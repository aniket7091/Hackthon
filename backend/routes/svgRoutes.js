const express = require('express');
const router = express.Router();
const { analyzeSvg } = require('../controllers/svgController');

// POST /api/svg/analyze
router.post('/analyze', analyzeSvg);

module.exports = router;
