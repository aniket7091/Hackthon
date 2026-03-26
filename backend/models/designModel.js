/**
 * Design Model
 * Defines the in-memory structure for a design object.
 * In production, this would be a database schema (e.g., Mongoose model).
 */

/**
 * Creates a normalized design object with metadata.
 * @param {Object} rawDesign - Raw design JSON from the client
 * @returns {Object} - Structured design object
 */
const createDesign = (rawDesign) => {
  return {
    id: `design_${Date.now()}`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    original: JSON.parse(JSON.stringify(rawDesign)), // Deep copy of the original
    current: rawDesign,                              // Working copy (mutated by autofix)
    shapes: rawDesign.shapes || [],
    metadata: rawDesign.metadata || {},
    validation: null,   // Populated after validation
    autofix: null,      // Populated after autofix
    aiSuggestions: [],  // Populated after AI analysis
  };
};

/**
 * Updates the validation result on a design object.
 * @param {Object} design
 * @param {Object} validationResult
 * @returns {Object} - Updated design
 */
const updateValidation = (design, validationResult) => {
  return {
    ...design,
    updatedAt: new Date().toISOString(),
    validation: validationResult,
  };
};

/**
 * Updates the autofix result on a design object.
 * @param {Object} design
 * @param {Object} autofixResult
 * @returns {Object} - Updated design
 */
const updateAutofix = (design, autofixResult) => {
  return {
    ...design,
    updatedAt: new Date().toISOString(),
    current: autofixResult.fixedDesign,
    autofix: autofixResult,
  };
};

module.exports = { createDesign, updateValidation, updateAutofix };
