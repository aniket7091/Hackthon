/**
 * SVG Analysis Service
 * Parse, validate, auto-fix and report SVG files.
 */

/**
 * Parse the raw SVG string into a simple element map.
 */
function parseSvgElements(svgContent) {
  const elements = [];
  const tagPattern = /<([a-zA-Z][a-zA-Z0-9:]*)([^>]*?)(\/?>)/g;
  let match;
  while ((match = tagPattern.exec(svgContent)) !== null) {
    elements.push({ tag: match[1], attrs: match[2].trim(), selfClosing: match[3] === '/>' });
  }
  return elements;
}

/**
 * Validate SVG and return list of issues.
 */
function validateSvg(svgContent) {
  const issues = [];

  // 1. Check root <svg> tag
  if (!svgContent.trim().startsWith('<svg') && !svgContent.includes('<svg')) {
    issues.push({
      type: 'structural',
      severity: 'High',
      element: '<svg>',
      explanation: 'Missing root <svg> element. SVG files must start with an <svg> tag.',
      fix: 'Wrap content in <svg xmlns="http://www.w3.org/2000/svg">...</svg>',
    });
  }

  // 2. Check xmlns attribute
  if (!svgContent.includes('xmlns')) {
    issues.push({
      type: 'attribute',
      severity: 'Medium',
      element: '<svg>',
      explanation: 'Missing xmlns attribute on <svg> root element.',
      fix: 'Add xmlns="http://www.w3.org/2000/svg" to root <svg> tag.',
    });
  }

  // 3. Check viewBox
  if (!svgContent.includes('viewBox') && !svgContent.includes('viewbox')) {
    issues.push({
      type: 'attribute',
      severity: 'High',
      element: '<svg>',
      explanation: 'Missing viewBox attribute. Without viewBox, SVG may not scale correctly across different screen sizes.',
      fix: 'Add viewBox="0 0 <width> <height>" to <svg> element.',
    });
  }

  // 4. Check for empty <g> groups
  const emptyGroups = (svgContent.match(/<g[^>]*>\s*<\/g>/g) || []).length;
  if (emptyGroups > 0) {
    issues.push({
      type: 'performance',
      severity: 'Low',
      element: '<g>',
      explanation: `Found ${emptyGroups} empty <g> group(s) which add unnecessary overhead.`,
      fix: 'Remove empty <g></g> elements.',
    });
  }

  // 5. Check accessibility (title/desc)
  if (!svgContent.includes('<title>') && !svgContent.includes('<title/>')) {
    issues.push({
      type: 'accessibility',
      severity: 'Medium',
      element: '<svg>',
      explanation: 'Missing <title> element. Screen readers cannot describe this SVG without a title.',
      fix: 'Add <title>Description of the image</title> as the first child of <svg>.',
    });
  }

  // 6. Detect deprecated xlink:href (should be href)
  if (svgContent.includes('xlink:href')) {
    issues.push({
      type: 'attribute',
      severity: 'Medium',
      element: 'use/image',
      explanation: 'xlink:href is deprecated in SVG 2.0. Use href instead for better compatibility.',
      fix: 'Replace xlink:href="..." with href="...".',
    });
  }

  // 7. Detect unclosed common tags
  const openTags = (svgContent.match(/<(path|rect|circle|polygon|polyline|ellipse|line)[^/]>/gi) || []).length;
  const elementsCount = (svgContent.match(/<(path|rect|circle|polygon|polyline|ellipse|line)/gi) || []).length;
  const selfClosedCount = (svgContent.match(/<(path|rect|circle|polygon|polyline|ellipse|line)[^>]*\/>/gi) || []).length;
  if (openTags > 0 && selfClosedCount < elementsCount) {
    issues.push({
      type: 'structural',
      severity: 'High',
      element: 'shape elements',
      explanation: `Some shape elements may not be properly self-closed (${openTags} potential issue(s) found).`,
      fix: 'Ensure shape elements like <path>, <rect> are self-closing: <path d="..." />.',
    });
  }

  // 8. Check for very large node count (performance)
  const nodeCount = (svgContent.match(/<[a-zA-Z]/g) || []).length;
  if (nodeCount > 500) {
    issues.push({
      type: 'performance',
      severity: 'Medium',
      element: 'document',
      explanation: `SVG contains ${nodeCount} elements which may cause slow rendering.`,
      fix: 'Consider merging paths, reducing detail, or using a symbol/defs approach.',
    });
  }

  // 9. Missing width/height
  if (!svgContent.match(/width\s*=\s*["']\d/)) {
    issues.push({
      type: 'attribute',
      severity: 'Low',
      element: '<svg>',
      explanation: 'Missing explicit width attribute on <svg> element.',
      fix: 'Add width="100%" (or a fixed pixel value) to the <svg> tag.',
    });
  }

  return issues;
}

/**
 * Auto-fix common SVG issues.
 */
function autoFixSvg(svgContent, issues) {
  let fixed = svgContent;
  const fixLog = [];

  // Fix: Add xmlns if missing
  if (!fixed.includes('xmlns') && fixed.includes('<svg')) {
    fixed = fixed.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"');
    fixLog.push('Added xmlns attribute to <svg> root');
  }

  // Fix: Add viewBox if missing (extract width/height to infer)
  if (!fixed.includes('viewBox') && !fixed.includes('viewbox')) {
    const wMatch = fixed.match(/width\s*=\s*["'](\d+)/);
    const hMatch = fixed.match(/height\s*=\s*["'](\d+)/);
    const w = wMatch ? wMatch[1] : '100';
    const h = hMatch ? hMatch[1] : '100';
    fixed = fixed.replace('<svg', `<svg viewBox="0 0 ${w} ${h}"`);
    fixLog.push(`Added viewBox="0 0 ${w} ${h}" to <svg>`);
  }

  // Fix: Add width if missing
  if (!fixed.match(/width\s*=\s*["']\d/)) {
    fixed = fixed.replace('<svg', '<svg width="100%"');
    fixLog.push('Added width="100%" to <svg>');
  }

  // Fix: Add title if missing
  if (!fixed.includes('<title>')) {
    fixed = fixed.replace(/(<svg[^>]*>)/, '$1\n  <title>FormWork AI Design</title>');
    fixLog.push('Added <title> element for accessibility');
  }

  // Fix: Remove empty groups
  const beforeCount = (fixed.match(/<g[^>]*>\s*<\/g>/g) || []).length;
  fixed = fixed.replace(/<g[^>]*>\s*<\/g>/g, '');
  if (beforeCount > 0) fixLog.push(`Removed ${beforeCount} empty <g> group(s)`);

  // Fix: Replace deprecated xlink:href
  if (fixed.includes('xlink:href')) {
    fixed = fixed.replace(/xlink:href/g, 'href');
    fixLog.push('Replaced deprecated xlink:href with href');
  }

  // Fix: Wrap in svg if root tag missing
  if (!fixed.trim().startsWith('<svg') && !fixed.includes('<svg')) {
    fixed = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100%">\n  <title>FormWork AI Design</title>\n  ${fixed}\n</svg>`;
    fixLog.push('Wrapped content in <svg> root element');
  }

  return { fixedSvg: fixed, fixLog };
}

/**
 * Generate smart AI-style suggestions.
 */
function generateSuggestions(svgContent, issues) {
  const suggestions = [];

  if (issues.some(i => i.type === 'performance')) {
    suggestions.push('Consider using <defs> and <use> to reuse repeated shapes for better performance.');
    suggestions.push('Merge overlapping paths using a vector editor to reduce node count.');
  }

  if (!svgContent.includes('fill="none"') && svgContent.includes('<path')) {
    suggestions.push('Add fill="none" to icon paths if they should be transparent, to avoid unintended fills.');
  }

  suggestions.push('Add aria-label or role="img" for improved screen reader compatibility.');
  suggestions.push('Use currentColor for fill/stroke to allow CSS theming via color property.');

  if (!svgContent.includes('transform')) {
    suggestions.push('Consider using CSS transforms for animations instead of SVG transform attributes for better performance.');
  }

  return suggestions;
}

module.exports = { validateSvg, autoFixSvg, generateSuggestions, parseSvgElements };
