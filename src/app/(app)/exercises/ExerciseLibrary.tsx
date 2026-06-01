"use client";

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import Image from "next/image";
import Link from "next/link";
import { Search, Filter } from "lucide-react";
import { cn } from "@/lib/utils";
import type { LibraryExercise } from "@/types/exercise";
import { getAllExercises } from "@/lib/exercise-library";
import { useI18n } from "@/components/providers/I18nProvider";
import { useExercisesBatchTranslation, useAllExerciseTranslationNames } from "@/hooks/useExerciseTranslation";
import { applyTranslationToLibraryExercise } from "@/lib/exercise-translate";
import { tBodyPart, tEquipment, tMuscle } from "@/lib/exercise-taxonomy";

interface FilterOptions {
  bodyParts: string[];
  equipment: string[];
  muscleGroups: string[];
  targets: string[];
}

interface Props {
  filters: FilterOptions;
}

const PAGINATION_SIZE = 18;

function GridSkeleton() {
  return (
    <div className="glass p-4">
      <div className="skeleton-steal w-full aspect-square mb-3" />
      <div className="skeleton-steal h-4 w-3/4 mb-2" />
      <div className="flex gap-1 mt-2">
        <div className="skeleton-steal h-5 w-16" />
        <div className="skeleton-steal h-5 w-12" />
      </div>
    </div>
  );
}

function ExerciseCard({ exercise, noImgLabel }: { exercise: LibraryExercise; noImgLabel: string }) {
  return (
    <Link
      href={`/exercises/${exercise.slug}`}
      className="glass glass-hover group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#C2410C] focus-visible:ring-offset-2 focus-visible:ring-offset-[#0a0a0a]"
    >
      {/* Image with diagonal hatch fallback */}
      <div
        className="relative overflow-hidden aspect-square"
        style={{ background: "rgba(0,0,0,0.3)" }}
      >
        {exercise.image ? (
          <Image
            src={exercise.image}
            alt={exercise.name}
            fill
            sizes="(max-width: 768px) 33vw, 25vw"
            className="object-cover group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        ) : (
          <div
            className="absolute inset-0 flex items-center justify-center"
            style={{
              background: "rgba(0,0,0,0.4)",
              backgroundImage: "repeating-linear-gradient(45deg, rgba(194,65,12,0.08) 0px, rgba(194,65,12,0.08) 1px, transparent 1px, transparent 8px)",
            }}
          >
            <span
              className="font-data text-[24px] text-[#444]"
              aria-hidden="true"
            >
              ▶
            </span>
          </div>
        )}
        {/* Target muscle badge */}
        {exercise.target && (
          <div
            className="absolute top-2 right-2 px-2 py-1 font-data text-[9px] uppercase tracking-widest"
            style={{
              background: "rgba(194,65,12,0.9)",
              color: "#fff",
            }}
          >
            {exercise.target}
          </div>
        )}
      </div>

      {/* Name + tags */}
      <div className="p-4">
        <p className="font-heading text-sm font-bold uppercase text-[#f0f0f0] leading-tight group-hover:text-[#e53e00] transition-colors line-clamp-2 min-h-[2.5em]">
          {exercise.name}
        </p>
        <div className="flex flex-wrap gap-1.5 mt-2">
          {exercise.bodyPart && (
            <span className="tag-pill text-[10px]">{exercise.bodyPart.toUpperCase()}</span>
          )}
          {exercise.equipment && (
            <span className="tag-pill text-[10px]">{exercise.equipment.toUpperCase()}</span>
          )}
        </div>
      </div>
    </Link>
  );
}

function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "shrink-0 px-3 py-1.5 font-data text-[10px] uppercase tracking-widest transition-all border",
        active
          ? "bg-[#C2410C] text-white border-[#C2410C]"
          : "border-[rgba(255,255,255,0.06)] text-[#71717A] hover:border-[rgba(255,255,255,0.12)] hover:text-[#a3a3a3]",
      )}
      aria-pressed={active}
    >
      {label}
    </button>
  );
}

