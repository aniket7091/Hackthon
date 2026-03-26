/**
 * Validation Service
 * Rule-based design validation engine.
 * Each rule is a function that receives all shapes and returns an array of issues.
 */

const { distanceBetween, getShapeRadius, getBoundingBox, boxesOverlap, calculateScore, shapeLabel } = require('../utils/helpers');

// ─── Constants ─────────────────────────────────────────────────────────────────
const MIN_DISTANCE = 5;    // Minimum gap between shapes (units)
const MAX_SIZE = 200;      // Max allowed dimension for any shape (units)
const MIN_SIZE = 1;        // Minimum allowed dimension for any shape (units)
const MAX_SHAPES = 50;     // Maximum number of shapes in a design
const CANVAS_BOUNDS = { width: 500, height: 500 }; // Default canvas size

// ─── Rule Implementations ──────────────────────────────────────────────────────

/**
 * Rule 1: Minimum distance between shapes.
 * Two shapes that are closer than MIN_DISTANCE (center-to-center minus radii) are flagged.
 */
const checkMinimumDistance = (shapes) => {
  const issues = [];
  for (let i = 0; i < shapes.length; i++) {
    for (let j = i + 1; j < shapes.length; j++) {
      const a = shapes[i];
      const b = shapes[j];
      const dist = distanceBetween(a, b);
      const gap = dist - getShapeRadius(a) - getShapeRadius(b);

      if (gap < MIN_DISTANCE && gap >= 0) {
        issues.push({
          type: 'warning',
          ruleId: 'MIN_DISTANCE',
          shapeIds: [a.id, b.id],
          message: `${shapeLabel(a, i)} and ${shapeLabel(b, j)} are too close (gap: ${gap.toFixed(2)} units, min: ${MIN_DISTANCE}).`,
          suggestion: `Increase spacing between ${shapeLabel(a, i)} and ${shapeLabel(b, j)} by at least ${(MIN_DISTANCE - gap).toFixed(2)} units.`,
          severity: 'medium',
          status: 'pending',
        });
      }
    }
  }
  return issues;
};

/**
 * Rule 2: Overlapping shape detection.
 * Two shapes whose bounding boxes intersect are flagged as errors.
 */
const checkOverlapping = (shapes) => {
  const issues = [];
  for (let i = 0; i < shapes.length; i++) {
    for (let j = i + 1; j < shapes.length; j++) {
      const a = shapes[i];
      const b = shapes[j];
      const boxA = getBoundingBox(a);
      const boxB = getBoundingBox(b);

      if (boxesOverlap(boxA, boxB)) {
        issues.push({
          type: 'error',
          ruleId: 'OVERLAP',
          shapeIds: [a.id, b.id],
          message: `${shapeLabel(a, i)} overlaps with ${shapeLabel(b, j)}.`,
          suggestion: `Reposition ${shapeLabel(a, i)} or ${shapeLabel(b, j)} so their bounding boxes no longer intersect.`,
          severity: 'high',
          status: 'pending',
        });
      }
    }
  }
  return issues;
};

/**
 * Rule 3: Size constraints.
 * Shapes must have dimensions within [MIN_SIZE, MAX_SIZE].
 */
const checkSizeConstraints = (shapes) => {
  const issues = [];
  shapes.forEach((shape, i) => {
    const checkDim = (value, dimName) => {
      if (value !== undefined && value < MIN_SIZE) {
        issues.push({
          type: 'error',
          ruleId: 'SIZE_TOO_SMALL',
          shapeIds: [shape.id],
          message: `${shapeLabel(shape, i)} has ${dimName} ${value} which is below minimum ${MIN_SIZE}.`,
          suggestion: `Set ${dimName} of ${shapeLabel(shape, i)} to at least ${MIN_SIZE}.`,
          severity: 'high',
          status: 'pending',
        });
      }
      if (value !== undefined && value > MAX_SIZE) {
        issues.push({
          type: 'warning',
          ruleId: 'SIZE_TOO_LARGE',
          shapeIds: [shape.id],
          message: `${shapeLabel(shape, i)} has ${dimName} ${value} which exceeds maximum ${MAX_SIZE}.`,
          suggestion: `Consider reducing ${dimName} of ${shapeLabel(shape, i)} to at most ${MAX_SIZE}.`,
          severity: 'medium',
          status: 'pending',
        });
      }
    };

    checkDim(shape.radius, 'radius');
    checkDim(shape.width, 'width');
    checkDim(shape.height, 'height');
    checkDim(shape.rx, 'rx');
    checkDim(shape.ry, 'ry');
  });
  return issues;
};

