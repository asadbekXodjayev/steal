#!/usr/bin/env node
/**
 * ensure-translations.mjs
 *
 * Called automatically by predev / prebuild npm hooks.
 * Checks whether the translation bundle is complete.
 *   • Complete  → exits immediately (no work, no delay).
 *   • Incomplete + API keys present → runs generate-translations.mjs inline.
 *   • Incomplete + no API keys      → prints a one-line warning and exits 0
 *                                     (non-blocking so dev/build still starts).
 */

import { existsSync, readFileSync } from "node:fs";
import { spawnSync }                from "node:child_process";

const BUNDLE      = "public/exercise-translations.json";
const EXERCISES   = "src/data/exercises.json";
const GENERATE    = "scripts/generate-translations.mjs";
const ENV_FILE    = ".env.local";

// ── Check completeness ────────────────────────────────────────────────────────
function isComplete() {
  if (!existsSync(BUNDLE)) return false;
  try {
    const bundle = JSON.parse(readFileSync(BUNDLE, "utf8"));
    const total  = JSON.parse(readFileSync(EXERCISES, "utf8")).length;
    const ru     = Object.keys(bundle.ru ?? {}).length;
    const uz     = Object.keys(bundle.uz ?? {}).length;
    // Consider complete when both locales cover ≥ 95 % of the catalog.
    return ru >= total * 0.95 && uz >= total * 0.95;
  } catch {
    return false;
  }
}

function coverage() {
  try {
    const bundle = JSON.parse(readFileSync(BUNDLE, "utf8"));
    return {
      ru: Object.keys(bundle.ru ?? {}).length,
      uz: Object.keys(bundle.uz ?? {}).length,
    };
  } catch {
    return { ru: 0, uz: 0 };
  }
}

if (isComplete()) {
  const { ru, uz } = coverage();
  console.log(`✓ exercise-translations: ru=${ru} uz=${uz} — complete, skipping generation`);
  process.exit(0);
}

// Bundle is partial. We deliberately SHIP PARTIAL: missing rows fall back to
// English per-field on both web and Flutter, so dev/build must NOT block on
// (re)generation. Generation is opt-in — finish later with either:
//   • npm run generate:translations            (manual, recommended)
//   • AUTO_TRANSLATE=1 npm run dev | build      (let this gate run the generator)
const AI_KEY_VARS = [
  "CEREBRAS_API_KEY", "CEREBRAS_API_KEY_RU", "CEREBRAS_API_KEY_UZ",
  "GROQ_API_KEY",     "GROQ_API_KEY_RU",     "GROQ_API_KEY_UZ",
  "GEMINI_API_KEY",   "GOOGLE_GENERATIVE_AI_API_KEY",
  "ANTHROPIC_API_KEY", "OPENAI_API_KEY",
];
const hasKey = AI_KEY_VARS.some(k => process.env[k]);
const { ru, uz } = coverage();

if (process.env.AUTO_TRANSLATE === "1" && hasKey) {
  console.log(`→ exercise-translations: partial (ru=${ru} uz=${uz}) — AUTO_TRANSLATE=1, running generator…`);
  const envFileArgs = existsSync(ENV_FILE) ? [`--env-file=${ENV_FILE}`] : [];
  const result = spawnSync(
    process.execPath,
    [...envFileArgs, GENERATE],
    { stdio: "inherit", env: process.env },
  );
  process.exit(result.status ?? 0);
}

console.log(
  `→ exercise-translations: partial (ru=${ru} uz=${uz}) — shipping with English fallback. ` +
  "Run `npm run generate:translations` to finish.",
);
process.exit(0); // non-blocking — dev/build proceeds
