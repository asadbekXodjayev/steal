#!/usr/bin/env node
/**
 * generate-translations.mjs
 *
 * Build exercise-translations.json directly from src/data/exercises.json.
 * No PocketBase involved — the bundle IS the runtime source of truth.
 *
 * Two passes:
 *   1. EN enrichment  — fill overview, tips, variations, difficulty (all 1 300+ are empty)
 *   2. RU + UZ        — full translation of the now-complete English source (run in parallel)
 *
 * All available AI providers run as parallel workers per locale, each pulling
 * batches from a shared queue. Fully resumable via .translate-progress.json.
 *
 * Usage:
 *   node --env-file=.env.local scripts/generate-translations.mjs
 *
 * Env overrides:
 *   LIMIT=50          only process first N exercises (smoke test)
 *   LOCALES=ru        comma-separated (default: ru,uz)
 *   GENERATE_EN=0     skip English enrichment pass
 *   DELAY_MS=2000     override inter-batch delay for ALL providers
 */

import { generateObject, generateText } from "ai";
import { createGroq }   from "@ai-sdk/groq";
import { google }       from "@ai-sdk/google";
import { anthropic }    from "@ai-sdk/anthropic";
import { createOpenAI } from "@ai-sdk/openai";
import { z } from "zod";
import {
  readFileSync, writeFileSync, existsSync, mkdirSync,
} from "node:fs";
import { dirname } from "node:path";

// ── Config ────────────────────────────────────────────────────────────────────
const LIMIT          = process.env.LIMIT ? Number(process.env.LIMIT) : Infinity;
const LOCALES        = (process.env.LOCALES || "ru,uz").split(",").map(s => s.trim()).filter(Boolean);
const DELAY_OVERRIDE = process.env.DELAY_MS ? Number(process.env.DELAY_MS) : null;

const EXERCISES_FILE = "src/data/exercises.json";
const PROGRESS_FILE  = ".translate-progress.json";
const OUTPUT_PATHS   = [
  "public/exercise-translations.json",
  "steel_flutter/assets/exercise-translations.json",
];

// ── Provider detection ────────────────────────────────────────────────────────
const GEMINI_KEY      = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
const GROQ_KEY        = process.env.GROQ_API_KEY;
const GROQ_RU_KEY     = process.env.GROQ_API_KEY_RU;
const GROQ_UZ_KEY     = process.env.GROQ_API_KEY_UZ;
const CEREBRAS_KEY    = process.env.CEREBRAS_API_KEY;
const CEREBRAS_RU_KEY = process.env.CEREBRAS_API_KEY_RU;
const CEREBRAS_UZ_KEY = process.env.CEREBRAS_API_KEY_UZ;
const ANTHRO_KEY      = process.env.ANTHROPIC_API_KEY;
const OPENAI_KEY      = process.env.OPENAI_API_KEY;

if (GEMINI_KEY && !process.env.GOOGLE_GENERATIVE_AI_API_KEY) {
  process.env.GOOGLE_GENERATIVE_AI_API_KEY = GEMINI_KEY;
}

function d(ms) { return DELAY_OVERRIDE ?? ms; }
function mkP(cfg) { return { lastCall: 0, modelIdx: 0, ...cfg }; }

// ── Model rotation pools ────────────────────────────────────────────────────────
// Each provider key has a SEPARATE daily limit per model. When the current model
// hits its quota, advanceModel() switches the same key to the next model (fresh
// quota) instead of killing the worker. Env override (AI_MODEL/GROQ_MODEL/
// GEMINI_MODEL) is tried first, then the rest as fallbacks. Deduped.
const CEREBRAS_MODELS = [...new Set([
  process.env.AI_MODEL ?? "gpt-oss-120b",
  "zai-glm-4.7",
])];
const GROQ_MODELS = [...new Set([
  process.env.GROQ_MODEL ?? "llama-3.1-8b-instant",
  "llama-3.3-70b-versatile",
  "meta-llama/llama-4-scout-17b-16e-instruct",
  "qwen/qwen3-32b", "qwen/qwen3.6-27b",
  "openai/gpt-oss-20b", "openai/gpt-oss-120b",
])];
const GEMINI_MODELS = [...new Set([
  process.env.GEMINI_MODEL ?? "gemini-2.0-flash",
  "gemini-2.5-flash", "gemini-2.5-flash-lite",
  "gemini-2.0-flash-lite", "gemini-1.5-flash", "gemini-1.5-flash-8b",
])];

