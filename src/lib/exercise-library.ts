import {
  fetchExercises,
  getExerciseById,
  searchExercisesByName,
  type ExerciseV2,
} from "@/lib/exercise-db-api";
import type { LibraryExercise } from "@/types/exercise";

const PAGE_SIZE = 100; // API max page size
const MAX_PAGES = 40;

function slugify(input: string): string {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function first<T>(arr: T[] | undefined, fallback = ""): T | string {
  return arr && arr.length > 0 ? arr[0] : fallback;
}

/**
 * Route third-party exercise GIFs through our own origin (`/api/exdb-media/*`)
 * so the browser never has to reach static.exercisedb.dev directly — fixes gifs
 * not loading behind region blocks / ad-blockers / CORS. Only the animated `gif`
 * (rendered via a raw <img>) is proxied; `image` stays absolute so next/image
 * thumbnails keep optimizing it server-side (which already works).
 */
function proxyMedia(url: string): string {
  return url.replace(/^https?:\/\/static\.exercisedb\.dev/i, "/api/exdb-media");
}

export function toLibraryExercise(ex: ExerciseV2): LibraryExercise {
  const instructions = Array.isArray(ex.instructions) ? ex.instructions : [];
  // The self-hosted fork only ships `gifUrl`; reuse it as the static image.
  const image = ex.imageUrl || ex.gifUrl || "";
  return {
    id: ex.exerciseId,
    exerciseId: ex.exerciseId,
    name: ex.name,
    slug: slugify(ex.name),
    category: ex.category ?? "",
    difficulty: ex.difficulty ?? "",
    bodyPart: String(first(ex.bodyParts, "")),
    equipment: String(first(ex.equipments, "")),
    muscleGroup: String(first(ex.targetMuscles, "")),
    target: String(first(ex.targetMuscles, "")),
    secondaryMuscles: ex.secondaryMuscles ?? [],
    instructions: instructions.join(" "),
    steps: instructions,
    overview: ex.overview ?? "",
    tips: ex.exerciseTips ?? [],
    variations: ex.variations ?? [],
    image,
    gif: proxyMedia(ex.gifUrl || image),
    videoUrl: ex.videoUrl ?? "",
  };
}

let _allCache: Promise<LibraryExercise[]> | null = null;

async function fetchAllPaginated(): Promise<LibraryExercise[]> {
  const all: LibraryExercise[] = [];
  for (let page = 0; page < MAX_PAGES; page++) {
    const chunk = await fetchExercises(PAGE_SIZE, page * PAGE_SIZE);
    if (!chunk.length) break;
    all.push(...chunk.map(toLibraryExercise));
    if (chunk.length < PAGE_SIZE) break;
  }
  return all;
}

export function getAllExercises(): Promise<LibraryExercise[]> {
  if (!_allCache) {
    _allCache = fetchAllPaginated().catch((err) => {
      _allCache = null;
      throw err;
    });
  }
  return _allCache;
}

function normalize(str: string): string {
  return str.toLowerCase().replace(/[^a-z0-9]/g, "");
}

const MIN_TOKEN_LENGTH = 4;

export async function findExerciseByName(
  name: string,
): Promise<LibraryExercise | null> {
  if (!name) return null;

  // Fast path: API search endpoint — cheap and deduplicated by the HTTP cache.
  try {
    const hits = await searchExercisesByName(name);
    if (hits && hits.length > 0) {
      return toLibraryExercise(hits[0]);
    }
  } catch {
    // Fall through to fuzzy match over the full list.
  }

  const exercises = await getAllExercises();
  const normalizedInput = normalize(name);

  const slugTarget = slugify(name);
  const bySlug = exercises.find((ex) => ex.slug === slugTarget);
  if (bySlug) return bySlug;

  const byName = exercises.find(
    (ex) => normalize(ex.name) === normalizedInput,
  );
  if (byName) return byName;

  const inputTokens = name
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .map((t) => t.replace(/[^a-z0-9]/g, ""))
    .filter((t) => t.length >= MIN_TOKEN_LENGTH);

  if (inputTokens.length === 0) return null;

  let bestScore = 0;
  let bestMatch: LibraryExercise | null = null;
  for (const ex of exercises) {
    const exNorm = normalize(ex.name);
    let score = 0;
    for (const token of inputTokens) {
      if (exNorm.includes(token)) score += token.length;
    }
    if (score > bestScore) {
      bestScore = score;
      bestMatch = ex;
    }
  }
  return bestScore >= MIN_TOKEN_LENGTH ? bestMatch : null;
}

export async function findExerciseBySlug(
  slug: string,
): Promise<LibraryExercise | null> {
  const list = await getAllExercises();
  return list.find((ex) => ex.slug === slug) ?? null;
}

export async function findExerciseById(
  exerciseId: string,
): Promise<LibraryExercise | null> {
  try {
    const ex = await getExerciseById(exerciseId);
    return ex ? toLibraryExercise(ex) : null;
  } catch {
    return null;
  }
}

export interface SearchOptions {
  q?: string;
  bodyPart?: string;
  equipment?: string;
  muscleGroup?: string;
  target?: string;
}

export async function searchExercises(
  opts: SearchOptions,
): Promise<LibraryExercise[]> {
  const exercises = await getAllExercises();
  const q = opts.q?.toLowerCase();
  return exercises.filter((ex) => {
    if (q && !ex.name.toLowerCase().includes(q)) return false;
    if (opts.bodyPart && ex.bodyPart !== opts.bodyPart) return false;
    if (opts.equipment && ex.equipment !== opts.equipment) return false;
    if (opts.muscleGroup && ex.muscleGroup !== opts.muscleGroup) return false;
    if (opts.target && ex.target !== opts.target) return false;
    return true;
  });
}

export async function getFilterOptions(): Promise<{
  bodyParts: string[];
  equipment: string[];
  muscleGroups: string[];
  targets: string[];
}> {
  const exercises = await getAllExercises();
  const bodyParts = [
    ...new Set(exercises.map((ex) => ex.bodyPart).filter(Boolean)),
  ].sort();
  const equipment = [
    ...new Set(exercises.map((ex) => ex.equipment).filter(Boolean)),
  ].sort();
  const muscleGroups = [
    ...new Set(exercises.map((ex) => ex.muscleGroup).filter(Boolean)),
  ].sort();
  const targets = [
    ...new Set(exercises.map((ex) => ex.target).filter(Boolean)),
  ].sort();
  return { bodyParts, equipment, muscleGroups, targets };
}
