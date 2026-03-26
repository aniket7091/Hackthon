/**
 * Design Controller
 * Handles all incoming requests for the /api/design routes.
 * Orchestrates services: parser → validation → AI → autofix → report.
 */

const { parseDesign } = require('../services/parserService');
const { validateDesign } = require('../services/validationService');
const { getAISuggestion, enrichIssuesWithAI } = require('../services/aiService');
const { applyFixes, markIssueStatuses } = require('../services/autoFixService');
const { generateReport } = require('../services/reportService');
const { createDesign } = require('../models/designModel');
const { calculateScore } = require('../utils/helpers');

// ─── 1. Upload Design ──────────────────────────────────────────────────────────

/**
 * POST /api/design/upload
 * Accepts a design JSON and returns a normalized, parsed version.
 */
const uploadDesign = async (req, res) => {
  try {
    const rawDesign = req.body;

    if (!rawDesign || Object.keys(rawDesign).length === 0) {
      return res.status(400).json({ success: false, message: 'Request body is empty. Please send a design JSON.' });
    }

    const { shapes, metadata, warnings } = parseDesign(rawDesign);
    const design = createDesign({ ...rawDesign, shapes });

    res.status(200).json({
      success: true,
      message: 'Design uploaded and parsed successfully.',
      data: {
        designId: design.id,
        metadata,
        shapes,
        shapeCount: shapes.length,
        parseWarnings: warnings,
      },
    });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─── 2. Validate Design ────────────────────────────────────────────────────────

/**
 * POST /api/design/validate
 * Parses the design, runs all validation rules, and returns issues + score.
 */
const validateDesignHandler = async (req, res) => {
  try {
    const rawDesign = req.body;

    if (!rawDesign || !rawDesign.shapes) {
      return res.status(400).json({ success: false, message: 'Design with "shapes" array is required.' });
    }

    // Parse and normalize
    const { shapes, metadata, warnings } = parseDesign(rawDesign);

    // Run validation rules
    const { issues, score, summary } = validateDesign(shapes, metadata);

    res.status(200).json({
      success: true,
      message: 'Validation completed.',
      data: {
        metadata,
        summary,
        score,
        issues,
        parseWarnings: warnings,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─── 3. Auto-Fix Design ────────────────────────────────────────────────────────

/**
 * POST /api/design/autofix
 * Runs validation, applies automated fixes, re-validates, and returns both states.
 */
const autoFixDesign = async (req, res) => {
  try {
    const rawDesign = req.body;

    if (!rawDesign || !rawDesign.shapes) {
      return res.status(400).json({ success: false, message: 'Design with "shapes" array is required.' });
    }

    // Parse
    const { shapes, metadata, warnings } = parseDesign(rawDesign);

    // Validate original
    const { issues: originalIssues, score: beforeScore, summary: originalSummary } = validateDesign(shapes, metadata);

    // Apply auto-fixes
    const { fixedShapes, fixLog, fixedCount } = applyFixes(shapes, originalIssues, metadata);

    // Re-validate fixed design
    const { issues: remainingIssues, score: afterScore, summary: fixedSummary } = validateDesign(fixedShapes, metadata);

    // Mark original issues with fix status
    const issuesWithStatus = markIssueStatuses(originalIssues, fixLog);

    res.status(200).json({
      success: true,
      message: `Auto-fix completed. ${fixedCount} fix(es) applied.`,
      data: {
        metadata,
        before: {
          shapes,
          issues: originalIssues,
          score: beforeScore,
          summary: originalSummary,
        },
        after: {
          shapes: fixedShapes,
          issues: remainingIssues,
          score: afterScore,
          summary: fixedSummary,
        },
        fixLog,
        fixedCount,
        issuesWithStatus,
        improvement: afterScore - beforeScore,
        parseWarnings: warnings,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─── 4. Generate PDF Report ────────────────────────────────────────────────────

/**
 * POST /api/design/report
 * Runs the full pipeline (validate + fix + AI enrich) and generates a PDF report.
 */
const generateReportHandler = async (req, res) => {
  try {
    const rawDesign = req.body;

    if (!rawDesign || !rawDesign.shapes) {
      return res.status(400).json({ success: false, message: 'Design with "shapes" array is required.' });
    }

    // Parse
    const { shapes, metadata } = parseDesign(rawDesign);

    // Validate
    const { issues, score: beforeScore } = validateDesign(shapes, metadata);

    // Auto-fix
    const { fixedShapes, fixLog } = applyFixes(shapes, issues, metadata);

    // Re-validate after fix
    const { score: afterScore } = validateDesign(fixedShapes, metadata);

    // Enrich top issues with AI suggestions (limit to first 5 to keep it fast)
    const topIssues = issues.slice(0, 5);
    const enrichedIssues = await enrichIssuesWithAI(topIssues);
    const aiSuggestions = enrichedIssues.map(i => i.aiSuggestion).filter(Boolean);

    // Mark statuses
    const issuesWithStatus = markIssueStatuses(issues, fixLog);

    // Generate PDF to disk
    const filePath = await generateReport({
      design: { shapes: fixedShapes },
      metadata,
      issues: issuesWithStatus,
      fixLog,
      beforeScore,
      afterScore,
      aiSuggestions,
    });

    // Send file to client
    const downloadName = `DesignGuard_Report_${Date.now()}.pdf`;
    res.download(filePath, downloadName, (err) => {
      if (err) {
        console.error('Error sending file:', err);
        // Can't send JSON here if headers are already sent, but res.download handles headers
        if (!res.headersSent) res.status(500).json({ success: false, message: 'Error downloading file' });
      }
    });

  } catch (err) {
    console.error('Report generation error:', err);
    if (!res.headersSent) {
      res.status(500).json({ success: false, message: 'Failed to generate report: ' + err.message });
    }
  }
};

// ─── 5. AI Suggestion ─────────────────────────────────────────────────────────

/**
 * POST /api/design/ai-suggest
 * Accepts a single issue and returns an AI-generated explanation + suggestion.
 * Body: { issue: { type, ruleId, message, ... } }
 */
const aiSuggest = async (req, res) => {
  try {
    const { issue } = req.body;

    // Validate input — issue.message is mandatory
    if (!issue || !issue.message) {
      return res.status(400).json({
        success: false,
        message: 'Request body must include an "issue" object with at least a "message" field.',
      });
    }

    const suggestion = await getAISuggestion(issue);

    return res.status(200).json({
      success: true,
      data: {
        issue: { message: issue.message, ...issue },
        suggestion,
      },
    });
  } catch (err) {
    console.error('[AI Suggest] Error:', err.message);
    return res.status(503).json({
      success: false,
      message: 'AI service unavailable',
      detail: err.message,
    });
  }
};


module.exports = {
  uploadDesign,
  validateDesign: validateDesignHandler,
  autoFixDesign,
  generateReport: generateReportHandler,
  aiSuggest,
};