export function ExerciseLibrary({ filters }: Props) {
  const { language, t } = useI18n();
  const translationNames = useAllExerciseTranslationNames();
  const [allExercises, setAllExercises] = useState<LibraryExercise[] | null>(null);
  const [displayCount, setDisplayCount] = useState(PAGINATION_SIZE);
  const [rawQ, setRawQ] = useState("");
  const [q, setQ] = useState("");
  const [bodyPart, setBodyPart] = useState("");
  const [equipment, setEquipment] = useState("");
  const [target, setTarget] = useState("");
  const [isLoading, setIsLoading] = useState(true);

  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    getAllExercises()
      .then((data) => {
        setAllExercises(data);
        setIsLoading(false);
      })
      .catch(() => setIsLoading(false));
  }, []);

  const handleQueryChange = useCallback((val: string) => {
    setRawQ(val);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => setQ(val.trim()), 150);
  }, []);

  const filteredExercises = useMemo(() => {
    if (!allExercises) return [];
    const lowerQ = q.toLowerCase();
    return allExercises.filter((ex) => {
      if (lowerQ) {
        const translatedName = translationNames.get(ex.exerciseId)?.toLowerCase();
        const matchesEn = ex.name.toLowerCase().includes(lowerQ);
        const matchesTranslated = translatedName?.includes(lowerQ) ?? false;
        if (!matchesEn && !matchesTranslated) return false;
      }
      if (bodyPart && ex.bodyPart !== bodyPart) return false;
      if (equipment && ex.equipment !== equipment) return false;
      if (target && ex.target !== target) return false;
      return true;
    });
  }, [allExercises, q, bodyPart, equipment, target, translationNames]);

  useEffect(() => {
    setDisplayCount(PAGINATION_SIZE);
  }, [q, bodyPart, equipment, target]);

  const displayedSlice = useMemo(
    () => filteredExercises.slice(0, displayCount),
    [filteredExercises, displayCount],
  );

  const visibleExtIds = useMemo(
    () => displayedSlice.map((ex) => ex.exerciseId),
    [displayedSlice],
  );

  const { data: translations } = useExercisesBatchTranslation(visibleExtIds);

  const displayedExercises = useMemo(() => {
    if (language === "en") return displayedSlice;
    return displayedSlice.map((ex) => {
      const tr = translations.get(ex.exerciseId);
      const merged = applyTranslationToLibraryExercise(ex, tr);
      return {
        ...merged,
        bodyPart: tr?.bodyPart || tBodyPart(ex.bodyPart, language) || ex.bodyPart,
        equipment: tr?.equipment || tEquipment(ex.equipment, language) || ex.equipment,
        target: tr?.target || tMuscle(ex.target, language) || ex.target,
      };
    });
  }, [displayedSlice, translations, language]);

  const hasMore = displayedSlice.length < filteredExercises.length;

  return (
    <div className="space-y-4 fade-up fade-up-1">
      {/* Search bar */}
      <div className="glass-acc relative flex items-center h-10">
        <Search className="absolute left-3 h-4 w-4 text-[#C2410C] pointer-events-none" />
        <input
          type="search"
          value={rawQ}
          onChange={(e) => handleQueryChange(e.target.value)}
          placeholder={t("library.SEARCH")}
          aria-label="Search exercises"
          className="w-full h-full bg-transparent pl-10 pr-4 font-heading text-[13px] uppercase text-[#f0f0f0] placeholder:text-[#525252] focus:outline-none"
        />
      </div>

      {/* Filters */}
      <div className="space-y-3">
        {/* Active filters display */}
        {(bodyPart || equipment || target) && (
          <div className="flex items-center gap-2 flex-wrap">
            <span className="font-data text-[9px] text-[#525252] uppercase tracking-widest">{t("library.ACTIVE_FILTERS")}:</span>
            {bodyPart && (
              <button
                onClick={() => setBodyPart("")}
                className="px-2 py-0.5 font-data text-[9px] uppercase tracking-widest border border-[#C2410C] text-[#C2410C] hover:bg-[#C2410C] hover:text-white transition-colors"
              >
                {tBodyPart(bodyPart, language).toUpperCase()} ×
              </button>
            )}
            {equipment && (
              <button
                onClick={() => setEquipment("")}
                className="px-2 py-0.5 font-data text-[9px] uppercase tracking-widest border border-[#C2410C] text-[#C2410C] hover:bg-[#C2410C] hover:text-white transition-colors"
              >
                {tEquipment(equipment, language).toUpperCase()} ×
              </button>
            )}
            {target && (
              <button
                onClick={() => setTarget("")}
                className="px-2 py-0.5 font-data text-[9px] uppercase tracking-widest border border-[#C2410C] text-[#C2410C] hover:bg-[#C2410C] hover:text-white transition-colors"
              >
                {tMuscle(target, language).toUpperCase()} ×
              </button>
            )}
            <button
              onClick={() => { setBodyPart(""); setEquipment(""); setTarget(""); }}
              className="font-data text-[8px] text-[#525252] hover:text-[#e53e00] uppercase tracking-widest underline"
            >
              {t("library.CLEAR_ALL")}
            </button>
          </div>
        )}

        <div
          className="flex gap-2 overflow-x-auto pb-1 scroll-forge"
          role="group"
          aria-label={t("library.FILTER_BODY_PART")}
        >
          <FilterChip label={t("library.ALL")} active={bodyPart === ""} onClick={() => setBodyPart("")} />
          {filters.bodyParts.map((bp) => (
            <FilterChip
              key={bp}
              label={tBodyPart(bp, language).toUpperCase()}
              active={bodyPart === bp}
              onClick={() => setBodyPart(bodyPart === bp ? "" : bp)}
            />
          ))}
        </div>

        <div
          className="flex gap-2 overflow-x-auto pb-1 scroll-forge"
          role="group"
          aria-label={t("library.FILTER_EQUIPMENT")}
        >
          <FilterChip label={t("library.ANY_EQUIP")} active={equipment === ""} onClick={() => setEquipment("")} />
          {filters.equipment.map((eq) => (
            <FilterChip
              key={eq}
              label={tEquipment(eq, language).toUpperCase()}
              active={equipment === eq}
              onClick={() => setEquipment(equipment === eq ? "" : eq)}
            />
          ))}
        </div>

        <div
          className="flex gap-2 overflow-x-auto pb-1 scroll-forge"
          role="group"
          aria-label={t("library.FILTER_MUSCLE")}
        >
          <FilterChip label={t("library.ALL_MUSCLES")} active={target === ""} onClick={() => setTarget("")} />
          {filters.targets.map((tgt) => (
            <FilterChip
              key={tgt}
              label={tMuscle(tgt, language).toUpperCase()}
              active={target === tgt}
              onClick={() => setTarget(target === tgt ? "" : tgt)}
            />
          ))}
        </div>
      </div>

      {/* Result count */}
      {!isLoading && allExercises !== null && (
        <div className="flex items-center gap-2">
          <div className="h-px flex-1 bg-[rgba(255,255,255,0.04)]" />
          <span className="font-data text-[9px] text-[#525252] tracking-widest uppercase">
            {displayedSlice.length} / {filteredExercises.length} {t("library.RESULTS")}
          </span>
          <div className="h-px flex-1 bg-[rgba(255,255,255,0.04)]" />
        </div>
      )}

      {/* Exercise grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 pb-24 md:pb-0">
          {Array.from({ length: 12 }).map((_, i) => (
            <GridSkeleton key={i} />
          ))}
        </div>
      ) : displayedExercises.length === 0 ? (
        <div className="glass flex flex-col items-center justify-center py-20 gap-4">
          <span className="font-data text-[14px] tracking-[0.3em] text-[#525252] uppercase">
            {t("library.NO_RESULTS")}
          </span>
          <span className="font-data text-[10px] text-[#444] tracking-[0.2em] uppercase">
            {t("library.NO_RESULTS_DESC")}
          </span>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 pb-24 md:pb-0">
            {displayedExercises.map((ex) => (
              <ExerciseCard key={ex.id} exercise={ex} noImgLabel={t("library.NO_IMG")} />
            ))}
          </div>

          {hasMore && (
            <div className="flex justify-center pt-4">
              <button
                onClick={() => setDisplayCount((c) => c + PAGINATION_SIZE)}
                className="btn-forge px-6 py-2.5 text-[10px]"
              >
                {t("library.LOAD_MORE")}
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
