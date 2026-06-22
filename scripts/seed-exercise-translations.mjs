#!/usr/bin/env node
/**
 * Seed the PocketBase `exercise_translations` collection.
 *
 * Parallel mode  — when both GROQ_API_KEY and GEMINI_API_KEY are set,
 *                  locale "ru" and locale "uz" run concurrently on separate
 *                  providers, cutting total wall time roughly in half.
 * Single mode    — falls back to sequential if only one key is present.
 *
 * Usage:
 *   node --env-file=.env.local scripts/seed-exercise-translations.mjs
 *
 * Optional env overrides:
 *   GROQ_MODEL=llama-3.1-8b-instant   (default)
 *   GEMINI_MODEL=gemini-2.5-flash-lite (default)
 *   LIMIT=50      — only first N exercises (smoke test)
 *   LOCALES=ru    — comma-separated locales (default: ru,uz)
 *   DELAY_MS=3000 — override per-batch delay for all providers
 *
 * Fully resumable — .seed-progress.json tracks per-locale completion.
 */

import PocketBase from "pocketbase";
import { generateObject, generateText } from "ai";
import { createGroq } from "@ai-sdk/groq";
import { google } from "@ai-sdk/google";
import { anthropic } from "@ai-sdk/anthropic";
import { createOpenAI } from "@ai-sdk/openai";
import { z } from "zod";
import { readFileSync, writeFileSync, existsSync } from "node:fs";

// ── Environment ────────────────────────────────────────────────────────────────
const PB_URL   = process.env.POCKETBASE_URL || process.env.NEXT_PUBLIC_API_URL || "http://127.0.0.1:8090";
const PB_EMAIL = process.env.POCKETBASE_ADMIN_EMAIL;
const PB_PASS  = process.env.POCKETBASE_ADMIN_PASSWORD;
const EXDB_URL = process.env.NEXT_PUBLIC_EXERCISEDB_URL;
const LIMIT    = process.env.LIMIT ? Number(process.env.LIMIT) : Infinity;
const LOCALES  = (process.env.LOCALES || "ru,uz").split(",").map(s => s.trim()).filter(Boolean);

if (!PB_EMAIL || !PB_PASS || !EXDB_URL) {
  console.error("Missing required env: POCKETBASE_ADMIN_EMAIL / POCKETBASE_ADMIN_PASSWORD / NEXT_PUBLIC_EXERCISEDB_URL");
  process.exit(1);
}

// ── Provider detection ─────────────────────────────────────────────────────────
const GROQ_KEY        = process.env.GROQ_API_KEY;
const GROQ_RU_KEY     = process.env.GROQ_API_KEY_RU;
const GROQ_UZ_KEY     = process.env.GROQ_API_KEY_UZ;
const GEMINI_KEY      = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
const ANTHRO_KEY      = process.env.ANTHROPIC_API_KEY;
const CEREBRAS_KEY    = process.env.CEREBRAS_API_KEY;
const CEREBRAS_UZ_KEY = process.env.CEREBRAS_API_KEY_UZ;
const CEREBRAS_RU_KEY = process.env.CEREBRAS_API_KEY_RU;

if (GEMINI_KEY && !process.env.GOOGLE_GENERATIVE_AI_API_KEY) {
  process.env.GOOGLE_GENERATIVE_AI_API_KEY = GEMINI_KEY;
}

/**
 * Provider descriptor:
 *   useTextMode — Groq doesn't support json_schema; we use generateText + manual parse.
 *   batchSize   — Groq 8B truncates on large batches; keep it at 5.
 *   delayMs     — minimum ms between batches to stay under RPM limit.
 */
