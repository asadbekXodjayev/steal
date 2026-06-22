"use client";

import { useEffect, useState, useCallback } from "react";
import { cn } from "@/lib/utils";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

interface PlanImageCarouselProps {
  imageUrls: string[];
  className?: string;
  autoSlideInterval?: number;
  showNavigation?: boolean;
  showIndicators?: boolean;
}

/**
 * PlanImageCarousel — Auto-sliding image carousel for workout plans
 * 
 * Features:
 * - Auto-sliding images with configurable interval
 * - Manual navigation with prev/next buttons
 * - Click indicators for direct navigation
 * - Pause on hover
 * - Fallback placeholder if no images
 */
export function PlanImageCarousel({
  imageUrls,
  className,
  autoSlideInterval = 4000,
  showNavigation = true,
  showIndicators = true,
}: PlanImageCarouselProps) {
  const { t } = useI18n();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isTransitioning, setIsTransitioning] = useState(false);

  // Auto-slide effect
  useEffect(() => {
    if (imageUrls.length <= 1 || isPaused) return;

    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % imageUrls.length);
    }, autoSlideInterval);

    return () => clearInterval(interval);
  }, [imageUrls.length, autoSlideInterval, isPaused]);

  const goToSlide = useCallback((index: number) => {
    if (isTransitioning || index === currentIndex) return;
    setIsTransitioning(true);
    setCurrentIndex(index);
    setTimeout(() => setIsTransitioning(false), 300);
  }, [currentIndex, isTransitioning]);

  const goToPrevious = useCallback(() => {
    goToSlide(currentIndex === 0 ? imageUrls.length - 1 : currentIndex - 1);
  }, [currentIndex, imageUrls.length, goToSlide]);

  const goToNext = useCallback(() => {
    goToSlide(currentIndex === imageUrls.length - 1 ? 0 : currentIndex + 1);
  }, [currentIndex, imageUrls.length, goToSlide]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft") goToPrevious();
      if (e.key === "ArrowRight") goToNext();
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [goToPrevious, goToNext]);

  if (!imageUrls || imageUrls.length === 0) {
    return (
      <div className={cn("relative aspect-video bg-[#1a1a1a] flex items-center justify-center", className)}>
        <div className="text-center">
          <div className="w-16 h-16 mx-auto mb-3 border-2 border-[#e53e00] border-dashed rounded-full flex items-center justify-center">
            <span className="text-[#e53e00] text-2xl">💪</span>
          </div>
          <p className="font-data text-[10px] uppercase tracking-widest text-[#525252]">
            {t("programs.NO_IMAGES")}
          </p>
        </div>
      </div>
    );
  }

  const currentImage = imageUrls[currentIndex];

  return (
    <div
      className={cn("relative overflow-hidden bg-[#1a1a1a]", className)}
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      {/* Image container */}
      <div className="relative aspect-video">
        {imageUrls.map((url, index) => (
          <div
            key={index}
            className={cn(
              "absolute inset-0 transition-opacity duration-300",
              index === currentIndex ? "opacity-100" : "opacity-0",
            )}
          >
            <img
              src={url}
              alt={`Plan image ${index + 1}`}
              className="w-full h-full object-cover"
              loading="lazy"
              decoding="async"
            />
            {/* Gradient overlay for text readability */}
            <div className="absolute inset-0 bg-gradient-to-t from-[#0a0a0a]/80 via-transparent to-[#0a0a0a]/30" />
          </div>
        ))}
      </div>

      {/* Navigation arrows */}
      {showNavigation && imageUrls.length > 1 && (
        <>
          <button
            onClick={goToPrevious}
            className="absolute left-2 top-1/2 -translate-y-1/2 z-10 p-2.5 sm:p-2 bg-[#0a0a0a] hover:bg-[#e53e00] transition-colors border border-[#2a2a2a] hover:border-[#e53e00]"
            aria-label={t("common.PREVIOUS_IMAGE")}
          >
            <ChevronLeft className="h-5 w-5 sm:h-4 sm:w-4 text-[#e5e5e5]" />
          </button>
          <button
            onClick={goToNext}
            className="absolute right-2 top-1/2 -translate-y-1/2 z-10 p-2.5 sm:p-2 bg-[#0a0a0a] hover:bg-[#e53e00] transition-colors border border-[#2a2a2a] hover:border-[#e53e00]"
            aria-label={t("common.NEXT_IMAGE")}
          >
            <ChevronRight className="h-5 w-5 sm:h-4 sm:w-4 text-[#e5e5e5]" />
          </button>
        </>
      )}

      {/* Slide counter */}
      {imageUrls.length > 1 && (
        <div className="absolute top-2 sm:top-3 right-2 sm:right-3 z-10 bg-[#0a0a0a] border border-[#2a2a2a] px-2 py-1">
          <span className="font-data text-[9px] uppercase tracking-widest text-[#71717A]">
            {String(currentIndex + 1).padStart(2, "0")} / {String(imageUrls.length).padStart(2, "0")}
          </span>
        </div>
      )}

      {/* Indicators */}
      {showIndicators && imageUrls.length > 1 && (
        <div className="absolute bottom-3 left-1/2 -translate-x-1/2 z-10 flex gap-1.5">
          {imageUrls.map((_, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className={cn(
                "transition-all duration-200",
                index === currentIndex
                  ? "w-6 bg-[#e53e00]"
                  : "w-2 bg-[#525252] hover:bg-[#71717A]",
              )}
              aria-label={t("programs.GO_TO_SLIDE").replace("{n}", String(index + 1))}
            />
          ))}
        </div>
      )}

      {/* Pause indicator */}
      {isPaused && imageUrls.length > 1 && (
        <div className="absolute top-3 left-3 z-10 bg-[#0a0a0a] border border-[#2a2a2a] px-2 py-1">
          <span className="font-data text-[8px] uppercase tracking-widest text-[#10b981]">
            {t("programs.PAUSED_INDICATOR")}
          </span>
        </div>
      )}
    </div>
  );
}