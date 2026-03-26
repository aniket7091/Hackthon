/**
 * Auto-Fix Service
 * Automatically resolves detected issues by modifying shape properties.
 * Applies fixes non-destructively and tracks what was changed.
 */

const { distanceBetween, getShapeRadius, getBoundingBox, calculateScore } = require('../utils/helpers');

const MIN_DISTANCE = 5;
const MIN_SIZE = 1;
const MAX_SIZE = 200;

/**
 * Deep-clones the shapes array to avoid mutating the original.
 * @param {Array} shapes
 * @returns {Array}
 */
const cloneShapes = (shapes) => JSON.parse(JSON.stringify(shapes));

/**
 * Fix: Push two overlapping/too-close shapes apart along the vector connecting their centers.
 * @param {Object} a - Shape A (will NOT be moved — treat as anchor)
 * @param {Object} b - Shape B (will be repositioned)
 * @param {number} requiredGap - Desired gap between shapes
 */
const pushApart = (a, b, requiredGap = MIN_DISTANCE) => {
  const dist = distanceBetween(a, b);
  const combined = getShapeRadius(a) + getShapeRadius(b);
  const currentGap = dist - combined;

  if (currentGap >= requiredGap) return; // Already fine

  const pushDistance = requiredGap - currentGap + 1; // +1 buffer
  const dx = (b.x - a.x) || 1; // Avoid division by zero
  const dy = (b.y - a.y) || 0;
  const magnitude = Math.sqrt(dx * dx + dy * dy) || 1;

  // Move shape B along the direction away from shape A
  b.x = Math.round((b.x + (dx / magnitude) * pushDistance) * 100) / 100;
  b.y = Math.round((b.y + (dy / magnitude) * pushDistance) * 100) / 100;
};

/**
 * Fix: Clamp a shape's dimension to stay within [MIN_SIZE, MAX_SIZE].
 * @param {Object} shape - Will be mutated
 * @returns {boolean} - Whether the shape was changed
 */
const fixSizeConstraints = (shape) => {
  let changed = false;
  const clamp = (val, min, max) => Math.min(max, Math.max(min, val));

  if (shape.radius !== undefined && (shape.radius < MIN_SIZE || shape.radius > MAX_SIZE)) {
    shape.radius = clamp(shape.radius, MIN_SIZE, MAX_SIZE);
    changed = true;
  }
  if (shape.width !== undefined && (shape.width < MIN_SIZE || shape.width > MAX_SIZE)) {
    shape.width = clamp(shape.width, MIN_SIZE, MAX_SIZE);
    changed = true;
  }
  if (shape.height !== undefined && (shape.height < MIN_SIZE || shape.height > MAX_SIZE)) {
    shape.height = clamp(shape.height, MIN_SIZE, MAX_SIZE);
    changed = true;
  }
  if (shape.rx !== undefined && (shape.rx < MIN_SIZE || shape.rx > MAX_SIZE)) {
    shape.rx = clamp(shape.rx, MIN_SIZE, MAX_SIZE);
    changed = true;
  }
  if (shape.ry !== undefined && (shape.ry < MIN_SIZE || shape.ry > MAX_SIZE)) {
    shape.ry = clamp(shape.ry, MIN_SIZE, MAX_SIZE);
    changed = true;
  }
  return changed;
};

/**
 * Fix: Translate a shape so it fits within the canvas boundaries.
 * @param {Object} shape - Will be mutated
 * @param {Object} canvas - { width, height }
 * @returns {boolean}
 */
const fixCanvasBounds = (shape, canvas = { width: 500, height: 500 }) => {
  const [x1, y1, x2, y2] = getBoundingBox(shape);
  let changed = false;

  if (x1 < 0) { shape.x -= x1; changed = true; }
  if (y1 < 0) { shape.y -= y1; changed = true; }
  if (x2 > canvas.width) { shape.x -= (x2 - canvas.width); changed = true; }
  if (y2 > canvas.height) { shape.y -= (y2 - canvas.height); changed = true; }

  // Round to 2 decimal places
  shape.x = Math.round(shape.x * 100) / 100;
  shape.y = Math.round(shape.y * 100) / 100;
  return changed;
};

/**
 * Main auto-fix function.
 * Accepts the original shapes and the issues from validation, returns fixed shapes + fix log.
 * @param {Array} shapes - Original normalized shapes
 * @param {Array} issues - Issues from validationService
 * @param {Object} metadata - Design metadata (for canvas size)
 * @returns {{ fixedShapes: Array, fixLog: Array, fixedCount: number }}
 */
const applyFixes = (shapes, issues, metadata = {}) => {
  const fixedShapes = cloneShapes(shapes);
  const canvas = metadata.canvas || { width: 500, height: 500 };
  const fixLog = [];

  // ── Pass 1: Fix size constraints ────────────────────────────────────────────
  fixedShapes.forEach((shape) => {
    const changed = fixSizeConstraints(shape);
    if (changed) {
      fixLog.push({
        ruleId: 'SIZE_CONSTRAINT',
        shapeId: shape.id,
        action: 'Clamped dimensions to valid range',
        status: 'fixed',
      });
    }
  });

  // ── Pass 2: Bring shapes in bounds ──────────────────────────────────────────
  fixedShapes.forEach((shape) => {
    const changed = fixCanvasBounds(shape, canvas);
    if (changed) {
      fixLog.push({
        ruleId: 'CANVAS_BOUNDS',
        shapeId: shape.id,
        action: `Translated shape to fit within ${canvas.width}×${canvas.height} canvas`,
        status: 'fixed',
      });
    }
  });

  // ── Pass 3: Resolve overlaps and proximity (multiple passes for stability) ──
  const MAX_ITERATIONS = 10;
  for (let iter = 0; iter < MAX_ITERATIONS; iter++) {
    let anyChange = false;

    for (let i = 0; i < fixedShapes.length; i++) {
      for (let j = i + 1; j < fixedShapes.length; j++) {
        const a = fixedShapes[i];
        const b = fixedShapes[j];
        const before = { x: b.x, y: b.y };

        pushApart(a, b, MIN_DISTANCE);

        if (b.x !== before.x || b.y !== before.y) {
          // After moving, clamp back to canvas
          fixCanvasBounds(b, canvas);
          anyChange = true;

          // Only log once per pair (first iteration that changes them)
          if (iter === 0) {
            fixLog.push({
              ruleId: 'SPACING',
              shapeId: b.id,
              action: `Repositioned to resolve overlap/proximity with ${a.id}`,
              status: 'fixed',
            });
          }
        }
      }
    }

    if (!anyChange) break; // Converged — no more changes needed
  }

  return {
    fixedShapes,
    fixLog,
    fixedCount: fixLog.length,
  };
};

/**
 * Marks issues as fixed or still-pending based on the fix log.
 * @param {Array} issues
 * @param {Array} fixLog
 * @returns {Array} - Updated issues with status field set
 */
const markIssueStatuses = (issues, fixLog) => {
  const fixedRules = new Set(fixLog.map(f => f.ruleId));
  const fixedShapeIds = new Set(fixLog.map(f => f.shapeId));

  return issues.map(issue => {
    const isFixed =
      fixedRules.has(issue.ruleId) ||
      (issue.shapeIds && issue.shapeIds.some(id => fixedShapeIds.has(id)));
    return { ...issue, status: isFixed ? 'fixed' : 'pending' };
  });
};

module.exports = { applyFixes, markIssueStatuses };
