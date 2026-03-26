/**
 * Utility Helpers
 * Shared utility functions used across services and controllers
 */

/**
 * Calculates the Euclidean distance between the center points of two shapes.
 * @param {Object} a - Shape A with x, y properties
 * @param {Object} b - Shape B with x, y properties
 * @returns {number} - Distance between centers
 */
const distanceBetween = (a, b) => {
  const dx = (a.x || 0) - (b.x || 0);
  const dy = (a.y || 0) - (b.y || 0);
  return Math.sqrt(dx * dx + dy * dy);
};

/**
 * Returns the effective "radius" of a shape for collision detection.
 * Circles use their radius; rectangles use half the diagonal.
 * @param {Object} shape
 * @returns {number}
 */
const getShapeRadius = (shape) => {
  if (shape.type === 'circle') return shape.radius || 0;
  if (shape.type === 'rectangle') {
    const w = shape.width || 0;
    const h = shape.height || shape.width || 0;
    return Math.sqrt(w * w + h * h) / 2;
  }
  if (shape.type === 'line') return 0;
  return (shape.size || shape.radius || 10); // fallback
};

/**
 * Computes the bounding box of a shape [x1, y1, x2, y2].
 * @param {Object} shape
 * @returns {Array} - [minX, minY, maxX, maxY]
 */
const getBoundingBox = (shape) => {
  const x = shape.x || 0;
  const y = shape.y || 0;

  if (shape.type === 'circle') {
    const r = shape.radius || 0;
    return [x - r, y - r, x + r, y + r];
  }
  if (shape.type === 'rectangle') {
    const w = shape.width || 0;
    const h = shape.height || w;
    return [x, y, x + w, y + h];
  }
  if (shape.type === 'line') {
    const x2 = shape.x2 || x;
    const y2 = shape.y2 || y;
    return [Math.min(x, x2), Math.min(y, y2), Math.max(x, x2), Math.max(y, y2)];
  }
  // generic fallback: treat as small square
  const s = shape.size || 5;
  return [x - s, y - s, x + s, y + s];
};

/**
 * Checks if two bounding boxes overlap.
 * @param {Array} boxA - [x1, y1, x2, y2]
 * @param {Array} boxB - [x1, y1, x2, y2]
 * @returns {boolean}
 */
const boxesOverlap = (boxA, boxB) => {
  const [ax1, ay1, ax2, ay2] = boxA;
  const [bx1, by1, bx2, by2] = boxB;
  return ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1;
};

/**
 * Calculates a validation score starting from 100, deducting per issue.
 * Errors cost 15 points, warnings 5 points, info 1 point.
 * @param {Array} issues - Array of issue objects with a `type` field
 * @returns {number} - Score clamped to [0, 100]
 */
const calculateScore = (issues) => {
  const deductions = issues.reduce((acc, issue) => {
    if (issue.type === 'error') return acc + 15;
    if (issue.type === 'warning') return acc + 5;
    return acc + 1;
  }, 0);
  return Math.max(0, 100 - deductions);
};

/**
 * Generates a short unique label for a shape (e.g. "circle#0", "rectangle#2").
 * @param {Object} shape
 * @param {number} index
 * @returns {string}
 */
const shapeLabel = (shape, index) => `${shape.type || 'shape'}#${index}`;

/**
 * Formats a timestamp as a human-readable string.
 * @param {string|Date} ts
 * @returns {string}
 */
const formatTimestamp = (ts) => {
  const d = ts ? new Date(ts) : new Date();
  return d.toLocaleString('en-US', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  });
};

module.exports = { distanceBetween, getShapeRadius, getBoundingBox, boxesOverlap, calculateScore, shapeLabel, formatTimestamp };