const currentModel = (p) => p.models[p.modelIdx];
function advanceModel(p) {
  if (p.modelIdx < p.models.length - 1) { p.modelIdx++; return true; }
  return false;
}

// Build provider objects for every key that's present.
const P = {
  // The dedicated locale keys also help the OTHER locale — once their own
  // locale is complete they bring leftover daily quota to whatever's left.
  cerebrasRu: CEREBRAS_RU_KEY && mkP({
    name: "cerebras-ru", pool: ["ru", "uz"],
    batchSize: 20, delayMs: d(2000), maxTokens: 16000,
    cerebrasApiKey: CEREBRAS_RU_KEY,
    models: CEREBRAS_MODELS,
  }),
  cerebrasUz: CEREBRAS_UZ_KEY && mkP({
    name: "cerebras-uz", pool: ["uz", "ru"],
    batchSize: 20, delayMs: d(2000), maxTokens: 16000,
    cerebrasApiKey: CEREBRAS_UZ_KEY,
    models: CEREBRAS_MODELS,
  }),
  cerebras: CEREBRAS_KEY && mkP({
    name: "cerebras", pool: ["en", "ru", "uz"],
    batchSize: 20, delayMs: d(2000), maxTokens: 16000,
    cerebrasApiKey: CEREBRAS_KEY,
    models: CEREBRAS_MODELS,
  }),
  groqRu: GROQ_RU_KEY && mkP({
    name: "groq-ru", pool: ["ru", "uz"],
    batchSize: 5, delayMs: d(3000), maxTokens: 8000, useTextMode: true,
    groqApiKey: GROQ_RU_KEY,
    models: GROQ_MODELS,
  }),
  groqUz: GROQ_UZ_KEY && mkP({
    name: "groq-uz", pool: ["uz", "ru"],
    batchSize: 5, delayMs: d(3000), maxTokens: 8000, useTextMode: true,
    groqApiKey: GROQ_UZ_KEY,
    models: GROQ_MODELS,
  }),
  groq: GROQ_KEY && mkP({
    name: "groq", pool: ["en", "ru", "uz"],
    batchSize: 5, delayMs: d(3000), maxTokens: 8000, useTextMode: true,
    groqApiKey: GROQ_KEY,
    models: GROQ_MODELS,
  }),
  gemini: GEMINI_KEY && mkP({
    name: "gemini", pool: ["en", "ru", "uz"],
    batchSize: 20, delayMs: d(3000),
    models: GEMINI_MODELS,
  }),
  anthropic: ANTHRO_KEY && mkP({
    name: "anthropic", pool: ["en", "ru", "uz"],
    batchSize: 20, delayMs: d(2000),
    models: ["claude-haiku-4-5-20251001"],
  }),
  openai: OPENAI_KEY && mkP({
    name: "openai", pool: ["en", "ru", "uz"],
    batchSize: 20, delayMs: d(2000),
    models: ["gpt-4o-mini"],
  }),
};

// Filter to only providers where the key exists, then build per-phase pools.
// Priority: dedicated locale-specific providers first (separate rate-limit pools),
// then shared ones as additional workers / fallbacks.
const providers = Object.values(P).filter(Boolean);

function poolFor(locale) {
  // Dedicated first, then shared — larger batchSize naturally handles more work.
  return [
    ...providers.filter(p => p.pool.includes(locale) && !p.pool.includes("en")), // dedicated
    ...providers.filter(p => p.pool.includes("en") && p.pool.includes(locale)),  // shared
  ];
}

