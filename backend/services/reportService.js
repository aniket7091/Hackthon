/**
 * Report Service
 * Generates a professional PDF validation report using PDFKit.
 * Strictly uses ASCII-safe text and core fonts for cross-platform compatibility.
 */

const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const { formatTimestamp } = require('../utils/helpers');

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const COLORS = {
  primary: '#1a1a2e',
  accent: '#e94560',
  accentBlue: '#0f3460',
  success: '#27ae60',
  warning: '#f39c12',
  error: '#e74c3c',
  light: '#f5f5f5',
  gray: '#7f8c8d',
  white: '#ffffff',
  text: '#2c3e50',
};

const FONTS = {
  normal: 'Helvetica',
  bold: 'Helvetica-Bold',
};

// ─── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Strips unsupported unicode characters and maps specific symbols to ASCII.
 */
const asciiSafe = (str) => {
  if (!str) return '';
  return String(str)
    .replace(/×/g, 'x')
    .replace(/²/g, '^2')
    .replace(/³/g, '^3')
    .replace(/[^\x20-\x7E]/g, ''); // Strip all non-printable ASCII (emojis, etc.)
};

const scoreColor = (score) => {
  if (score >= 85) return COLORS.success;
  if (score >= 60) return COLORS.warning;
  return COLORS.error;
};

const issueColor = (type) => {
  if (type === 'error') return COLORS.error;
  if (type === 'warning') return COLORS.warning;
  return COLORS.accentBlue;
};

const statusColor = (status) => {
  return status === 'fixed' ? COLORS.success : COLORS.error;
};

/**
 * Checks if the required height is available on the current page.
 * If not, triggers a clean page break.
 */
const ensureSpace = (doc, requiredHeight) => {
  if (doc.y + requiredHeight > doc.page.height - doc.page.margins.bottom) {
    console.log(`New page added at Y: ${doc.y}`);
    doc.addPage();
  }
};

// ─── Section Builders ──────────────────────────────────────────────────────────

const drawDivider = (doc, y) => {
  doc.moveTo(50, y).lineTo(545, y).strokeColor('#e0e0e0').lineWidth(1).stroke();
};

const drawHeader = (doc, title, subtitle) => {
  // Background bar
  doc.rect(0, 0, 595, 120).fill(COLORS.primary);

  // Title
  doc.font(FONTS.bold).fontSize(24).fillColor(COLORS.white).text('DesignGuard AI', 50, 30);
  doc.font(FONTS.normal).fontSize(12).fillColor('#aab2bd').text('CAD Validation Report', 50, 60);

  // Report meta
  doc.font(FONTS.normal).fontSize(10).fillColor('#aab2bd')
    .text(`Generated: ${asciiSafe(formatTimestamp())}`, 50, 90)
    .text(`Report Type: Full Validation`, 350, 90, { align: 'right', width: 195 });

  doc.moveDown(4);
};

const drawSummaryCard = (doc, summary, score, designName) => {
  const y = doc.y + 10;
  doc.rect(50, y, 495, 110).fill(COLORS.light).stroke('#e0e0e0');

  // Design name
  doc.font(FONTS.bold).fontSize(16).fillColor(COLORS.primary).text(asciiSafe(designName || 'Untitled Design'), 65, y + 15);
  doc.font(FONTS.normal).fontSize(12).fillColor(COLORS.gray)
    .text(`Shapes Checked: ${summary.totalShapes}`, 65, y + 42)
    .text(`Total Issues: ${summary.totalIssues}`, 65, y + 60)
    .text(`Errors: ${summary.errors} | Warnings: ${summary.warnings}`, 65, y + 78);

  // Score circle (right side)
  const scoreX = 450;
  const scoreY = y + 55;
  doc.circle(scoreX, scoreY, 38).fill(scoreColor(score));
  doc.font(FONTS.bold).fontSize(22).fillColor(COLORS.white)
    .text(String(score), scoreX - 22, scoreY - 14, { width: 44, align: 'center' });
  doc.font(FONTS.normal).fontSize(9).fillColor(COLORS.white)
    .text('/ 100', scoreX - 22, scoreY + 10, { width: 44, align: 'center' });
  doc.font(FONTS.bold).fontSize(9).fillColor(scoreColor(score))
    .text('SCORE', scoreX - 22, y + 97, { width: 44, align: 'center' });

  doc.moveDown(0.5);
  doc.y = y + 135;
};