/**
 * Rule 4: Canvas boundary check.
 * Shapes must be fully within the design canvas.
 */
const checkCanvasBounds = (shapes, canvas = CANVAS_BOUNDS) => {
  const issues = [];
  shapes.forEach((shape, i) => {
    const [x1, y1, x2, y2] = getBoundingBox(shape);
    if (x1 < 0 || y1 < 0 || x2 > canvas.width || y2 > canvas.height) {
      issues.push({
        type: 'error',
        ruleId: 'OUT_OF_BOUNDS',
        shapeIds: [shape.id],
        message: `${shapeLabel(shape, i)} extends outside canvas bounds (${canvas.width}×${canvas.height}).`,
        suggestion: `Reposition ${shapeLabel(shape, i)} so it stays within the canvas.`,
        severity: 'high',
        status: 'pending',
      });
    }
  });
  return issues;
};

/**
 * Rule 5: Shape count limit.
 */
const checkShapeCount = (shapes) => {
  if (shapes.length > MAX_SHAPES) {
    return [{
      type: 'warning',
      ruleId: 'TOO_MANY_SHAPES',
      shapeIds: [],
      message: `Design contains ${shapes.length} shapes, exceeding the recommended maximum of ${MAX_SHAPES}.`,
      suggestion: 'Consider simplifying the design by grouping or removing redundant shapes.',
      severity: 'low',
      status: 'pending',
    }];
  }
  return [];
};

/**
 * Rule 6: Detect unknown/unsupported shape types.
 */
const checkUnknownTypes = (shapes) => {
  const SUPPORTED = ['circle', 'rectangle', 'line', 'polygon', 'ellipse'];
  return shapes
    .filter(s => !SUPPORTED.includes(s.type))
    .map((shape, idx) => ({
      type: 'warning',
      ruleId: 'UNKNOWN_TYPE',
      shapeIds: [shape.id],
      message: `Shape "${shape.id}" has unsupported type "${shape.type}".`,
      suggestion: `Use one of the supported types: ${SUPPORTED.join(', ')}.`,
      severity: 'low',
      status: 'pending',
    }));
};

// ─── Main Validation Function ──────────────────────────────────────────────────

/**
 * Runs all validation rules against a parsed design.
 * @param {Array} shapes - Normalized shapes from parserService
 * @param {Object} metadata - Design metadata (canvas size, etc.)
 * @returns {{ issues: Array, score: number, summary: Object }}
 */
const validateDesign = (shapes, metadata = {}) => {
  const canvas = metadata.canvas || CANVAS_BOUNDS;
  const allRules = [
    checkShapeCount,
    checkUnknownTypes,
    (s) => checkSizeConstraints(s),
    (s) => checkCanvasBounds(s, canvas),
    (s) => checkMinimumDistance(s),
    (s) => checkOverlapping(s),
  ];

  // Collect issues from all rules
  const issues = allRules.flatMap(rule => rule(shapes));

  const score = calculateScore(issues);
  const errorCount = issues.filter(i => i.type === 'error').length;
  const warningCount = issues.filter(i => i.type === 'warning').length;

  return {
    issues,
    score,
    summary: {
      totalShapes: shapes.length,
      totalIssues: issues.length,
      errors: errorCount,
      warnings: warningCount,
      passed: issues.length === 0,
    },
  };
};

module.exports = { validateDesign };