const EN_POOL = providers.filter(p => p.pool.includes("en"));
const RU_POOL = poolFor("ru");
const UZ_POOL = poolFor("uz");

if (!EN_POOL.length) {
  console.error("No AI keys found. Set at least CEREBRAS_API_KEY, GEMINI_API_KEY, or GROQ_API_KEY.");
  process.exit(1);
}
console.log("→ Providers loaded:");
console.log("  EN:", EN_POOL.map(p => `${p.name}(b=${p.batchSize},m=${p.models.length})`).join(" | "));
console.log("  RU:", RU_POOL.map(p => p.name).join(" | ") || "(none — will use EN pool)");
console.log("  UZ:", UZ_POOL.map(p => p.name).join(" | ") || "(none — will use EN pool)");
console.log("  Model rotation: cerebras", CEREBRAS_MODELS.join("→"));
console.log("                  groq    ", GROQ_MODELS.join("→"));
console.log("                  gemini  ", GEMINI_MODELS.join("→"));

// ── Zod schema ────────────────────────────────────────────────────────────────
// Normalise AI output that might return arrays or strings for the same field.
const toStr = z.union([
  z.string(),
  z.array(z.string()).transform(a => a.join(", ")),
]).default("");

const toArr = z.union([
  z.array(z.string()),
  z.string().transform(s => s.split(/\n/).map(x => x.trim()).filter(Boolean)),
]).default([]);

const itemSchema = z.object({
  exerciseExtId:    z.string(),
  name:             z.string().default(""),
  overview:         z.string().default(""),
  bodyPart:         toStr,
  equipment:        toStr,
  muscleGroup:      toStr,
  target:           toStr,
  category:         z.string().default(""),
  difficulty:       z.string().default(""),
  secondaryMuscles: toArr,
  instructions:     toArr,
  exerciseTips:     toArr,
  variations:       toArr,
});
const responseSchema = z.object({ translations: z.array(itemSchema) });

// ── Exercises ─────────────────────────────────────────────────────────────────
const rawExercises = JSON.parse(readFileSync(EXERCISES_FILE, "utf8"));
const exercises = rawExercises.slice(0, Number.isFinite(LIMIT) ? LIMIT : rawExercises.length);
console.log(`→ Loaded ${exercises.length} exercises`);

// Build the payload we send to the AI for each exercise.
function toSourcePayload(e) {
  return {
    exerciseExtId:    e.id,
    name:             e.name              ?? "",
    overview:         e.overview           ?? "",
    bodyPart:         e.bodyPart           ?? "",
    equipment:        e.equipment          ?? "",
    muscleGroup:      e.muscleGroup        ?? "",
    target:           e.target             ?? "",
    category:         e.category           ?? "",
    difficulty:       e.difficulty          ?? "",
    secondaryMuscles: e.secondaryMuscles   ?? [],
    instructions:     e.steps              ?? [],  // exercises.json uses `steps` (array)
    exerciseTips:     e.exerciseTips        ?? [],
    variations:       e.variations          ?? [],
  };
}

// Convert a validated AI result item to the bundle row format.
// Array fields (instructions, tips, variations, secondaryMuscles) are stored as
// "\n"-joined strings — consistent with how the web splitLines() and Flutter
// splitLines() consumers read them.
function toRow(t, locale) {
  return {
    exerciseExtId:    t.exerciseExtId,
    locale,
    name:             t.name,
    overview:         t.overview,
    bodyPart:         t.bodyPart,         // already a string (Zod toStr)
    equipment:        t.equipment,
    muscleGroup:      t.muscleGroup,
    target:           t.target,
    category:         t.category,
    difficulty:       t.difficulty,
    secondaryMuscles: t.secondaryMuscles.join("\n"),
    instructions:     t.instructions.join("\n"),
    exerciseTips:     t.exerciseTips.join("\n"),
    variations:       t.variations.join("\n"),
  };
}

// ── Bundle ────────────────────────────────────────────────────────────────────
const bundle = { en: {}, ru: {}, uz: {} };