const PROVIDERS = [];
if (GROQ_RU_KEY) {
  // Dedicated Groq account for RU — separate rate-limit pool from the UZ account.
  PROVIDERS.push({
    name: "groq-ru",
    model: process.env.GROQ_MODEL ?? "llama-3.1-8b-instant",
    batchSize: 5,
    maxTokens: 8000,
    delayMs: Number(process.env.DELAY_MS ?? 3000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    groqApiKey: GROQ_RU_KEY,
  });
}
if (GROQ_KEY) {
  PROVIDERS.push({
    name: "groq",
    model: process.env.GROQ_MODEL ?? "llama-3.1-8b-instant",
    batchSize: 5,
    maxTokens: 8000,
    delayMs: Number(process.env.DELAY_MS ?? 3000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    groqApiKey: GROQ_KEY,
  });
}
if (GEMINI_KEY) {
  PROVIDERS.push({
    name: "gemini",
    model: process.env.GEMINI_MODEL ?? "gemini-2.5-flash-lite",
    batchSize: 20,
    maxTokens: undefined,
    delayMs: Number(process.env.DELAY_MS ?? 3000),
    lastCall: 0,
    useTextMode: false,
  });
}
if (CEREBRAS_RU_KEY) {
  // Dedicated Cerebras account for RU — separate rate-limit pool from the UZ account.
  PROVIDERS.push({
    name: "cerebras-ru",
    model: process.env.AI_MODEL ?? "qwen-3-235b-a22b-instruct-2507",
    batchSize: 20,
    maxTokens: 16000,
    delayMs: Number(process.env.DELAY_MS ?? 2000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    cerebrasApiKey: CEREBRAS_RU_KEY,
  });
}
if (CEREBRAS_UZ_KEY) {
  // Dedicated Cerebras account for UZ — separate rate-limit pool from the RU account.
  PROVIDERS.push({
    name: "cerebras-uz",
    model: process.env.AI_MODEL ?? "qwen-3-235b-a22b-instruct-2507",
    batchSize: 20,
    maxTokens: 16000,
    delayMs: Number(process.env.DELAY_MS ?? 2000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    cerebrasApiKey: CEREBRAS_UZ_KEY,
  });
}
if (GROQ_UZ_KEY) {
  // Dedicated Groq account for UZ — separate rate-limit pool from the RU account.
  PROVIDERS.push({
    name: "groq-uz",
    model: process.env.GROQ_MODEL ?? "llama-3.1-8b-instant",
    batchSize: 5,
    maxTokens: 8000,
    delayMs: Number(process.env.DELAY_MS ?? 3000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    groqApiKey: GROQ_UZ_KEY,
  });
}
if (CEREBRAS_KEY) {
  PROVIDERS.push({
    name: "cerebras",
    model: process.env.AI_MODEL ?? "qwen-3-235b-a22b-instruct-2507",
    batchSize: 20,
    maxTokens: 16000,
    delayMs: Number(process.env.DELAY_MS ?? 2000),
    lastCall: 0,
    useTextMode: true,
    dailyQuotaSwitch: true,
    cerebrasApiKey: CEREBRAS_KEY,
  });
}
if (!PROVIDERS.length && ANTHRO_KEY) {
  PROVIDERS.push({
    name: "anthropic",
    model: "claude-sonnet-4-6",
    batchSize: 20,
    maxTokens: undefined,
    delayMs: Number(process.env.DELAY_MS ?? 2000),
    lastCall: 0,
    useTextMode: false,
  });
}

if (!PROVIDERS.length) {
  console.error("No AI keys found. Set GROQ_API_KEY and/or GEMINI_API_KEY.");
  process.exit(1);
}

// Put the larger-batch provider first so it handles locale[0] (ru) — better quality.
PROVIDERS.sort((a, b) => b.batchSize - a.batchSize);
console.log(`→ Providers: ${PROVIDERS.map(p => `${p.name}/${p.model} (batch=${p.batchSize})`).join(" | ")}`);

// ── Zod schema ─────────────────────────────────────────────────────────────────
// bodyPart / equipment / target / muscleGroup: normalize to string[] regardless of what the model returns
const strOrArr = z.union([z.string(), z.array(z.string())]).transform(v =>
  Array.isArray(v) ? v : v ? [v] : []
);
const itemSchema = z.object({
  exerciseExtId:    z.string(),
  name:             z.string(),
  overview:         z.string().default(""),
  bodyPart:         strOrArr.default([]),
  equipment:        strOrArr.default([]),
  target:           strOrArr.default([]),
  muscleGroup:      strOrArr.default([]),
  category:         z.string().default(""),
  difficulty:       z.string().default(""),
  secondaryMuscles: z.array(z.string()).default([]),
  instructions:     z.array(z.string()).default([]),
  exerciseTips:     z.array(z.string()).default([]),
  variations:       z.array(z.string()).default([]),
});
const translationSchema = z.object({ translations: z.array(itemSchema) });

// ── System prompts ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPTS = {
  ru: `Ты — профессиональный переводчик фитнес-контента с английского на русский язык. Используй живой, профессиональный язык фитнес-индустрии, понятный посетителям спортивных залов.

═══ АБСОЛЮТНЫЕ ПРАВИЛА ═══
• Отвечай СТРОГО JSON-массивом — ни markdown, ни тройные апострофы, ни объяснений, ни слов до или после JSON.
• Переводи КАЖДОЕ поле для КАЖДОГО упражнения без исключения.
• Если поле пустое в оригинале — оставь пустую строку или пустой массив.
• Сохраняй РОВНО столько элементов в массивах, сколько в оригинале.
• НЕ пропускай ни одно упражнение из входного списка.

═══ КАК ПЕРЕВОДИТЬ КАЖДОЕ ПОЛЕ ═══
name           → Официальное русское название: «Жим штанги лёжа», «Подтягивания», «Приседания со штангой».
overview       → Краткое описание упражнения (2-4 предложения), что оно развивает и для кого подходит.
bodyPart       → МАССИВ частей тела (каждая строкой): «грудь», «спина», «ноги», «плечи», «руки», «пресс», «ягодицы» и т.д.
equipment      → МАССИВ оборудования (каждое строкой): «штанга», «гантели», «гиря», «тренажёр», «эспандер», «вес тела» и т.д.
target         → МАССИВ целевых мышц (каждая строкой): «большая грудная», «широчайшая мышца спины», «квадрицепс» и т.д.
muscleGroup    → МАССИВ групп мышц (аналогично target, каждая строкой).
category       → «силовые», «кардио», «гибкость», «функциональные», «изометрические» и т.д.
difficulty     → «начинающий», «средний уровень», «продвинутый».
secondaryMuscles → Массив вторичных мышц (каждая строкой).
instructions   → Массив шагов. Каждый шаг — отдельная строка. Формат: «Шаг 1: ...», «Шаг 2: ...». Переводи каждый шаг полностью.
exerciseTips   → Массив советов и предостережений от типичных ошибок. Каждый совет — отдельная строка.
variations     → Массив вариантов и модификаций упражнения. Каждый вариант — отдельная строка.

═══ ФОРМАТ ОТВЕТА ═══
[
  {
    "exerciseExtId": "...",
    "name": "...",
    "overview": "...",
    "bodyPart": ["..."],
    "equipment": ["..."],
    "target": ["..."],
    "muscleGroup": ["..."],
    "category": "...",
    "difficulty": "...",
    "secondaryMuscles": ["..."],
    "instructions": ["Шаг 1: ...", "Шаг 2: ..."],
    "exerciseTips": ["..."],
    "variations": ["..."]
  }
]`,

  uz: `Siz ingliz tilidan o'zbek tiliga (lotin yozuvi) fitness kontentini tarjima qiluvchi professional tarjimonasiz. Sport zallariga qatnaydiganlar uchun tushunarli, jonli va professional til ishlating.

═══ MUTLAQ QOIDALAR ═══
• FAQAT JSON massiv bilan javob bering — markdown yo'q, uchta tirnoq yo'q, tushuntirish yo'q, JSON dan oldin yoki keyin hech qanday matn yo'q.
• Har bir mashq uchun BARCHA maydonlarni tarjima qiling, istisnosiz.
• Agar asl nusxada maydon bo'sh bo'lsa — bo'sh satr yoki bo'sh massiv qoldiring.
• Massivlardagi elementlar sonini asl nusxadagidek SAQLANG.
• Kiritilgan ro'yxatdagi birorta mashqni o'tkazib yubormang.

═══ HAR BIR MAYDONNI QANDAY TARJIMA QILISH ═══
name           → Rasmiy o'zbek nomi: «Yotib shtanga ko'tarish», «Turnikda tortilish», «Shtanga bilan o'tirish».
overview       → Mashqning qisqacha tavsifi (2-4 jumla): nima rivojlantiradi va kimlar uchun mos.
bodyPart       → Tana qismlari MASSIVI (har biri alohida satr): «ko'krak», «orqa», «oyoqlar», «yelkalar», «qo'llar», «qorin», «dumba» va h.k.
equipment      → Jihozlar MASSIVI (har biri alohida satr): «shtanga», «hantellar», «girya», «trenajer», «rezina», «o'z tana og'irligi» va h.k.
target         → Asosiy mushaklar MASSIVI (har biri alohida satr): «katta ko'krak mushagi», «keng orqa mushagi», «to'rt boshli mushak» va h.k.
muscleGroup    → Mushak guruhlari MASSIVI (target bilan o'xshash, har biri alohida satr).
category       → «kuch», «kardio», «egiluvchanlik», «funksional», «izometrik» va h.k.
difficulty     → «boshlang'ich», «o'rta daraja», «yuqori daraja».
secondaryMuscles → Ikkinchi darajali mushaklar massivi (har biri alohida satr).
instructions   → Qadamlar massivi. Har bir qadam alohida satr. Format: «1-qadam: ...», «2-qadam: ...». Har bir qadamni to'liq tarjima qiling.
exerciseTips   → Maslahatlar va keng tarqalgan xatolar haqida ogohlantirish massivi. Har biri alohida satr.
variations     → Mashqning variantlari va modifikatsiyalari massivi. Har biri alohida satr.

═══ JAVOB FORMATI ═══
[
  {
    "exerciseExtId": "...",
    "name": "...",
    "overview": "...",
    "bodyPart": ["..."],
    "equipment": ["..."],
    "target": ["..."],
    "muscleGroup": ["..."],
    "category": "...",
    "difficulty": "...",
    "secondaryMuscles": ["..."],
    "instructions": ["1-qadam: ...", "2-qadam: ..."],
    "exerciseTips": ["..."],
    "variations": ["..."]
  }
]`,

  // English ENRICHMENT (not translation): the free v1 dataset leaves some fields
  // empty. Generate coherent English for the gaps so all three locales share the
  // same complete source. Safety: never fabricate precise step-by-step technique.
  en: `You are a professional strength & conditioning content writer. You are given exercises where SOME fields are empty. Fill ONLY the empty fields with accurate, concise ENGLISH content inferred from the exercise's name, target muscles, secondary muscles, equipment, and body part.

═══ ABSOLUTE RULES ═══
• Respond with ONLY a JSON array — no markdown, no code fences, no commentary before or after the JSON.
• Return EVERY exercise from the input, matched by its exerciseExtId.
• For fields that ALREADY have content in the input, return them UNCHANGED (do not paraphrase or rewrite them).
• For empty fields, generate appropriate English content. Keep arrays as arrays.

═══ HOW TO FILL EACH EMPTY FIELD ═══
overview         → 2–4 sentences: what the exercise trains and who it suits.
exerciseTips     → Array of 2–4 practical form tips / common-mistake warnings.
variations       → Array of 1–3 common variations or modifications.
category         → One of: "strength", "cardio", "flexibility", "functional", "isometric".
difficulty       → One of: "beginner", "intermediate", "advanced".
secondaryMuscles → Array, inferred from the movement (only if empty).
instructions     → ONLY if empty: 3–5 SAFE, GENERIC setup/execution cues. Do NOT invent precise loads, joint angles, or technique you cannot infer — keep cues conservative and general. If instructions already exist, return them unchanged.

═══ RESPONSE FORMAT ═══
[
  {
    "exerciseExtId": "...",
    "name": "...",
    "overview": "...",
    "bodyPart": ["..."],
    "equipment": ["..."],
    "target": ["..."],
    "muscleGroup": ["..."],
    "category": "...",
    "difficulty": "...",
    "secondaryMuscles": ["..."],
    "instructions": ["..."],
    "exerciseTips": ["..."],
    "variations": ["..."]
  }
]`,
};

// ── Source payload builder ─────────────────────────────────────────────────────
function toSourcePayload(e) {
  return {
    exerciseExtId:    e.exerciseId,
    name:             e.name,
    overview:         e.overview || "",
    bodyPart:         e.bodyParts        || [],   // full array — all body parts translated
    equipment:        e.equipments       || [],   // full array — all equipment translated
    target:           e.targetMuscles    || [],   // full array — all target muscles translated
    muscleGroup:      e.targetMuscles    || [],   // same source as target
    category:         e.category         || "",
    difficulty:       e.difficulty        || "",
    secondaryMuscles: e.secondaryMuscles  || [],
    instructions:     e.instructions      || [],
    exerciseTips:     e.exerciseTips       || [],
    variations:       e.variations         || [],
  };
}

// ── Robust JSON extraction ─────────────────────────────────────────────────────
function extractFirstJSON(text) {
  // Strip Qwen3 <think>...</think> blocks and markdown code fences
  const s = text
    .replace(/<think>[\s\S]*?<\/think>/gi, "")
    .replace(/```(?:json)?\s*/gi, "").replace(/```/g, "");
  const oi = s.indexOf("{"), ai = s.indexOf("[");
  const start = oi === -1 ? ai : ai === -1 ? oi : Math.min(oi, ai);
  if (start === -1) throw new Error("No JSON found in response");
  const open = s[start], close = open === "{" ? "}" : "]";
  let depth = 0, inStr = false, esc = false;
  for (let i = start; i < s.length; i++) {
    const c = s[i];
    if (esc)        { esc = false; continue; }
    if (c === "\\") { esc = true;  continue; }
    if (c === '"')  { inStr = !inStr; continue; }
    if (inStr)      continue;
    if (c === open) depth++;
    else if (c === close) { depth--; if (depth === 0) return s.slice(start, i + 1); }
  }
  throw new Error("Unbalanced JSON in response");
}

function parseTranslations(raw) {
  const arr = Array.isArray(raw) ? raw
    : Array.isArray(raw.translations) ? raw.translations
    : Array.isArray(raw.data)         ? raw.data
    : Object.values(raw).find(Array.isArray);
  if (!arr) throw new Error("No translations array found in response");
  return z.array(itemSchema).parse(arr);
}

// ── Translation core ───────────────────────────────────────────────────────────
function buildModel(provider) {
  if (provider.name === "groq" || provider.name === "groq-ru" || provider.name === "groq-uz")
    return createGroq({ apiKey: provider.groqApiKey })(provider.model);
  if (provider.name === "gemini")    return google(provider.model);
  if (provider.name === "anthropic") return anthropic(provider.model);
  throw new Error(`Unknown provider: ${provider.name}`);
}

// Direct fetch for Cerebras (OpenAI-compatible but @ai-sdk/openai routing breaks)
async function cerebrasChat(apiKey, model, system, prompt, maxTokens) {
  const res = await fetch("https://api.cerebras.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages: [{ role: "system", content: system }, { role: "user", content: prompt }],
      max_tokens: maxTokens || 16000,
    }),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => res.statusText);
    throw new Error(`Cerebras ${res.status}: ${body.slice(0, 200)}`);
  }
  const data = await res.json();
  return data.choices[0].message.content;
}

// Run one model call with the given system prompt + user prompt, returning the
// parsed item array. Shared by translation and English-enrichment passes.
async function runModel(provider, system, prompt) {
  if (provider.name === "cerebras" || provider.name === "cerebras-uz" || provider.name === "cerebras-ru") {
    const text = await cerebrasChat(provider.cerebrasApiKey, provider.model, system, prompt, provider.maxTokens);
    return parseTranslations(JSON.parse(extractFirstJSON(text)));
  }

  if (provider.useTextMode) {
    // Groq: no json_schema support → generateText + manual parse
    const { text } = await generateText({
      model: buildModel(provider),
      maxTokens: provider.maxTokens,
      system,
      prompt,
    });
    return parseTranslations(JSON.parse(extractFirstJSON(text)));
  }

  // Gemini / Anthropic: structured output via generateObject
  const { object } = await generateObject({
    model: buildModel(provider),
    schema: translationSchema,
    system,
    prompt,
  });
  return object.translations;
}

async function translateBatch(batch, locale, provider) {
  const payload = batch.map(toSourcePayload);
  const prompt =
    `Translate the following ${batch.length} exercises into ${locale}. ` +
    `Match each exercise by its exerciseExtId. Translate EVERY field fully.\n\n` +
    JSON.stringify(payload, null, 0);
  return runModel(provider, SYSTEM_PROMPTS[locale], prompt);
}

// English-enrichment pass: ask the model to fill ONLY the empty fields.
async function generateEnglishBatch(batch, _locale, provider) {
  const payload = batch.map(toSourcePayload);
  const prompt =
    `These ${batch.length} exercises have some empty English fields. ` +
    `Fill ONLY the empty fields; return already-filled fields unchanged. ` +
    `Match each exercise by its exerciseExtId and return every one.\n\n` +
    JSON.stringify(payload, null, 0);
  return runModel(provider, SYSTEM_PROMPTS.en, prompt);
}

// ── Rate-limit-aware wrapper ───────────────────────────────────────────────────
// Serialise ALL calls per-provider through a promise chain so parallel locales
// that share a provider never fire simultaneously and always respect delayMs.
const providerQueues = new WeakMap();

async function throttledTranslate(batch, locale, provider, fn = translateBatch) {
  if (!providerQueues.has(provider)) providerQueues.set(provider, Promise.resolve());

  let resolve_;
  const slot = new Promise(r => { resolve_ = r; });
  const prev = providerQueues.get(provider);
  providerQueues.set(provider, slot);

  await prev; // wait for previous call to finish
  const now = Date.now();
  const wait = provider.delayMs - (now - provider.lastCall);
  if (wait > 0) await new Promise(r => setTimeout(r, wait));
  provider.lastCall = Date.now();
  try {
    return await fn(batch, locale, provider);
  } finally {
    resolve_(); // release the next queued call
  }
}

// ── PocketBase ─────────────────────────────────────────────────────────────────
const pb = new PocketBase(PB_URL);
try {
  await pb.collection("_superusers").authWithPassword(PB_EMAIL, PB_PASS);
  console.log("✓ PocketBase authed");
} catch (err) {
  console.error("✗ PocketBase auth failed:", err.message);
  process.exit(1);
}

async function upsert(row) {
  const opts = { requestKey: null }; // disable auto-cancellation for parallel upserts
  try {
    const existing = await pb.collection("exercise_translations")
      .getFirstListItem(`exerciseExtId="${row.exerciseExtId}" && locale="${row.locale}"`, opts);
    await pb.collection("exercise_translations").update(existing.id, row, opts);
  } catch {
    await pb.collection("exercise_translations").create(row, opts);
  }
}

// ── Exercise fetch ─────────────────────────────────────────────────────────────
async function fetchAllExercises() {
  const all = [];
  const pageSize = 100; // API max
  let offset = 0;
  while (all.length < LIMIT) {
    const url = `${EXDB_URL}/exercises?limit=${pageSize}&offset=${offset}`;
    const res = await fetch(url, { headers: { accept: "application/json" } });
    if (!res.ok) throw new Error(`exercisedb-api ${res.status} ${res.statusText}`);
    const body = await res.json();
    const items = Array.isArray(body) ? body : (body.data || []);
    if (!items.length) break;
    all.push(...items);
    if (items.length < pageSize) break;
    offset += pageSize;
  }
  return all.slice(0, LIMIT);
}

console.log(`→ Fetching exercises from ${EXDB_URL}…`);
const exercises = await fetchAllExercises();
console.log(`✓ Got ${exercises.length} exercises`);

// ── Progress ───────────────────────────────────────────────────────────────────
const PROGRESS_FILE = ".seed-progress.json";
let progress = existsSync(PROGRESS_FILE)
  ? JSON.parse(readFileSync(PROGRESS_FILE, "utf8"))
  : { done: {} };

function saveProgress() {
  writeFileSync(PROGRESS_FILE, JSON.stringify(progress, null, 2));
}

class ProviderDeadError extends Error {}

// ── Locale processing ──────────────────────────────────────────────────────────
async function processLocale(locale, provider) {
  if (!SYSTEM_PROMPTS[locale]) {
    console.warn(`! No system prompt for "${locale}", skipping`);
    return;
  }
  progress.done[locale] ||= {};

  const pending = exercises.filter(e => !progress.done[locale][e.exerciseId]);
  const tag = `[${provider.name}→${locale.toUpperCase()}]`;
  console.log(`\n─── ${tag} ${pending.length}/${exercises.length} pending ───`);

  let consecutiveFails = 0;

  for (let i = 0; i < pending.length; i += provider.batchSize) {
    const batch = pending.slice(i, i + provider.batchSize);
    console.log(`  ${tag} batch ${i + 1}-${i + batch.length} of ${pending.length}`);

    let translations;
    try {
      translations = await throttledTranslate(batch, locale, provider);
      if (translations.length < batch.length) {
        console.warn(`  ⚠ ${tag} partial: got ${translations.length}/${batch.length} — saving what we have`);
      }
      consecutiveFails = 0;
    } catch (err) {
      const isRateLimit = /rate.?limit|quota|429/i.test(err.message);
      const isDailyQuota = /tokens per day|daily.?quota|tokens.*day.*limit|exceeded.*quota|quota.*exceeded/i.test(err.message);

      // Daily quota exhausted — switch provider immediately (no point retrying today).
      if (isDailyQuota || (isRateLimit && provider.dailyQuotaSwitch)) {
        console.error(`  ✗ ${tag} daily quota exhausted — switching provider immediately`);
        throw new ProviderDeadError(`${provider.name} daily quota exhausted`);
      }

      const waitMs = isRateLimit ? 65_000 : 4_000;
      console.warn(`  ✗ ${tag} failed (${err.message.slice(0, 100)}). Retrying in ${waitMs / 1000}s…`);
      await new Promise(r => setTimeout(r, waitMs));
      try {
        translations = await throttledTranslate(batch, locale, provider);
        if (translations.length < batch.length) {
          console.warn(`  ⚠ ${tag} partial: got ${translations.length}/${batch.length} — saving what we have`);
        }
        consecutiveFails = 0;
      } catch (err2) {
        consecutiveFails++;
        if (consecutiveFails >= 6) throw new ProviderDeadError(`${provider.name} quota exhausted`);
        console.error(`  ✗✗ ${tag} giving up on batch: ${err2.message.slice(0, 120)}`);
        continue;
      }
    }

    let saved = 0;
    for (const t of translations) {
      const row = {
        exerciseExtId:    t.exerciseExtId,
        locale,
        name:             t.name,
        overview:         t.overview,
        bodyPart:         (t.bodyPart     || []).join("\n"),
        equipment:        (t.equipment    || []).join("\n"),
        target:           (t.target       || []).join("\n"),
        muscleGroup:      (t.muscleGroup  || []).join("\n"),
        category:         t.category,
        difficulty:       t.difficulty,
        secondaryMuscles: (t.secondaryMuscles || []).join("\n"),
        instructions:     (t.instructions     || []).join("\n"),
        exerciseTips:     (t.exerciseTips      || []).join("\n"),
        variations:       (t.variations        || []).join("\n"),
      };
      try {
        await upsert(row);
        progress.done[locale][t.exerciseExtId] = true;
        saved++;
      } catch (err) {
        console.error(`  ✗ upsert ${t.exerciseExtId}: ${err.message}`);
      }
    }
    saveProgress();
    console.log(`  ✓ ${tag} saved ${saved}`);
  }

  console.log(`\n✓ ${tag} done`);
}

// ── English enrichment ──────────────────────────────────────────────────────────
// True when the dataset left a descriptive field empty for this exercise.
function hasEnglishGap(e) {
  return !e.overview
    || !(e.exerciseTips || []).length
    || !(e.instructions || []).length
    || !(e.variations || []).length
    || !e.category
    || !e.difficulty;
}

// Generate missing English fields, store sparse `locale="en"` rows (only the
// fields that were empty), AND mutate the in-memory exercise so the subsequent
// ru/uz passes translate the enriched, complete source.
async function enrichEnglish(startIdx = 0, tried = new Set()) {
  tried.add(startIdx);
  const provider = PROVIDERS[startIdx];
  if (!provider) { console.error("✗ No provider left for EN enrichment"); return; }

  progress.done.en ||= {};
  const pending = exercises.filter(e => !progress.done.en[e.exerciseId] && hasEnglishGap(e));
  const tag = `[${provider.name}→EN-gen]`;
  console.log(`\n─── ${tag} ${pending.length} exercises need enrichment ───`);

  try {
    for (let i = 0; i < pending.length; i += provider.batchSize) {
      const batch = pending.slice(i, i + provider.batchSize);
      console.log(`  ${tag} batch ${i + 1}-${i + batch.length} of ${pending.length}`);

      let filled;
      try {
        filled = await throttledTranslate(batch, "en", provider, generateEnglishBatch);
      } catch (err) {
        const isRateLimit  = /rate.?limit|quota|429/i.test(err.message);
        const isDailyQuota = /tokens per day|daily.?quota|exceeded.*quota|quota.*exceeded/i.test(err.message);
        if (isDailyQuota || (isRateLimit && provider.dailyQuotaSwitch)) {
          throw new ProviderDeadError(`${provider.name} quota exhausted`);
        }
        console.warn(`  ✗ ${tag} ${err.message.slice(0, 100)} — skipping batch`);
        continue;
      }

      const byId = new Map(filled.map(t => [t.exerciseExtId, t]));
      let saved = 0;
      for (const e of batch) {
        const t = byId.get(e.exerciseId);
        if (t) {
          const row = { exerciseExtId: e.exerciseId, locale: "en" };
          // Fill only fields that were empty in the source — keep the row sparse
          // so the client overlay never clobbers real API data.
          if (!e.overview && t.overview) { row.overview = t.overview; e.overview = t.overview; }
          if (!(e.exerciseTips || []).length && t.exerciseTips?.length) { row.exerciseTips = t.exerciseTips.join("\n"); e.exerciseTips = t.exerciseTips; }
          if (!(e.variations || []).length && t.variations?.length) { row.variations = t.variations.join("\n"); e.variations = t.variations; }
          if (!(e.instructions || []).length && t.instructions?.length) { row.instructions = t.instructions.join("\n"); e.instructions = t.instructions; }
          if (!(e.secondaryMuscles || []).length && t.secondaryMuscles?.length) { row.secondaryMuscles = t.secondaryMuscles.join("\n"); e.secondaryMuscles = t.secondaryMuscles; }
          if (!e.category && t.category) { row.category = t.category; e.category = t.category; }
          if (!e.difficulty && t.difficulty) { row.difficulty = t.difficulty; e.difficulty = t.difficulty; }

          if (Object.keys(row).length > 2) {
            try { await upsert(row); saved++; }
            catch (err) { console.error(`  ✗ upsert en ${e.exerciseId}: ${err.message}`); }
          }
        }
        progress.done.en[e.exerciseId] = true;
      }
      saveProgress();
      console.log(`  ✓ ${tag} enriched ${saved}`);
    }
    console.log(`\n✓ ${tag} done`);
  } catch (err) {
    if (err instanceof ProviderDeadError) {
      const next = PROVIDERS.findIndex((_, i) => !tried.has(i));
      if (next !== -1) {
        console.warn(`\n⚠ ${provider.name} dead for EN — falling back to ${PROVIDERS[next].name}`);
        await enrichEnglish(next, tried);
      } else {
        console.error("✗ All providers exhausted for EN enrichment. Re-run tomorrow.");
      }
    } else {
      throw err;
    }
  }
}

// ── Main ───────────────────────────────────────────────────────────────────────
async function runLocale(locale, providerIndex = 0, tried = new Set()) {
  tried.add(providerIndex);
  const provider = PROVIDERS[providerIndex];
  if (!provider) {
    console.error(`✗ No working provider left for ${locale}`);
    return;
  }
  try {
    await processLocale(locale, provider);
  } catch (err) {
    if (err instanceof ProviderDeadError) {
      const fallbackIdx = PROVIDERS.findIndex((_, i) => !tried.has(i));
      if (fallbackIdx !== -1) {
        console.warn(`\n⚠ ${provider.name} dead for ${locale} — falling back to ${PROVIDERS[fallbackIdx].name}`);
        await runLocale(locale, fallbackIdx, tried);
      } else {
        console.error(`✗ All providers exhausted for ${locale}. Re-run tomorrow.`);
      }
    } else {
      throw err;
    }
  }
}

// Phase 1 — enrich missing English fields first, so ru/uz translate the
// complete source. Set GENERATE_EN=0 to skip.
if (process.env.GENERATE_EN !== "0") {
  console.log("\n→ EN enrichment phase (generating missing English fields)…");
  await enrichEnglish(0);
}

// Phase 2 — translate the (now-complete) English source into ru/uz.
if (PROVIDERS.length >= 2 && LOCALES.length >= 2) {
  // Pin each locale to its dedicated provider (separate account = separate quota pool).
  const uzIdx = PROVIDERS.findIndex(p => p.name === "cerebras-uz");
  const ruIdx = PROVIDERS.findIndex(p => p.name === "cerebras-ru") !== -1
    ? PROVIDERS.findIndex(p => p.name === "cerebras-ru")
    : PROVIDERS.findIndex(p => p.name === "groq-ru");
  const startIdx = locale => {
    if (locale === "uz" && uzIdx !== -1) return uzIdx;
    if (locale === "ru" && ruIdx !== -1) return ruIdx;
    return 0;
  };
  console.log(`\n→ PARALLEL mode: ${LOCALES.map(l => `${l}→${PROVIDERS[startIdx(l)].name}`).join(", ")}`);
  await Promise.all(LOCALES.map(locale => runLocale(locale, startIdx(locale))));
} else {
  console.log(`\n→ SEQUENTIAL mode: ${PROVIDERS[0].name}`);
  for (const locale of LOCALES) await runLocale(locale, 0);
}

console.log("\n✓ Seeding complete.");