const drawSectionTitle = (doc, title) => {
  ensureSpace(doc, 60);
  doc.moveDown(0.5);
  doc.font(FONTS.bold).fontSize(16).fillColor(COLORS.primary).text(asciiSafe(title));
  drawDivider(doc, doc.y + 2);
  doc.moveDown(0.8);
};

const drawBeforeAfterComparison = (doc, beforeScore, afterScore) => {
  const y = doc.y + 5;
  const leftX = 65;
  const rightX = 325;
  const boxW = 220;
  const boxH = 70;

  // Before
  doc.rect(leftX, y, boxW, boxH).fill('#fff5f5').stroke(COLORS.error);
  doc.font(FONTS.bold).fontSize(12).fillColor(COLORS.error).text('BEFORE AUTO-FIX', leftX + 10, y + 10);
  doc.font(FONTS.bold).fontSize(28).fillColor(COLORS.error).text(`${beforeScore}`, leftX + 10, y + 26);
  doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.gray).text('/ 100', leftX + 55, y + 40);

  // After
  doc.rect(rightX, y, boxW, boxH).fill('#f0fff4').stroke(COLORS.success);
  doc.font(FONTS.bold).fontSize(12).fillColor(COLORS.success).text('AFTER AUTO-FIX', rightX + 10, y + 10);
  doc.font(FONTS.bold).fontSize(28).fillColor(COLORS.success).text(`${afterScore}`, rightX + 10, y + 26);
  doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.gray).text('/ 100', rightX + 55, y + 40);

  // Improvement
  const improvement = afterScore - beforeScore;
  if (improvement > 0) {
    doc.font(FONTS.bold).fontSize(12).fillColor(COLORS.success)
      .text(`+${improvement} point improvement`, leftX, y + boxH + 12);
  }

  doc.y = y + boxH + 40;
};

const drawIssuesSection = (doc, issues) => {
  if (!issues || issues.length === 0) {
    doc.font(FONTS.bold).fontSize(12).fillColor(COLORS.success)
      .text('All validation checks passed. No issues found.', { indent: 10 });
    doc.moveDown(1);
    return;
  }

  issues.forEach((issue, idx) => {
    ensureSpace(doc, 80);

    const badgeColor = issueColor(issue.type);
    const statusBadge = statusColor(issue.status || 'pending');
    
    // Header line: 1. [ERROR] message
    doc.font(FONTS.bold).fontSize(12).fillColor(COLORS.primary)
      .text(`${idx + 1}. `, { continued: true });
    doc.font(FONTS.bold).fontSize(12).fillColor(badgeColor)
      .text(`[${(issue.type || 'info').toUpperCase()}] `, { continued: true });
    doc.font(FONTS.normal).fontSize(12).fillColor(COLORS.text)
      .text(asciiSafe(issue.message), { width: 450 });

    // Fix suggestion line (built-in validation rules)
    if (issue.suggestion) {
      doc.moveDown(0.2);
      doc.font(FONTS.bold).fontSize(10).fillColor(COLORS.gray)
        .text('Fix: ', { indent: 20, continued: true });
      doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.gray)
        .text(asciiSafe(issue.suggestion), { width: 450 });
    }

    // AI suggestion block (if present)
    if (issue.aiSuggestion && issue.aiSuggestion.explanation) {
      doc.moveDown(0.2);
      doc.font(FONTS.bold).fontSize(10).fillColor(COLORS.accentBlue)
        .text('AI Analysis: ', { indent: 20, continued: true });
      doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.text)
        .text(asciiSafe(issue.aiSuggestion.explanation), { width: 450 });
      
      if (issue.aiSuggestion.steps && issue.aiSuggestion.steps.length > 0) {
        doc.moveDown(0.2);
        issue.aiSuggestion.steps.forEach(step => {
          doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.gray)
            .text(`- ${asciiSafe(step)}`, { indent: 30, width: 440 });
        });
      }
    }

    // Status pill
    doc.moveDown(0.3);
    doc.font(FONTS.bold).fontSize(10).fillColor(COLORS.text)
      .text('Status: ', { indent: 20, continued: true });
    doc.font(FONTS.bold).fontSize(10).fillColor(statusBadge)
      .text((issue.status || 'pending').toUpperCase());

    doc.moveDown(0.8);
  });
};

