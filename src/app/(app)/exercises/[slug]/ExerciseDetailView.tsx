"use client";

import { useMemo } from "react";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { BrandNoiseOverlay } from "@/components/layout/BrandNoiseOverlay";
import type { LibraryExercise } from "@/types/exercise";
import { useExerciseTranslation } from "@/hooks/useExerciseTranslation";
import { applyTranslationToLibraryExercise } from "@/lib/exercise-translate";
import { useI18n } from "@/components/providers/I18nProvider";
import { tBodyPart, tEquipment, tMuscle } from "@/lib/exercise-taxonomy";

interface Props {
  baseExercise: LibraryExercise;
}

export function ExerciseDetailView({ baseExercise }: Props) {
  const { language, t } = useI18n();
  const { data: translation } = useExerciseTranslation(baseExercise.exerciseId);

  const exercise = useMemo(
    () => applyTranslationToLibraryExercise(baseExercise, translation ?? null),
    [baseExercise, translation],
  );

  const bodyPartLabel =
    language === "en"
      ? exercise.bodyPart
      : translation?.bodyPart || tBodyPart(baseExercise.bodyPart, language);
  const equipmentLabel =
    language === "en"
      ? exercise.equipment
      : translation?.equipment || tEquipment(baseExercise.equipment, language);
  const targetLabel =
    language === "en"
      ? exercise.target
      : translation?.target || tMuscle(baseExercise.target, language);
  const muscleGroupLabel =
    language === "en"
      ? exercise.muscleGroup
      : translation?.muscleGroup || tMuscle(baseExercise.muscleGroup, language);

  return (
    <div className="space-y-6 py-6">
      <Link
        href="/exercises"
        className="inline-flex items-center gap-1.5 font-data text-[10px] uppercase tracking-widest text-[#71717A] hover:text-[#e5e5e5] transition-colors group"
      >
        <ChevronLeft className="h-3 w-3 group-hover:text-[#e53e00] transition-colors" />
        {t("exercises.BACK_TO_LIBRARY")}
      </Link>

      <div className="border border-[#2a2a2a] bg-[#0a0a0a] relative overflow-hidden">
        <BrandNoiseOverlay />
        <div className="relative z-10 flex justify-center p-4 sm:p-8 bg-[#050505]">
          {exercise.gif ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={exercise.gif}
              alt={exercise.name}
              loading="lazy"
              className="max-h-64 sm:max-h-80 w-auto object-contain"
            />
          ) : exercise.image ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={exercise.image}
              alt={exercise.name}
              loading="lazy"
              className="max-h-64 sm:max-h-80 w-auto object-contain"
            />
          ) : (
            <div className="h-64 flex items-center justify-center">
              <span
                className="stamp text-[#525252] text-[10px] tracking-widest"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {t("exercises.NO_MEDIA")}
              </span>
            </div>
          )}
        </div>
      </div>

      <div>
        <h1
          className="text-3xl sm:text-4xl font-black uppercase tracking-tight text-[#e5e5e5]"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {exercise.name}
        </h1>
        <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {[
          { label: t("exercises.BODY_PART"), value: bodyPartLabel },
          { label: t("exercises.EQUIPMENT"), value: equipmentLabel },
          { label: t("exercises.TARGET"), value: targetLabel },
          { label: t("exercises.CATEGORY"), value: exercise.category },
        ].map(({ label, value }) => (
          <div
            key={label}
            className="border border-[#2a2a2a] bg-[#0a0a0a] p-3 relative overflow-hidden"
            style={{ borderLeft: "2px solid #e53e00" }}
          >
            <BrandNoiseOverlay />
            <div className="relative z-10">
              <p
                className="stamp text-[8px] text-[#525252] tracking-widest mb-1"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {label}
              </p>
              <p
                className="font-data text-[11px] font-bold uppercase tracking-widest text-[#e5e5e5]"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {value || t("exercises.NA")}
              </p>
            </div>
          </div>
        ))}
      </div>

      {exercise.overview && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-px flex-1 bg-[#1a1a1a]" />
              <span
                className="stamp text-[9px] uppercase tracking-widest text-[#525252]"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {t("exercises.OVERVIEW")}
              </span>
              <div className="h-px flex-1 bg-[#1a1a1a]" />
            </div>
            <p className="font-data text-[13px] leading-relaxed text-[#a3a3a3]">
              {exercise.overview}
            </p>
          </div>
        </div>
      )}

      {exercise.steps.length > 0 && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-px flex-1 bg-[#1a1a1a]" />
              <span
                className="stamp text-[9px] uppercase tracking-widest text-[#525252]"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {t("exercises.STEPS")}
              </span>
              <div className="h-px flex-1 bg-[#1a1a1a]" />
            </div>
            <ol className="space-y-3">
              {exercise.steps.map((step, i) => (
                <li key={i} className="flex gap-3">
                  <span
                    className="shrink-0 font-data text-[10px] font-bold text-[#e53e00] tabular-nums pt-0.5"
                    style={{ fontFamily: "var(--font-mono, monospace)" }}
                  >
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <p className="font-data text-[13px] leading-relaxed text-[#a3a3a3]">
                    {step}
                  </p>
                </li>
              ))}
            </ol>
          </div>
        </div>
      )}

      {exercise.tips.length > 0 && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-3">
              <div className="h-px flex-1 bg-[#1a1a1a]" />
              <span
                className="stamp text-[9px] uppercase tracking-widest text-[#525252]"
                style={{ fontFamily: "var(--font-mono, monospace)" }}
              >
                {t("exercises.TIPS")}
              </span>
              <div className="h-px flex-1 bg-[#1a1a1a]" />
            </div>
            <ul className="space-y-2">
              {exercise.tips.map((tip, i) => (
                <li
                  key={i}
                  className="font-data text-[13px] leading-relaxed text-[#a3a3a3] pl-3 border-l border-[#e53e00]/40"
                >
                  {tip}
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {exercise.variations.length > 0 && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <p
              className="stamp text-[9px] uppercase tracking-widest text-[#525252] mb-3"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {t("exercises.VARIATIONS")}
            </p>
            <div className="flex flex-wrap gap-2">
              {exercise.variations.map((v) => (
                <span
                  key={v}
                  className="px-2 py-1 border border-[#2a2a2a] font-data text-[10px] uppercase tracking-widest text-[#a3a3a3]"
                >
                  {v}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}

      {exercise.secondaryMuscles.length > 0 && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <p
              className="stamp text-[9px] uppercase tracking-widest text-[#525252] mb-3"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {t("exercises.SECONDARY_MUSCLES")}
            </p>
            <div className="flex flex-wrap gap-2">
              {exercise.secondaryMuscles.map((muscle) => (
                <span
                  key={muscle}
                  className="px-2 py-1 border border-[#2a2a2a] font-data text-[9px] uppercase tracking-widest text-[#71717A]"
                >
                  {language === "en" ? muscle : tMuscle(muscle, language)}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}

      <div className="border-t-2 border-[#e53e00] pt-4">
        <div className="grid grid-cols-3">
          <div className="px-4 py-2 text-center border-r border-[#1a1a1a]">
            <p
              className="stamp text-[8px] text-[#525252] mb-1"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {t("exercises.MUSCLE_GROUP")}
            </p>
            <p
              className="font-data text-[10px] text-[#71717A] uppercase tracking-widest"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {muscleGroupLabel || "—"}
            </p>
          </div>
          <div className="px-4 py-2 text-center border-r border-[#1a1a1a]">
            <p
              className="stamp text-[8px] text-[#525252] mb-1"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {t("exercises.TARGET")}
            </p>
            <p
              className="font-data text-[10px] text-[#71717A] uppercase tracking-widest"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {targetLabel || "—"}
            </p>
          </div>
          <div className="px-4 py-2 text-center">
            <p
              className="stamp text-[8px] text-[#525252] mb-1"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {t("exercises.EXERCISE_ID")}
            </p>
            <p
              className="font-data text-[10px] text-[#71717A] truncate"
              style={{ fontFamily: "var(--font-mono, monospace)" }}
            >
              {exercise.exerciseId.slice(0, 8)}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
