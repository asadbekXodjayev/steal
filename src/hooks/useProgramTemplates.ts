"use client";

import { useQuery } from "@tanstack/react-query";
import { getPocketBase } from "@/lib/pocketbase";
import { useI18n } from "@/components/providers/I18nProvider";
import type { Language } from "@/lib/translations";
import type { LegendProgram, TrainingDay, Exercise } from "@/data/legend-programs";

// ── PocketBase shape ───────────────────────────────────────────────────────
interface PBExercise {
  name: string;
  sets: string;
  repsRange: string;
  restSeconds: number;
  tempo: string;
  notes: string;
}

interface PBDay {
  dayNumber: number;
  label: string;
  isRest: boolean;
  exercises?: PBExercise[];
  activities?: string[];
}

interface PBLocale {
  slug: string;
  title: string;
  description: string;
  overview: {
    split: string;
    bestFor: string;
    characteristics: string[];
  };
  days: PBDay[];
  guidelines: {
    progression: string[];
    deload: string[];
    recovery: string[];
  };
}

interface PBStructure {
  slug: string;
  locales: Record<string, PBLocale>;
}

export interface PBProgramTemplate {
  id: string;
  title: string;
  description: string;
  goalType: string;
  difficulty: string;
  durationWeeks: number;
  popularity: number;
  structure: PBStructure;
}

// ── Static metadata (presentation data not stored in PB) ───────────────────
const SLUG_META: Record<string, { athleteName: string; image: string; images: string[]; sessionLength: string; tags: string[] }> = {
  // Curated athlete photos under public/legends/<slug>/: prev.jpg is the card
  // preview; `images` is the detail carousel (prev first, then the rest).
  arnold:  { athleteName: "Arnold Schwarzenegger", image: "/legends/arnold/prev.jpg",  images: ["/legends/arnold/prev.jpg", "/legends/arnold/1.jpg", "/legends/arnold/2.jpg"], sessionLength: "75-90 min",  tags: ["Classic Bodybuilding", "High Volume", "Pump Focus"] },
  platz:   { athleteName: "Tom Platz",             image: "/legends/platz/prev.jpg",   images: ["/legends/platz/prev.jpg", "/legends/platz/1.jpg", "/legends/platz/2.webp"], sessionLength: "75-105 min", tags: ["Quad Focus", "High Intensity", "Extreme Volume"] },
  piana:   { athleteName: "Rich Piana",            image: "/legends/piana/prev.jpg",   images: ["/legends/piana/prev.jpg", "/legends/piana/1.jpg"], sessionLength: "90-120 min", tags: ["Extreme Volume", "High Intensity", "Drop Sets"] },
  mentzer: { athleteName: "Mike Mentzer",          image: "/legends/mentzer/prev.jpg", images: ["/legends/mentzer/prev.jpg", "/legends/mentzer/1.png", "/legends/mentzer/2.jpg", "/legends/mentzer/3.jpg"], sessionLength: "30-45 min",  tags: ["HIT", "Low Volume", "Maximum Intensity"] },
  yates:   { athleteName: "Dorian Yates",          image: "/legends/yates/prev.jpg",   images: ["/legends/yates/prev.jpg", "/legends/yates/1.jpg", "/legends/yates/2.jpg"], sessionLength: "45-60 min",  tags: ["Blood & Guts", "HIT", "Controlled Negatives"] },
  ronnie:  { athleteName: "Ronnie Coleman",        image: "/legends/ronnie/prev.jpg",  images: ["/legends/ronnie/prev.jpg", "/legends/ronnie/1.webp", "/legends/ronnie/2.jpg"], sessionLength: "75-90 min",  tags: ["High Frequency", "Heavy Compounds", "Maximum Mass"] },
  nippard: { athleteName: "Jeff Nippard",          image: "/legends/nippard/prev.jpg", images: ["/legends/nippard/prev.jpg"], sessionLength: "60-75 min",  tags: ["Science-Based", "RIR Tracking", "Evidence-Based"] },
};

const DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

// ── Mapper: PB record + locale → LegendProgram ─────────────────────────────
function mapToLegendProgram(pb: PBProgramTemplate, lang: Language): LegendProgram {
  const locales = pb.structure?.locales ?? {};
  const locale: PBLocale = locales[lang] ?? locales["en"];
  if (!locale) throw new Error(`Missing locale data for ${pb.id}`);

  const slug = pb.structure?.slug ?? "unknown";
  const meta = SLUG_META[slug] ?? { athleteName: pb.title, image: "", images: [] as string[], sessionLength: "60-90 min", tags: [] };

  const activeDays = locale.days.filter((d) => !d.isRest);
  const frequency = `${activeDays.length} day${activeDays.length !== 1 ? "s" : ""} per week`;

  const schedule = locale.days.map((d, i) => ({
    day: DAY_NAMES[i] ?? `Day ${d.dayNumber}`,
    workout: d.isRest ? "Rest" : d.label,
  }));

  const trainingDays: TrainingDay[] = locale.days
    .filter((d) => !d.isRest && d.exercises?.length)
    .map((d): TrainingDay => ({
      name: `Day ${d.dayNumber}`,
      focus: d.label,
      exercises: (d.exercises ?? []).map((ex): Exercise => ({
        name: ex.name,
        imagePlaceholder: ex.name,
        sets: ex.sets,
        reps: ex.repsRange,
        rest:
          ex.restSeconds >= 120
            ? `${Math.round(ex.restSeconds / 60)} min`
            : `${ex.restSeconds}s`,
        tempo: ex.tempo,
        notes: ex.notes,
      })),
    }));

  return {
    id: pb.id,
    name: locale.title,
    athleteName: meta.athleteName,
    philosophy: locale.description,
    frequency,
    split: locale.overview.split,
    weeklyVolume: Object.fromEntries(
      locale.overview.characteristics.map((c, i) => [`pt${i + 1}`, c])
    ),
    recommendedFor: locale.overview.bestFor,
    sessionLength: meta.sessionLength,
    schedule,
    trainingDays,
    progression: locale.guidelines.progression,
    deload: Array.isArray(locale.guidelines.deload)
      ? locale.guidelines.deload.join(" ")
      : String(locale.guidelines.deload ?? ""),
    recovery: locale.guidelines.recovery,
    image: meta.image,
    tags: meta.tags,
  };
}

// ── Hook ───────────────────────────────────────────────────────────────────
// Fetches raw PB records once (queryKey: ["program-templates"]).
// `select` re-transforms cached data on every language change — no extra
// network request, just a locale swap from the embedded structure.locales.
export function useProgramTemplates() {
  const { language } = useI18n();
  const pb = getPocketBase();

  return useQuery<PBProgramTemplate[], Error, LegendProgram[]>({
    queryKey: ["program-templates"],
    queryFn: async () => {
      const result = await pb
        .collection("plan_templates")
        .getList<PBProgramTemplate>(1, 20, {
          sort: "-popularity",
          requestKey: null,
        });
      return result.items;
    },
    // select re-runs whenever `language` changes (new function ref each render)
    // without touching the raw cache — optimal: 1 PB call, instant locale switch
    select: (raw) => raw.map((r) => mapToLegendProgram(r, language)),
    staleTime: 5 * 60 * 1000,
  });
}