// Resume: load any existing bundle data.
try {
  const existing = JSON.parse(readFileSync(OUTPUT_PATHS[0], "utf8"));
  Object.assign(bundle.en,  existing.en  ?? {});
  Object.assign(bundle.ru,  existing.ru  ?? {});
  Object.assign(bundle.uz,  existing.uz  ?? {});
  const counts = [bundle.en, bundle.ru, bundle.uz].map(m => Object.keys(m).length);
  if (counts.some(n => n > 0)) {
    console.log(`→ Resuming from existing bundle (en=${counts[0]}, ru=${counts[1]}, uz=${counts[2]})`);
  }
} catch { /* fresh start */ }

function saveBundle() {
  const json = JSON.stringify(bundle, null, 2);
  for (const p of OUTPUT_PATHS) {
    mkdirSync(dirname(p), { recursive: true });
    writeFileSync(p, json);
  }
}

// ── Checkpoint ────────────────────────────────────────────────────────────────
let progress = existsSync(PROGRESS_FILE)
  ? JSON.parse(readFileSync(PROGRESS_FILE, "utf8"))
  : { done: {} };

function saveProgress() {
  writeFileSync(PROGRESS_FILE, JSON.stringify(progress, null, 2));
}

// ── AI infrastructure ─────────────────────────────────────────────────────────
function extractFirstJSON(text) {
  const s = text
    .replace(/<think>[\s\S]*?<\/think>/gi, "")
    .replace(/```(?:json)?\s*/gi, "")
    .replace(/```/g, "");
  const oi = s.indexOf("{"), ai = s.indexOf("[");
  const start = oi === -1 ? ai : ai === -1 ? oi : Math.min(oi, ai);
  if (start === -1) throw new Error("No JSON in response");
  const open = s[start], close = open === "{" ? "}" : "]";
  let depth = 0, inStr = false, esc = false;
  for (let i = start; i < s.length; i++) {
    const c = s[i];
    if (esc)        { esc = false; continue; }
    if (c === "\\") { esc = true;  continue; }
    if (c === '"')  { inStr = !inStr; continue; }
    if (inStr)      continue;
    if (c === open)  depth++;
    else if (c === close) { depth--; if (depth === 0) return s.slice(start, i + 1); }
  }
  throw new Error("Unbalanced JSON in response");
}

function parseItems(raw) {
  const arr = Array.isArray(raw)           ? raw
    : Array.isArray(raw?.translations)     ? raw.translations
    : Array.isArray(raw?.data)             ? raw.data
    : Object.values(raw ?? {}).find(Array.isArray);
  if (!arr) throw new Error("No array in AI response");
  return z.array(itemSchema).parse(arr);
}

function buildSdkModel(p) {
  const m = currentModel(p);
  if (p.name.startsWith("groq"))  return createGroq({ apiKey: p.groqApiKey })(m);
  if (p.name === "gemini")        return google(m);
  if (p.name === "anthropic")     return anthropic(m);
  if (p.name === "openai")        return createOpenAI({ apiKey: OPENAI_KEY })(m);
  throw new Error(`Unknown provider for SDK: ${p.name}`);
}