const drawFixLog = (doc, fixLog) => {
  if (!fixLog || fixLog.length === 0) {
    doc.font(FONTS.normal).fontSize(12).fillColor(COLORS.gray)
      .text('No automatic fixes were applied.', { indent: 10 });
    return;
  }

  fixLog.forEach((fix, idx) => {
    ensureSpace(doc, 40);
    doc.font(FONTS.bold).fontSize(11).fillColor(COLORS.primary)
      .text(`${idx + 1}. `, { continued: true });
    doc.font(FONTS.bold).fontSize(11).fillColor(COLORS.success)
      .text(`[FIXED] `, { continued: true });
    doc.font(FONTS.normal).fontSize(11).fillColor(COLORS.text)
      .text(`Shape: ${asciiSafe(fix.shapeId)} -- ${asciiSafe(fix.action)}`, { width: 450 });
    doc.moveDown(0.3);
  });
};

const drawFooter = (doc) => {
  const range = doc.bufferedPageRange();
  const totalPages = range.count;
  
  console.log("Total Pages:", totalPages);

  for (let i = 0; i < totalPages; i++) {
    doc.switchToPage(i);
    doc.font(FONTS.normal).fontSize(10).fillColor(COLORS.gray)
      .text(`DesignGuard AI -- Confidential Validation Report -- Page ${i + 1} of ${totalPages}`,
        50, doc.page.height - 50, { align: 'center', width: 495 });
  }
};

// ─── Main Report Generator ─────────────────────────────────────────────────────

/**
 * Generates a PDF report, saves it to disk, and returns the file path.
 * @param {Object} reportData - All report data
 * @returns {Promise<string>} - Resolves with the absolute path of the generated PDF
 */
const generateReport = (reportData) => {
  return new Promise((resolve, reject) => {
    try {
      const {
        design,
        metadata,
        issues,
        fixLog,
        beforeScore,
        afterScore,
        aiSuggestions,
      } = reportData;

      const reportsDir = path.join(__dirname, '../reports');
      if (!fs.existsSync(reportsDir)) {
        fs.mkdirSync(reportsDir, { recursive: true });
      }

      const filePath = path.join(reportsDir, `report_${Date.now()}.pdf`);
      console.log('Generating PDF...');

      const doc = new PDFDocument({ margin: 50, size: 'A4', autoFirstPage: true, bufferPages: true });
      const stream = fs.createWriteStream(filePath);

      doc.pipe(stream);

      // Handle stream completion successfully
      stream.on('finish', () => {
        console.log(`PDF saved at: ${filePath}`);
        resolve(filePath);
      });

      // Handle file stream error
      stream.on('error', (err) => {
        console.error('File stream error:', err);
        reject(new Error('Failed to write PDF file to disk.'));
      });

      // Handle PDF generation error
      doc.on('error', (err) => {
        console.error('PDF document error:', err);
        reject(new Error('Failed to generate PDF document.'));
      });

      // ── Page 1 ─────────────────────────────────────────────────────────────────
      drawHeader(doc);

      drawSummaryCard(
        doc,
        {
          totalShapes: (design?.shapes || []).length,
          totalIssues: issues.length,
          errors: issues.filter(i => i.type === 'error').length,
          warnings: issues.filter(i => i.type === 'warning').length,
        },
        afterScore ?? beforeScore,
        metadata?.name
      );

      if (afterScore !== undefined && afterScore !== beforeScore) {
        drawSectionTitle(doc, 'Score Comparison');
        drawBeforeAfterComparison(doc, beforeScore, afterScore);
      }

      drawSectionTitle(doc, 'Validation Issues');
      drawIssuesSection(doc, issues);

      drawSectionTitle(doc, 'Auto-Fix Log');
      drawFixLog(doc, fixLog);

      // (AI Suggestions are now merged inline under each issue in drawIssuesSection, making it much cleaner)

      drawFooter(doc);

      doc.end();
    } catch (err) {
      console.error('Report generation error:', err);
      reject(new Error('Failed to process report data: ' + err.message));
    }
  });
};

module.exports = { generateReport };

