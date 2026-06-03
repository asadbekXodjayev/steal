"use client";

import { useEffect, useMemo, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Play, Pause, ExternalLink, ImageOff } from "lucide-react";
import { findExerciseByName } from "@/lib/exercise-library";
import { cn } from "@/lib/utils";
import type { LibraryExercise } from "@/types/exercise";
import { useExerciseTranslation } from "@/hooks/useExerciseTranslation";
import { applyTranslationToLibraryExercise } from "@/lib/exercise-translate";
import { useI18n } from "@/components/providers/I18nProvider";

interface Props {
  exerciseName: string;
  size?: "thumb" | "card" | "hero";
  className?: string;
}

type LoadState = "loading" | "found" | "not-found";

export function ExerciseMedia({ exerciseName, size = "card", className }: Props) {
  const { t } = useI18n();
  const [baseMatch, setBaseMatch] = useState<LibraryExercise | null>(null);
  const [loadState, setLoadState] = useState<LoadState>("loading");
  const [playing, setPlaying] = useState(false);

  useEffect(() => {
    let cancelled = false;
    setLoadState("loading");
    setPlaying(false);

    findExerciseByName(exerciseName).then((result) => {
      if (cancelled) return;
      setBaseMatch(result);
      setLoadState(result ? "found" : "not-found");
    });

    return () => {
      cancelled = true;
    };
  }, [exerciseName]);

  const { data: translation } = useExerciseTranslation(baseMatch?.exerciseId);

  const match = useMemo(() => {
    if (!baseMatch) return null;
    return applyTranslationToLibraryExercise(baseMatch, translation ?? null);
  }, [baseMatch, translation]);

  if (size === "thumb") {
    if (loadState === "loading") {
      return (
        <div
          className={cn(
            "h-12 w-12 shrink-0 bg-[#1a1a1a] border border-[#2a2a2a] animate-pulse",
            className,
          )}
          aria-hidden="true"
        />
      );
    }

    if (loadState === "not-found" || !match) {
      return (
        <div
          className={cn(
            "h-12 w-12 shrink-0 bg-[#0a0a0a] border border-[#2a2a2a] flex items-center justify-center",
            className,
          )}
          aria-hidden="true"
        >
          <ImageOff className="h-4 w-4 text-[#525252]" />
        </div>
      );
    }

    return (
      <Link
        href={`/exercises/${match.slug}`}
        aria-label={t("exerciseMedia.VIEW_TUTORIAL_FOR").replace("{name}", match.name)}
        className={cn(
          "relative h-12 w-12 shrink-0 block overflow-hidden border border-[#2a2a2a] bg-[#0a0a0a] hover:border-[#e53e00]/50 transition-colors",
          className,
        )}
      >
        <Image
          src={match.image}
          alt={match.name}
          fill
          sizes="48px"
          className="object-cover"
        />
      </Link>
    );
  }

  const isHero = size === "hero";

  if (loadState === "loading") {
    return (
      <div
        className={cn(
          "w-full bg-[#1a1a1a] border border-[#2a2a2a] animate-pulse",
          isHero ? "aspect-video" : "aspect-video max-w-[240px]",
          className,
        )}
        aria-hidden="true"
      />
    );
  }

  if (loadState === "not-found" || !match) {
    return (
      <div
        className={cn(
          "w-full bg-[#0a0a0a] border border-[#2a2a2a] flex flex-col items-center justify-center gap-2",
          isHero ? "aspect-video" : "aspect-video max-w-[240px]",
          className,
        )}
      >
        <ImageOff className="h-5 w-5 text-[#525252]" />
        <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
          {t("exerciseMedia.NO_TUTORIAL")}
        </span>
      </div>
    );
  }

  return (
    <div
      className={cn(
        "w-full bg-[#0a0a0a] border border-[#2a2a2a] overflow-hidden",
        isHero ? "aspect-video" : "aspect-video max-w-[240px]",
        className,
      )}
    >
      <div className="relative w-full h-full">
        {playing ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={match.gif}
            alt={`${match.name} animation`}
            loading="lazy"
            className="w-full h-full object-cover"
          />
        ) : (
          <Image
            src={match.image}
            alt={match.name}
            fill
            sizes={isHero ? "100vw" : "240px"}
            className="object-cover"
          />
        )}

        {/* h-10 w-10 on mobile (≥44px touch target), h-8 w-8 at sm+ */}
        <button
          type="button"
          onClick={() => setPlaying((p) => !p)}
          aria-label={playing ? t("workout.PAUSE_ANIMATION") : t("workout.PLAY_ANIMATION")}
          className="absolute bottom-2 right-2 flex h-10 w-10 sm:h-8 sm:w-8 items-center justify-center bg-[#e53e00] hover:bg-[#ff4500] text-white transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-[#e53e00] focus-visible:outline-offset-2"
        >
          {playing ? (
            <Pause className="h-3.5 w-3.5" />
          ) : (
            <Play className="h-3.5 w-3.5" />
          )}
        </button>
      </div>

      <div className="border-t border-[#2a2a2a] px-3 py-1.5 flex items-center justify-between bg-[#0a0a0a]">
        <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
          {t("exerciseMedia.TUTORIAL_LABEL")}
        </span>
        <Link
          href={`/exercises/${match.slug}`}
          className="flex items-center gap-1 font-data text-[9px] uppercase tracking-widest text-[#e53e00] hover:text-[#ff4500] transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-[#e53e00]"
          aria-label={t("exerciseMedia.VIEW_FULL_TUTORIAL_FOR").replace("{name}", match.name)}
        >
          {t("exerciseMedia.VIEW_FULL_TUTORIAL")}
          <ExternalLink className="h-3 w-3" />
        </Link>
      </div>
    </div>
  );
}
