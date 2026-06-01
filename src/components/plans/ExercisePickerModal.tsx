"use client";

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import Image from "next/image";
import { Search, X, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import type { LibraryExercise } from "@/types/exercise";
import { getAllExercises } from "@/lib/exercise-library";
import { useI18n } from "@/components/providers/I18nProvider";
import { useExercisesBatchTranslation, useAllExerciseTranslationNames } from "@/hooks/useExerciseTranslation";
import { applyTranslationToLibraryExercise } from "@/lib/exercise-translate";
import { tBodyPart, tEquipment } from "@/lib/exercise-taxonomy";

interface Props {
  open: boolean;
  onClose: () => void;
  onSelect: (exercise: LibraryExercise) => void;
}

const BODY_PARTS = [
  "back", "cardio", "chest", "lower arms", "lower legs",
  "neck", "shoulders", "upper arms", "upper legs", "waist",
];

export function ExercisePickerModal({ open, onClose, onSelect }: Props) {
  const { t, language } = useI18n();
  const translationNames = useAllExerciseTranslationNames();
  const [allExercises, setAllExercises] = useState<LibraryExercise[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [rawQ, setRawQ] = useState("");
  const [q, setQ] = useState("");
  const [bodyPart, setBodyPart] = useState("");
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (!open || allExercises.length > 0) return;
    setIsLoading(true);
    getAllExercises()
      .then(setAllExercises)
      .finally(() => setIsLoading(false));
  }, [open, allExercises.length]);

  const handleQueryChange = useCallback((val: string) => {
    setRawQ(val);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => setQ(val.trim().toLowerCase()), 150);
  }, []);

  // Filter by English name OR translated name, then slice for display
  const filtered = useMemo(() => {
    let list = allExercises;
    if (bodyPart) list = list.filter((ex) => ex.bodyPart === bodyPart);
    if (q) {
      list = list.filter((ex) => {
        const translatedName = translationNames.get(ex.exerciseId)?.toLowerCase();
        return ex.name.toLowerCase().includes(q) || (translatedName?.includes(q) ?? false);
      });
    }
    return list.slice(0, 60);
  }, [allExercises, bodyPart, q, translationNames]);

  // Batch-fetch translations for the visible slice
  const visibleIds = useMemo(() => filtered.map((ex) => ex.exerciseId), [filtered]);
  const { data: translations } = useExercisesBatchTranslation(visibleIds);

  // Apply translations to displayed names only; original data stays English for storage
  const displayedExercises = useMemo(() => {
    if (language === "en") return filtered;
    return filtered.map((ex) => {
      const tr = translations.get(ex.exerciseId);
      return applyTranslationToLibraryExercise(ex, tr);
    });
  }, [filtered, translations, language]);

  const handleSelect = (original: LibraryExercise) => {
    onSelect(original);
    onClose();
  };

  useEffect(() => {
    if (!open) {
      setRawQ("");
      setQ("");
      setBodyPart("");
    }
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/80 p-0 sm:p-4"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <div className="relative flex h-[95svh] sm:h-[90svh] md:h-[80vh] w-full sm:max-w-2xl flex-col border border-[#2a2a2a] bg-[#0a0a0a] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-[#2a2a2a] px-4 py-3 shrink-0">
          <span className="font-data text-[10px] font-bold uppercase tracking-widest text-[#e53e00]">
            {t("planForm.SELECT_EXERCISE")}
          </span>
          <button
            onClick={onClose}
            className="text-[#71717A] hover:text-[#E5E5E5] transition-colors"
            aria-label={t("common.CLOSE")}
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Search */}
        <div className="relative border-b border-[#2a2a2a] shrink-0">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#525252] pointer-events-none" />
          <input
            autoFocus
            type="search"
            value={rawQ}
            onChange={(e) => handleQueryChange(e.target.value)}
            placeholder={t("planForm.SEARCH_EXERCISE")}
            className="w-full bg-transparent pl-11 pr-4 py-3 font-data text-[11px] uppercase tracking-widest text-[#e5e5e5] placeholder:text-[#525252] focus:outline-none"
          />
        </div>

        {/* Body part filter chips */}
        <div className="flex gap-2 overflow-x-auto px-4 py-2 border-b border-[#2a2a2a] shrink-0 scrollbar-custom">
          <FilterChip label={t("library.ALL")} active={bodyPart === ""} onClick={() => setBodyPart("")} />
          {BODY_PARTS.map((bp) => (
            <FilterChip
              key={bp}
              label={tBodyPart(bp, language).toUpperCase()}
              active={bodyPart === bp}
              onClick={() => setBodyPart(bodyPart === bp ? "" : bp)}
            />
          ))}
        </div>

        {/* Results */}
        <div className="flex-1 overflow-y-auto">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-16 gap-3">
              <div className="h-5 w-5 animate-spin rounded-full border-2 border-[#e53e00] border-t-transparent" />
              <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
                {t("common.LOADING")}
              </span>
            </div>
          ) : displayedExercises.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 gap-2">
              <span className="font-data text-[11px] uppercase tracking-widest text-[#525252]">
                {t("library.NO_RESULTS")}
              </span>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-px bg-[#1a1a1a]">
              {displayedExercises.map((ex, i) => {
                const original = filtered[i];
                return (
                  <button
                    key={original.id}
                    type="button"
                    onClick={() => handleSelect(original)}
                    className="group flex flex-col bg-[#0a0a0a] text-left hover:bg-[#111] transition-colors relative"
                  >
                    {/* Image */}
                    <div className="relative aspect-square sm:aspect-video w-full overflow-hidden bg-[#111]">
                      {original.image ? (
                        <Image
                          src={original.gif || original.image}
                          alt={ex.name}
                          fill
                          sizes="(max-width: 640px) 50vw, 33vw"
                          className="object-cover"
                          loading="lazy"
                          unoptimized={original.gif?.endsWith(".gif")}
                        />
                      ) : (
                        <div className="absolute inset-0 flex items-center justify-center">
                          <span className="font-data text-[8px] uppercase tracking-widest text-[#525252]">
                            {t("library.NO_IMG")}
                          </span>
                        </div>
                      )}
                      <div className="absolute inset-0 bg-gradient-to-t from-[#0a0a0a]/70 to-transparent pointer-events-none" />
                      <div className="absolute right-2 bottom-2 opacity-0 group-hover:opacity-100 transition-opacity bg-[#e53e00] p-1">
                        <ChevronRight className="h-3 w-3 text-white" />
                      </div>
                    </div>

                    {/* Info */}
                    <div className="p-2.5 flex-1">
                      <p className="font-data text-[10px] font-bold uppercase tracking-wide text-[#e5e5e5] line-clamp-2 group-hover:text-[#e53e00] transition-colors leading-tight mb-1">
                        {ex.name}
                      </p>
                      <div className="flex flex-wrap gap-1">
                        {original.bodyPart && (
                          <span className="px-1 py-0.5 border border-[#2a2a2a] font-data text-[7px] uppercase tracking-widest text-[#71717A]">
                            {tBodyPart(original.bodyPart, language)}
                          </span>
                        )}
                        {original.equipment && (
                          <span className="px-1 py-0.5 border border-[#2a2a2a] font-data text-[7px] uppercase tracking-widest text-[#525252]">
                            {tEquipment(original.equipment, language)}
                          </span>
                        )}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </div>

        {/* Footer count */}
        {!isLoading && displayedExercises.length > 0 && (
          <div className="border-t border-[#2a2a2a] px-4 py-2 shrink-0">
            <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
              {displayedExercises.length} {t("library.RESULTS")}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}

function FilterChip({ label, active, onClick }: { label: string; active: boolean; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "shrink-0 px-2.5 py-1 font-data text-[9px] font-semibold uppercase tracking-widest transition-all border",
        active
          ? "border-[#e53e00] text-[#e53e00] bg-[#e53e00]/10"
          : "border-[#2a2a2a] text-[#71717A] hover:border-[#525252] hover:text-[#a3a3a3]",
      )}
    >
      {label}
    </button>
  );
}
