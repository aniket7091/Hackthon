/**
 * AI Service — DesignGuard AI
 * Calls the Groq (Kimi K2) API to generate real engineering suggestions.
 * No mock or fallback responses are used.
 */

const axios = require('axios');

/**
 * Builds the engineering prompt from an issue object.
 * @param {Object} issue
 * @returns {string}
 */
const buildPrompt = (issue) => `
You are a CAD design expert.

Issue: ${issue.message}

Give:
1. Short technical explanation
2. Clear fix suggestion
3. Keep it specific and actionable
`;

/**
 * Cleans a raw text block:
 * - Strips leading labels like "Explanation:", "Fix:", "1.", "2.", "**...**"
 * - Collapses multiple newlines/spaces
 * - Trims whitespace
 * @param {string} text
 * @returns {string}
 */
const cleanText = (text) => {
  return text
    .replace(/\*\*(.*?)\*\*/g, '$1')          // Remove markdown bold
    .replace(/^[\s\d\-.*]+[.)]\s*/gm, '')     // Remove leading "1." "2." "- " "* "
    .replace(/^(explanation|fix|suggestion|step|note)[:\s-]*/gim, '')  // Remove section labels
    .replace(/\n{2,}/g, ' ')                  // Collapse blank lines
    .replace(/\n/g, ' ')                      // Flatten single newlines
    .replace(/\s{2,}/g, ' ')                  // Collapse multiple spaces
    .trim();
};

/**
 * Converts a block of fix/suggestion text into an array of actionable steps.
 * Splits on sentence boundaries, numbered lists, or newlines.
 * Filters out empty or very short fragments.
 * @param {string} text
 * @returns {string[]}
 */
const extractSteps = (text) => {
  // First try splitting on newlines (numbered list style)
  let parts = text.split(/\n+/).map(s => s.trim()).filter(Boolean);

  // If that gave us only 1 part, split on sentences instead
  if (parts.length <= 1) {
    parts = text
      .split(/(?<=[.!?])\s+(?=[A-Z])/)  // Split after sentence-ending punctuation
      .map(s => s.trim())
      .filter(Boolean);
  }

  return parts
    .map(s =>
      s
        .replace(/^\d+[.)]\s*/, '')                           // Strip leading numbers
        .replace(/^[-*•]\s*/, '')                             // Strip bullet symbols
        .replace(/^(fix|step|suggestion)[:\s]*/i, '')         // Strip labels
        .replace(/\*\*(.*?)\*\*/g, '$1')                      // Remove bold
        .trim()
    )
    .filter(s => s.length > 4);  // Drop fragments that are too short to be useful
};

/**
 * Parses the raw AI text response into a structured { explanation, steps } object.
 * Strategy:
 *  1. Try to find explicit "Explanation" and "Fix/Suggestion" sections.
 *  2. Try numbered sections (1. ... 2. ...).
 *  3. Fall back: treat everything as explanation with a generic step.
 * @param {string} text
 * @returns {{ explanation: string, steps: string[] }}
 */
const parseAIResponse = (text) => {
  let explanationRaw = '';
  let fixRaw = '';

  // ── Strategy 1: Explicit labelled sections ─────────────────────────────────
  const explicitExplanation = text.match(
    /(?:explanation|technical\s+explanation)[:\s-]*([\s\S]*?)(?=fix[:\s]|suggestion[:\s]|$)/i
  );
  const explicitFix = text.match(
    /(?:fix|suggestion|fix\s+suggestion)[:\s-]*([\s\S]*?)$/i
  );

  if (explicitExplanation) {
    explanationRaw = explicitExplanation[1];
    fixRaw = explicitFix ? explicitFix[1] : '';
  } else {
    // ── Strategy 2: Numbered sections (1. explanation  2. fix) ───────────────
    const num1 = text.match(/(?:^|\n)\s*1[.)]\s*([\s\S]*?)(?=\n\s*2[.)]|$)/);
    const num2 = text.match(/\n\s*2[.)]\s*([\s\S]*?)(?=\n\s*3[.)]|$)/);

    if (num1) {
      explanationRaw = num1[1];
      fixRaw = num2 ? num2[1] : '';
    } else {
      // ── Strategy 3: Split on blank line ──────────────────────────────────
      const paragraphs = text.split(/\n{2,}/).filter(Boolean);
      explanationRaw = paragraphs[0] || text;
      fixRaw = paragraphs.slice(1).join(' ');
    }
  }

  const explanation = cleanText(explanationRaw) || cleanText(text);
  const steps = fixRaw
    ? extractSteps(fixRaw)
    : extractSteps(text).slice(1); // skip first sentence (used as explanation)

  return {
    explanation,
    steps: steps.length > 0 ? steps : ['Review the flagged element and adjust manually.'],
  };
};

/**
 * Calls the Groq API and returns a structured AI suggestion.
 * Throws an error if the call fails (no silent fallback).
 * @param {Object} issue - Validation issue object (must have .message)
 * @returns {Promise<Object>} - Structured suggestion
 */
const getAISuggestion = async (issue) => {
  if (!issue || !issue.message) {
    throw new Error('Issue object with a "message" field is required.');
  }

  const prompt = buildPrompt(issue);

  let response;
  try {
    response = await axios.post(
      process.env.AI_API_URL,
      {
        model: process.env.AI_MODEL || 'moonshotai/kimi-k2-instruct-0905',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.6,
        max_tokens: parseInt(process.env.AI_MAX_TOKENS) || 512,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.AI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        timeout: 20000,
      }
    );
  } catch (err) {
    const detail = err.response?.data?.error?.message || err.message;
    throw new Error(`AI API call failed: ${detail}`);
  }

  const rawText = response.data?.choices?.[0]?.message?.content;
  if (!rawText) {
    throw new Error('AI API returned an empty response.');
  }

  const { explanation, steps } = parseAIResponse(rawText);

  return {
    explanation,
    steps,
    confidence: 0.85,
    source: 'real-ai',
    generatedAt: new Date().toISOString(),
  };
};

/**
 * Enriches a list of issues with real AI suggestions (parallel calls).
 * Issues that fail AI enrichment are returned with an error note.
 * @param {Array} issues
 * @returns {Promise<Array>}
 */
const enrichIssuesWithAI = async (issues) => {
  return Promise.all(
    issues.map(async (issue) => {
      try {
        const aiSuggestion = await getAISuggestion(issue);
        return { ...issue, aiSuggestion };
      } catch (err) {
        return { ...issue, aiSuggestion: { error: err.message, source: 'real-ai' } };
      }
    })
  );
};

module.exports = { getAISuggestion, enrichIssuesWithAI };
