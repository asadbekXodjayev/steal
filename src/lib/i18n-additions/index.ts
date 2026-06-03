import type { Language, TranslationData } from "@/lib/translations";
import progress from "./progress";
import plansPrograms from "./plans-programs";
import workoutDashboard from "./workout-dashboard";
import misc from "./misc";

export type LocaleAdditions = Partial<Record<Language, TranslationData>>;

const LANGUAGES: Language[] = ["en", "ru", "uz"];

const modules: LocaleAdditions[] = [
  progress,
  plansPrograms,
  workoutDashboard,
  misc,
];

function deepMergeInto(target: TranslationData, source: TranslationData): void {
  for (const key of Object.keys(source)) {
    const value = source[key];
    if (value && typeof value === "object") {
      const existing = target[key];
      if (!existing || typeof existing !== "object") {
        target[key] = {};
      }
      deepMergeInto(target[key] as TranslationData, value as TranslationData);
    } else {
      target[key] = value;
    }
  }
}

/**
 * Aggregated, deep-merged feature additions, keyed by language.
 * Consumed by translations.ts and merged on top of the base locale objects.
 */
export const additions: Record<Language, TranslationData> = LANGUAGES.reduce(
  (acc, lang) => {
    const merged: TranslationData = {};
    for (const mod of modules) {
      const langData = mod[lang];
      if (langData) deepMergeInto(merged, langData);
    }
    acc[lang] = merged;
    return acc;
  },
  {} as Record<Language, TranslationData>,
);
