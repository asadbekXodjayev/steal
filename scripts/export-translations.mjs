#!/usr/bin/env node
/**
 * Export the PocketBase `exercise_translations` collection to a bundled JSON
 * file shipped inside both apps. PocketBase stays the editable master; this
 * bundle is the RUNTIME source so:
 *   • the Flutter app works fully offline, and
 *   • logged-out / guest users get ru/uz too (the live PB read is gated on auth).
 *
 * Run after seeding:
 *   node --env-file=.env.local scripts/export-translations.mjs
 *
 * Output shape (array fields stay newline-joined, exactly as stored in PB — the
 * web `splitLines` and Flutter `fromRecord` overlays already split on "\n"):
 *   {
 *     "en": { "<exerciseExtId>": { exerciseExtId, locale, name, overview, … } },
 *     "ru": { … },
 *     "uz": { … }
 *   }
 */

import PocketBase from "pocketbase";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const PB_URL   = process.env.POCKETBASE_URL || process.env.NEXT_PUBLIC_API_URL || "http://127.0.0.1:8090";
const PB_EMAIL = process.env.POCKETBASE_ADMIN_EMAIL;
const PB_PASS  = process.env.POCKETBASE_ADMIN_PASSWORD;

if (!PB_EMAIL || !PB_PASS) {
  console.error("Missing required env: POCKETBASE_ADMIN_EMAIL / POCKETBASE_ADMIN_PASSWORD");
  process.exit(1);
}

const LOCALES = ["en", "ru", "uz"];

// Fields copied into the bundle. Array fields are newline-joined strings in PB;
// keep them verbatim so the existing client overlays work unchanged.
const FIELDS = [
  "exerciseExtId", "locale", "name", "overview", "description",
  "instructions", "exerciseTips", "variations", "secondaryMuscles",
  "bodyPart", "equipment", "muscleGroup", "target", "category", "difficulty",
];

const OUTPUTS = [
  "public/exercise-translations.json",            // web — fetched at runtime (guest-accessible)
  "steel_flutter/assets/exercise-translations.json", // Flutter — bundled asset (offline)
];

const pb = new PocketBase(PB_URL);
try {
  await pb.collection("_superusers").authWithPassword(PB_EMAIL, PB_PASS);
  console.log(`✓ PocketBase authed (${PB_URL})`);
} catch (err) {
  console.error("✗ PocketBase auth failed:", err.message);
  process.exit(1);
}

const bundle = { en: {}, ru: {}, uz: {} };

for (const locale of LOCALES) {
  const records = await pb.collection("exercise_translations").getFullList({
    filter: `locale="${locale}"`,
    batch: 500,
  });
  for (const r of records) {
    if (!r.exerciseExtId) continue;
    const entry = {};
    for (const f of FIELDS) {
      const v = r[f];
      if (v !== undefined && v !== null && v !== "") entry[f] = v;
    }
    bundle[locale][r.exerciseExtId] = entry;
  }
  console.log(`  ${locale}: ${Object.keys(bundle[locale]).length} entries`);
}

const json = JSON.stringify(bundle);
for (const out of OUTPUTS) {
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, json);
  console.log(`✓ wrote ${out} (${(json.length / 1024).toFixed(0)} KB)`);
}

console.log("\n✓ Export complete.");