async function cerebrasChat(p, system, prompt) {
  const res = await fetch("https://api.cerebras.ai/v1/chat/completions", {
    method:  "POST",
    headers: { "Authorization": `Bearer ${p.cerebrasApiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model:      currentModel(p),
      messages:   [{ role: "system", content: system }, { role: "user", content: prompt }],
      max_tokens: p.maxTokens ?? 16000,
    }),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => res.statusText);
    throw new Error(`Cerebras ${res.status}: ${body.slice(0, 300)}`);
  }
  return (await res.json()).choices[0].message.content;
}

async function callProvider(p, system, prompt) {
  if (p.name.startsWith("cerebras")) {
    const text = await cerebrasChat(p, system, prompt);
    return parseItems(JSON.parse(extractFirstJSON(text)));
  }
  if (p.useTextMode) {
    const { text } = await generateText({ model: buildSdkModel(p), maxTokens: p.maxTokens, system, prompt });
    return parseItems(JSON.parse(extractFirstJSON(text)));
  }
  const { object } = await generateObject({ model: buildSdkModel(p), schema: responseSchema, system, prompt });
  return object.translations;
}

// Per-provider serial queue: serialises calls and enforces delayMs between them
// so we never fire two requests to the same account concurrently.
const pQueues = new WeakMap();
function queued(p, fn) {
  if (!pQueues.has(p)) pQueues.set(p, Promise.resolve());
  const next = pQueues.get(p).then(async () => {
    const wait = p.delayMs - (Date.now() - p.lastCall);
    if (wait > 0) await new Promise(r => setTimeout(r, wait));
    p.lastCall = Date.now();
    return fn();
  });
  // Keep the chain alive even if this call errors (so the next call still runs).
  pQueues.set(p, next.catch(() => {}));
  return next;
}

// ── System prompts ────────────────────────────────────────────────────────────
const PROMPTS = {

ru: `Ты — профессиональный переводчик фитнес-контента с английского на русский язык. Используй живой, профессиональный язык фитнес-индустрии, понятный посетителям спортивных залов.

═══ АБСОЛЮТНЫЕ ПРАВИЛА ═══
• Отвечай СТРОГО JSON-массивом — ни markdown, ни тройные апострофы, ни объяснений, ни слов до или после JSON.
• Переводи КАЖДОЕ поле для КАЖДОГО упражнения без исключения.
• Если поле пустое в оригинале — оставь пустую строку или пустой массив.
• Сохраняй РОВНО столько элементов в массивах, сколько в оригинале.
• НЕ пропускай ни одно упражнение из входного списка.

═══ КАК ПЕРЕВОДИТЬ КАЖДОЕ ПОЛЕ ═══
name             → Официальное русское название: «Жим штанги лёжа», «Подтягивания», «Приседания со штангой».
overview         → Краткое описание (2–4 предложения): что тренирует и для кого подходит.
bodyPart         → Часть тела строкой: «грудь», «спина», «ноги», «плечи», «руки», «пресс», «ягодицы».
equipment        → Оборудование строкой: «штанга», «гантели», «гиря», «тренажёр», «эспандер», «вес тела».
target           → Целевые мышцы строкой: «большая грудная», «широчайшая мышца спины», «квадрицепс».
muscleGroup      → Группа мышц строкой.
category         → «силовые», «кардио», «гибкость», «функциональные» или «изометрические».
difficulty       → «начинающий», «средний уровень» или «продвинутый».
secondaryMuscles → Массив вторичных мышц. Каждая — отдельная строка.
instructions     → Массив шагов. Каждый — отдельная строка. Формат: «Шаг 1: ...», «Шаг 2: ...».
exerciseTips     → Массив практических советов и предостережений. Каждый — отдельная строка.
variations       → Массив вариантов/модификаций упражнения. Каждый — отдельная строка.

═══ ФОРМАТ ОТВЕТА ═══
[
  {
    "exerciseExtId": "...", "name": "...", "overview": "...",
    "bodyPart": "...", "equipment": "...", "target": "...", "muscleGroup": "...",
    "category": "...", "difficulty": "...",
    "secondaryMuscles": ["..."], "instructions": ["Шаг 1: ..."],
    "exerciseTips": ["..."], "variations": ["..."]
  }
]`,

uz: `Siz ingliz tilidan o'zbek tiliga (lotin yozuvi) fitness kontentini tarjima qiluvchi professional tarjimonasiz. Sport zallariga qatnaydiganlar uchun tushunarli, jonli va professional til ishlating.

═══ MUTLAQ QOIDALAR ═══
• FAQAT JSON massiv bilan javob bering — markdown yo'q, uchta tirnoq yo'q, JSON dan oldin yoki keyin hech qanday matn yo'q.
• Har bir mashq uchun BARCHA maydonlarni tarjima qiling, istisnosiz.
• Agar asl nusxada maydon bo'sh bo'lsa — bo'sh satr yoki bo'sh massiv qoldiring.
• Massivlardagi elementlar sonini asl nusxadagidek SAQLANG.
• Kiritilgan ro'yxatdagi birorta mashqni o'tkazib yubormang.

═══ HAR BIR MAYDONNI QANDAY TARJIMA QILISH ═══
name             → Rasmiy o'zbek nomi: «Yotib shtanga ko'tarish», «Turnikda tortilish», «Shtanga bilan o'tirish».
overview         → Qisqacha tavsif (2–4 jumla): nima rivojlantiradi va kimlar uchun mos.
bodyPart         → Tana qismi satr bilan: «ko'krak», «orqa», «oyoqlar», «yelkalar», «qo'llar», «qorin», «dumba».
equipment        → Jihozlar satr bilan: «shtanga», «hantellar», «girya», «trenajer», «rezina», «o'z tana og'irligi».
target           → Asosiy mushaklar satr bilan: «katta ko'krak mushagi», «keng orqa mushagi», «to'rt boshli mushak».
muscleGroup      → Mushak guruhilari satr bilan.
category         → «kuch», «kardio», «egiluvchanlik», «funksional» yoki «izometrik».
difficulty       → «boshlang'ich», «o'rta daraja» yoki «yuqori daraja».
secondaryMuscles → Ikkinchi darajali mushaklar massivi. Har biri alohida satr.
instructions     → Qadamlar massivi. Har biri alohida satr. Format: «1-qadam: ...», «2-qadam: ...».
exerciseTips     → Maslahatlar massivi. Har biri alohida satr.
variations       → Variantlar massivi. Har biri alohida satr.

═══ JAVOB FORMATI ═══
[
  {
    "exerciseExtId": "...", "name": "...", "overview": "...",
    "bodyPart": "...", "equipment": "...", "target": "...", "muscleGroup": "...",
    "category": "...", "difficulty": "...",
    "secondaryMuscles": ["..."], "instructions": ["1-qadam: ..."],
    "exerciseTips": ["..."], "variations": ["..."]
  }
]`,

en: `You are a professional strength & conditioning content writer. You receive exercises where SOME fields are EMPTY. Your job is to fill ONLY the empty fields with accurate, concise English content inferred from the exercise name, muscles, equipment, and body part.

═══ ABSOLUTE RULES ═══
• Respond with ONLY a JSON array — no markdown, no code fences, no text before or after the JSON.
• Return EVERY exercise from the input, matched by exerciseExtId.
• For fields that ALREADY have content, return them UNCHANGED.
• For empty fields, generate appropriate English content.

═══ HOW TO FILL EACH EMPTY FIELD ═══
overview         → 2–4 sentences: what the exercise trains and who it suits.
difficulty       → One of: "beginner", "intermediate", "advanced".
exerciseTips     → Array of 2–4 practical form tips / common-mistake warnings.
variations       → Array of 1–3 common variations or modifications.
secondaryMuscles → Array of secondary muscles, inferred from the movement (only if empty).
instructions     → ONLY if empty: 3–5 safe, generic setup/execution cues. If already present, return unchanged.

═══ RESPONSE FORMAT ═══
[
  {
    "exerciseExtId": "...", "name": "...", "overview": "...",
    "bodyPart": "...", "equipment": "...", "target": "...", "muscleGroup": "...",
    "category": "...", "difficulty": "...",
    "secondaryMuscles": ["..."], "instructions": ["..."],
    "exerciseTips": ["..."], "variations": ["..."]
  }
]`,
};

// ── Worker queue ──────────────────────────────────────────────────────────────
function isQuota(err) {
  return /rate.?limit|quota|429|tokens.*day|daily.*quota|exceeded.*quota|per.*day/i.test(err.message);
}

// 404 "model does not exist" / decommissioned — the current MODEL is unusable;
// advanceModel() rotates to the next one (rather than looping retries forever).
function isDeadProvider(err) {
  return /404|does not exist|no such model|model.*not.*found|decommission|no longer supported|not supported|deprecated/i.test(err.message);
}

/**
 * Run a pool of provider workers against a shared queue of exercises for one locale.
 * Workers run truly in parallel; each pulls batches from the shared queue until
 * empty or its quota is exhausted.
 *
 * onBatch(items, locale, sourceBatch) is called after each successful batch.
 */
async function runPool(locale, pool, pending, systemPrompt, buildPrompt, onBatch) {
  if (!pool.length) { console.warn(`  ⚠ No providers for ${locale}`); return; }
  if (!pending.length) return;

  const queue = [...pending]; // shared mutable queue (splice is atomic in single-threaded JS)
  let done = 0;
  const total = pending.length;

  async function worker(provider) {
    while (true) {
      // Atomically claim a batch from the front of the queue.
      const batch = queue.splice(0, provider.batchSize);
      if (!batch.length) return; // queue drained

      const tag = `[${provider.name}→${locale.toUpperCase()}]`;
      process.stdout.write(`  ${tag} ${done + 1}–${done + batch.length}/${total} … `);

      const run = () => callProvider(provider, systemPrompt, buildPrompt(batch, locale));

      let items;
      try {
        items = await queued(provider, run);
        done += batch.length;
        console.log(`✓ (${items.length})`);
      } catch (err) {
        if (isQuota(err) || isDeadProvider(err)) {
          // Daily limit (or dead model) on the current model: switch this key to
          // its next model (fresh per-model quota) and keep going. Only stop the
          // worker once ALL of the provider's models are exhausted.
          const why = isDeadProvider(err) ? "DEAD" : "QUOTA";
          const spent = currentModel(provider);
          queue.unshift(...batch); // requeue the unprocessed batch
          if (advanceModel(provider)) {
            console.log(`${why} (${spent}) — switching model → ${currentModel(provider)}`);
            continue; // retry same work on the fresh model
          }
          console.log(`${why} (${spent}) — all ${provider.models.length} models exhausted, stopping worker`);
          return;
        }
        // Transient error — retry once.
        console.log(`ERR: ${err.message.slice(0, 60)} — retrying 5s`);
        await new Promise(r => setTimeout(r, 5000));
        try {
          items = await queued(provider, run);
          done += batch.length;
          console.log(`  ${tag} retry ✓`);
        } catch (err2) {
          if (isQuota(err2) || isDeadProvider(err2)) {
            const why2 = isDeadProvider(err2) ? "DEAD" : "QUOTA";
            const spent2 = currentModel(provider);
            queue.unshift(...batch);
            if (advanceModel(provider)) {
              console.log(`  ${tag} ${why2} (${spent2}) — switching model → ${currentModel(provider)}`);
              continue;
            }
            console.log(`  ${tag} ${why2} (${spent2}) — all models exhausted, stopping worker`);
            return;
          }
          console.error(`  ${tag} retry failed — skipping: ${err2.message.slice(0, 80)}`);
          continue; // batch lost this run; checkpoint catches on re-run
        }
      }

      await onBatch(items, locale, batch);
    }
  }

  await Promise.all(pool.map(worker));

  if (queue.length > 0) {
    console.warn(`\n  ⚠ ${queue.length} exercises still pending for ${locale} — all provider quotas exhausted.`);
    console.warn(`  Re-run the script tomorrow to continue.`);
  }
}

// ── Phase 1: English enrichment ───────────────────────────────────────────────
async function enrichEnglish() {
  progress.done.en ||= {};
  const pending = exercises.filter(e => !progress.done.en[e.id]);
  if (!pending.length) { console.log("✓ EN enrichment already complete"); return; }

  console.log(`\n──── EN enrichment: ${pending.length} exercises ────`);

  await runPool(
    "en",
    EN_POOL,
    pending,
    PROMPTS.en,
    (batch) =>
      `Fill the empty fields for these ${batch.length} exercises. ` +
      `Return every exercise in a JSON array.\n\n` +
      JSON.stringify(batch.map(toSourcePayload), null, 0),
    async (items, _locale, batch) => {
      const byId = new Map(items.map(t => [t.exerciseExtId, t]));
      let saved = 0;
      for (const e of batch) {
        const t = byId.get(e.id);
        if (!t) { progress.done.en[e.id] = true; continue; }

        // Sparse EN row — only the GENERATED fields (fields already in exercises.json stay there).
        const row = { exerciseExtId: e.id, locale: "en" };
        if (t.overview   && !e.overview)    { row.overview   = t.overview;   e.overview   = t.overview;   }
        if (t.difficulty && !e.difficulty)  { row.difficulty = t.difficulty; e.difficulty = t.difficulty; }
        if (t.exerciseTips.length  && !(e.exerciseTips  || []).length) {
          row.exerciseTips  = t.exerciseTips.join("\n");  e.exerciseTips  = t.exerciseTips;
        }
        if (t.variations.length    && !(e.variations    || []).length) {
          row.variations    = t.variations.join("\n");    e.variations    = t.variations;
        }
        if (t.secondaryMuscles.length && !(e.secondaryMuscles || []).length) {
          row.secondaryMuscles = t.secondaryMuscles.join("\n"); e.secondaryMuscles = t.secondaryMuscles;
        }

        if (Object.keys(row).length > 2) {
          bundle.en[e.id] = row;
          saved++;
        }
        progress.done.en[e.id] = true;
      }
      saveProgress();
      saveBundle();
      if (saved) console.log(`    → EN saved ${saved} enriched rows`);
    },
  );

  console.log(`\n✓ EN enrichment done  (${Object.keys(bundle.en).length} rows in bundle)`);
}

// ── Phase 2: Translation (ru / uz) ────────────────────────────────────────────
async function translateLocale(locale, pool) {
  progress.done[locale] ||= {};
  const pending = exercises.filter(e => !progress.done[locale][e.id]);
  if (!pending.length) { console.log(`✓ ${locale.toUpperCase()} already complete`); return; }

  const locName = { ru: "Russian", uz: "Uzbek" }[locale] ?? locale;
  console.log(`\n──── ${locale.toUpperCase()} (${locName}): ${pending.length} exercises ────`);

  await runPool(
    locale,
    pool,
    pending,
    PROMPTS[locale],
    (batch, loc) =>
      `Translate the following ${batch.length} exercises into ${locName}. ` +
      `Translate EVERY text field. Return a JSON array.\n\n` +
      JSON.stringify(batch.map(toSourcePayload), null, 0),
    async (items, loc, batch) => {
      const byId = new Map(items.map(t => [t.exerciseExtId, t]));
      let saved = 0;
      for (const e of batch) {
        const t = byId.get(e.id);
        // If the model omitted this exercise from its response, leave it
        // PENDING (don't mark done) so a later run / rotated model retries it —
        // otherwise it's silently lost forever.
        if (!t) continue;
        bundle[loc][e.id] = toRow(t, loc);
        progress.done[loc][e.id] = true;
        saved++;
      }
      saveProgress();
      saveBundle();
    },
  );

  console.log(`\n✓ ${locale.toUpperCase()} done  (${Object.keys(bundle[locale]).length}/${exercises.length})`);
}

// ── Main ──────────────────────────────────────────────────────────────────────
if (process.env.GENERATE_EN !== "0") {
  await enrichEnglish();
}

const toTranslate = LOCALES.filter(l => ["ru", "uz"].includes(l));
if (toTranslate.length) {
  const pools = { ru: RU_POOL, uz: UZ_POOL };
  // RU and UZ run fully in parallel — each locale's dedicated providers are
  // separate accounts with their own rate-limit pools.
  await Promise.all(toTranslate.map(l => translateLocale(l, pools[l])));
}

console.log("\n════════════════════════════════");
console.log("✓ All done.");
console.log(`  EN: ${Object.keys(bundle.en).length}/${exercises.length}`);
console.log(`  RU: ${Object.keys(bundle.ru).length}/${exercises.length}`);
console.log(`  UZ: ${Object.keys(bundle.uz).length}/${exercises.length}`);
console.log(`  → ${OUTPUT_PATHS.join("\n  → ")}`);
