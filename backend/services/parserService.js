/**
 * Parser Service
 * Parses and normalizes incoming design JSON
 */

const SUPPORTED_TYPES = ['circle', 'rectangle', 'line', 'polygon', 'ellipse'];

/**
 * Normalizes a single shape by filling in defaults and validating fields.
 * @param {Object} shape - Raw shape from input
 * @param {number} index - Position in the shapes array
 * @returns {Object} - Normalized shape
 */
const normalizeShape = (shape, index) => {
  if (!shape || typeof shape !== 'object') {
    throw new Error(`Shape at index ${index} is invalid.`);
  }

  const type = (shape.type || 'unknown').toLowerCase();

  const normalized = {
    id: shape.id || `shape_${index}`,
    type,
    x: Number(shape.x) || 0,
    y: Number(shape.y) || 0,
    color: shape.color || '#000000',
    layer: shape.layer || 0,
    label: shape.label || `${type}_${index}`,
  };

  // Type-specific fields
  switch (type) {
    case 'circle':
      normalized.radius = Number(shape.radius) || 10;
      break;
    case 'rectangle':
      normalized.width = Number(shape.width) || 10;
      normalized.height = Number(shape.height) || Number(shape.width) || 10;
      normalized.rotation = Number(shape.rotation) || 0;
      break;
    case 'line':
      normalized.x2 = Number(shape.x2) || normalized.x + 10;
      normalized.y2 = Number(shape.y2) || normalized.y;
      normalized.thickness = Number(shape.thickness) || 1;
      break;
    case 'ellipse':
      normalized.rx = Number(shape.rx) || 10;
      normalized.ry = Number(shape.ry) || 5;
      break;
    case 'polygon':
      normalized.points = Array.isArray(shape.points) ? shape.points : [];
      normalized.sides = Number(shape.sides) || 3;
      normalized.radius = Number(shape.radius) || 10;
      break;
    default:
      // Unknown type — keep as-is but flag it
      normalized.unknownType = true;
      break;
  }

  return normalized;
};

/**
 * Parses and validates the full design JSON.
 * @param {Object} rawDesign - The raw JSON input from the client
 * @returns {{ shapes: Array, metadata: Object, warnings: Array }}
 */
const parseDesign = (rawDesign) => {
  if (!rawDesign || typeof rawDesign !== 'object') {
    throw new Error('Design input must be a JSON object.');
  }

  if (!Array.isArray(rawDesign.shapes) || rawDesign.shapes.length === 0) {
    throw new Error('Design must contain a non-empty "shapes" array.');
  }

  const warnings = [];
  const shapes = rawDesign.shapes.map((shape, i) => {
    const normalized = normalizeShape(shape, i);
    if (normalized.unknownType) {
      warnings.push(`Shape at index ${i} has unknown type "${shape.type}". Validation rules may not apply.`);
    }
    return normalized;
  });

  const metadata = {
    name: rawDesign.name || 'Untitled Design',
    version: rawDesign.version || '1.0',
    units: rawDesign.units || 'mm',
    canvas: rawDesign.canvas || { width: 500, height: 500 },
    shapeCount: shapes.length,
    parsedAt: new Date().toISOString(),
  };

  return { shapes, metadata, warnings };
};

module.exports = { parseDesign, normalizeShape };
