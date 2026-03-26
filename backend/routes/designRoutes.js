/**
 * Design Routes
 * Maps HTTP endpoints to controller handlers
 */

const express = require('express');
const router = express.Router();
const designController = require('../controllers/designController');

// POST /api/design/upload      - Accept and store a design JSON
router.post('/upload', designController.uploadDesign);

// POST /api/design/validate    - Validate the design and return issues + score
router.post('/validate', designController.validateDesign);

// POST /api/design/autofix     - Auto-fix detected issues and return updated design
router.post('/autofix', designController.autoFixDesign);

// POST /api/design/report      - Generate and download a PDF validation report
router.post('/report', designController.generateReport);

// POST /api/design/ai-suggest  - Get AI-generated explanation & suggestion for an issue
router.post('/ai-suggest', designController.aiSuggest);

module.exports = router;
