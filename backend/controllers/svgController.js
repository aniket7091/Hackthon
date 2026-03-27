/**
 * SVG Controller
 * POST /api/svg/analyze
 */

const { validateSvg, autoFixSvg, generateSuggestions, parseSvgElements } = require('../services/svgAnalysisService');

const analyzeSvg = async (req, res) => {
  try {
    const { svgContent } = req.body;

    if (!svgContent || typeof svgContent !== 'string' || !svgContent.trim()) {
      return res.status(400).json({
        status: 'error',
        message: 'Request body must include a non-empty "svgContent" string field.',
      });
    }

    // Parse elements
    const elements = parseSvgElements(svgContent);

    // Validate
    const issues = validateSvg(svgContent);

    // Auto-fix
    const { fixedSvg, fixLog } = autoFixSvg(svgContent, issues);

    // Re-validate fixed version to confirm fixes applied
    const remainingIssues = validateSvg(fixedSvg);

    // Suggestions
    const suggestions = generateSuggestions(svgContent, issues);

    // Score
    const score = Math.max(0, 100 - issues.length * 12);
    const fixedScore = Math.max(0, 100 - remainingIssues.length * 12);

    return res.status(200).json({
      status: 'success',
      issues_found: issues.length,
      issues: issues.map((issue, i) => ({ id: `issue_${i}`, ...issue })),
      fixed_svg: fixedSvg,
      fix_log: fixLog,
      fixes_applied: fixLog.length,
      remaining_issues: remainingIssues.length,
      suggestions,
      preview: {
        before: svgContent,
        after: fixedSvg,
      },
      score: { before: score, after: fixedScore },
      elements_count: elements.length,
      '3d_model': 'enabled',
    });
  } catch (err) {
    console.error('[SVG Analyze] Error:', err.message);
    return res.status(500).json({
      status: 'error',
      message: 'SVG analysis failed: ' + err.message,
    });
  }
};

module.exports = { analyzeSvg };
