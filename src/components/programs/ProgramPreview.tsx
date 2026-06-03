"use client";

import { useState } from "react";
import type { ProgramTemplateDefinition } from "@/types/plan";
import { getExerciseForWeek } from "@/lib/program-templates";
import { BrandNoiseOverlay } from "@/components/layout/BrandNoiseOverlay";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  Dumbbell, 
  Clock, 
  Target, 
  ChevronRight, 
  Flame,
  CheckCircle2,
  AlertCircle,
  Info
} from "lucide-react";
import { cn } from "@/lib/utils";
import { PlanImageCarousel } from "@/components/programs/PlanImageCarousel";
import { useI18n } from "@/components/providers/I18nProvider";

interface ProgramPreviewProps {
  program: ProgramTemplateDefinition;
  onActivate: (program: ProgramTemplateDefinition) => void;
  onBack: () => void;
  activating?: boolean;
}

export function ProgramPreview({
  program,
  onActivate,
  onBack,
  activating
}: ProgramPreviewProps) {
  const { t } = useI18n();
  const [selectedWeek, setSelectedWeek] = useState(1);

  const difficultyConfig = {
    Beginner: { border: "border-[#C2410C]/40", text: "text-[#C2410C]", bg: "bg-[#C2410C]/5" },
    Intermediate: { border: "border-[#71717A]/40", text: "text-[#71717A]", bg: "bg-[#71717A]/5" },
    Advanced: { border: "border-[#8B0000]/40", text: "text-[#8B0000]", bg: "bg-[#8B0000]/5" },
    Elite: { border: "border-[#C2410C]/40", text: "text-[#C2410C]", bg: "bg-[#C2410C]/5" },
  };

  const config = difficultyConfig[program.difficulty];

  // Get the current week's structure
  const currentWeekDays = program.weeklyStructure.days;

  return (
    <div className="space-y-6 py-6">
      {/* Back button */}
      <Button
        variant="ghost"
        onClick={onBack}
        className="rounded-none font-data text-xs uppercase tracking-widest text-muted-foreground hover:text-foreground hover:bg-muted"
      >
        {t("programs.BACK_BTN")}
      </Button>

      {/* Hero Header */}
      <div className="relative border border-card-border bg-card overflow-hidden">
        <BrandNoiseOverlay />
        
        {/* Image carousel */}
        {program.imageUrls && program.imageUrls.length > 0 && (
          <PlanImageCarousel
            imageUrls={program.imageUrls}
            className="aspect-[21/9]"
            autoSlideInterval={5000}
            showNavigation={true}
            showIndicators={true}
          />
        )}

        <div className="relative z-10 p-6">
          {/* Badge row */}
          <div className="flex items-center gap-2 mb-3">
            <Badge
              variant="outline"
              className={cn(
                "rounded-none border font-data text-[10px] uppercase tracking-widest",
                config.border,
                config.text,
              )}
            >
              {program.difficulty}
            </Badge>
            <Badge
              variant="outline"
              className="rounded-none border border-card-border font-data text-[10px] uppercase tracking-widest text-muted-foreground"
            >
              <Clock className="mr-1 h-2.5 w-2.5" />
              {t("programs.ONE_WEEK_CHALLENGE_BADGE")}
            </Badge>
            <Badge
              variant="outline"
              className="rounded-none border border-card-border font-data text-[10px] uppercase tracking-widest text-muted-foreground"
            >
              <Dumbbell className="mr-1 h-2.5 w-2.5" />
              {program.daysPerWeek}
            </Badge>
          </div>

          {/* Title */}
          <h1
            className="text-3xl sm:text-4xl font-black uppercase tracking-tight text-[#e5e5e5]"
            style={{ fontFamily: "var(--font-heading, system-ui)" }}
          >
            {program.title}
          </h1>
          
          {/* Subtitle */}
          <p className="mt-2 font-data text-sm font-semibold uppercase tracking-widest text-[#e53e00]">
            {program.subtitle}
          </p>

          {/* Tagline */}
          <p className="mt-3 text-sm text-[#a3a3a3]">
            {program.tagline}
          </p>

          {/* Description */}
          <p className="mt-4 max-w-2xl text-sm leading-relaxed text-[#71717A]">
            {program.description}
          </p>

          {/* Tags */}
          <div className="mt-4 flex flex-wrap gap-1.5">
            {program.tags.map((tag) => (
              <span
                key={tag}
                className="bg-muted px-2 py-0.5 font-data text-[9px] uppercase tracking-widest text-muted-foreground"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* One-Week Challenge Info */}
      <div className="border border-secondary/30 bg-secondary/5 p-4">
        <div className="flex items-start gap-3">
          <div className="bg-secondary/20 p-1.5 rounded-sm">
            <Flame className="h-4 w-4 text-secondary" />
          </div>
          <div className="flex-1">
            <h3 className="font-data text-xs font-bold uppercase tracking-widest text-secondary">
              {t("programs.ONE_WEEK_CHALLENGE_TITLE")}
            </h3>
            <p className="mt-1 text-sm text-muted-foreground">
              {t("programs.ONE_WEEK_CHALLENGE_DESC").replace("{n}", String(program.weeklyStructure.rotationLength))}
            </p>
          </div>
        </div>
      </div>

      {/* Week Selector */}
      <div className="space-y-3">
        <div className="flex items-center gap-4">
          <div className="h-px flex-1 bg-[#2a2a2a]" />
          <span className="font-data text-[10px] uppercase tracking-widest text-[#71717A]">
            {t("programs.SELECT_WEEK_HEADING")}
          </span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>

        <div className="flex gap-2 overflow-x-auto pb-2">
          {Array.from({ length: program.weeklyStructure.rotationLength }, (_, i) => i + 1).map((week) => (
            <button
              key={week}
              onClick={() => setSelectedWeek(week)}
              className={cn(
                "flex-shrink-0 px-4 py-2 border font-data text-xs font-bold uppercase tracking-widest transition-all",
                selectedWeek === week
                  ? "bg-primary border-primary text-primary-foreground"
                  : "bg-card border-card-border text-muted-foreground hover:border-primary/50 hover:text-primary"
              )}
            >
              {t("programs.WEEK_BTN").replace("{n}", String(week))}
            </button>
          ))}
        </div>
      </div>

      {/* Week Structure */}
      <div className="space-y-4">
        <div className="flex items-center gap-4">
          <div className="h-px flex-1 bg-[#2a2a2a]" />
          <span className="font-data text-[10px] uppercase tracking-widest text-[#71717A]">
            {t("programs.WEEK_SCHEDULE_HEADING").replace("{n}", String(selectedWeek))}
          </span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>

        {currentWeekDays
          .sort((a, b) => a.dayOfWeek - b.dayOfWeek)
          .map((day) => (
            <div key={day.dayOfWeek} className="border border-card-border bg-card overflow-hidden">
              {/* Day Header */}
              <div className="border-b border-card-border p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <span className="font-data text-[10px] font-bold uppercase tracking-widest text-[#e53e00]">
                      {t(`daysOfWeek.${(["MON","TUE","WED","THU","FRI","SAT","SUN"] as const)[day.dayOfWeek - 1]}`)}
                    </span>
                    <h3 className="mt-1 font-data text-sm font-bold uppercase tracking-wide text-[#e5e5e5]">
                      {day.label}
                    </h3>
                    {Array.isArray(day.focus) && day.focus.length > 0 && (
                      <div className="mt-1.5 flex gap-1">
                        {day.focus.map((muscle) => (
                          <span
                            key={muscle}
                            className="px-1.5 py-0.5 border border-[#2a2a2a] font-data text-[8px] uppercase tracking-widest text-[#71717A]"
                          >
                            {muscle}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-1 text-[#71717A]">
                    <Dumbbell className="h-4 w-4" />
                    <span className="font-data text-xs font-bold text-[#a3a3a3]">
                      {t("programs.EXERCISES_COUNT").replace("{n}", String(day.exercises.length))}
                    </span>
                  </div>
                </div>
              </div>

              {/* Exercises */}
              <div className="p-4">
                <div className="space-y-2">
                  {day.exercises.map((exercise, idx) => {
                    const exerciseData = getExerciseForWeek(exercise.primary, selectedWeek);
                    return (
                      <div
                        key={idx}
                        className="flex items-start gap-3 p-3 border border-card-border bg-surface-2"
                      >
                        <span className="font-data text-[10px] text-[#525252] w-6 shrink-0 text-center">
                          {String(idx + 1).padStart(2, "0")}
                        </span>
                        <div className="flex-1 min-w-0">
                          <p className="font-data text-sm font-bold uppercase tracking-wide text-[#e5e5e5] truncate">
                            {exerciseData.name}
                          </p>
                          <div className="mt-1 flex flex-wrap items-center gap-3">
                            <span className="font-data text-[10px] text-[#71717A]">
                              <Target className="inline h-3 w-3 mr-0.5" />
                              {exerciseData.sets} {t("programs.SETS_INLINE")}
                            </span>
                            <span className="font-data text-[10px] text-[#71717A]">
                              <Dumbbell className="inline h-3 w-3 mr-0.5" />
                              {exerciseData.repsMin}-{exerciseData.repsMax} {t("programs.REPS_INLINE")}
                            </span>
                            <span className="font-data text-[10px] text-[#71717A]">
                              <Clock className="inline h-3 w-3 mr-0.5" />
                              {Math.floor(exerciseData.restSeconds / 60)}:{String(exerciseData.restSeconds % 60).padStart(2, "0")} {t("programs.REST_INLINE")}
                            </span>
                          </div>
                          {exerciseData.notes && (
                            <p className="mt-1.5 font-data text-[9px] text-[#525252]">
                              {exerciseData.notes}
                            </p>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Warmup/Cooldown */}
                {(day.warmup || day.cooldown) && (
                  <div className="mt-4 pt-4 border-t border-[#2a2a2a]">
                    {day.warmup && (
                      <div className="mb-3">
                        <span className="font-data text-[9px] uppercase tracking-widest text-[#10b981]">
                          {t("programs.WARMUP_LABEL")}
                        </span>
                        <div className="mt-1 space-y-1">
                          {day.warmup.exercises.map((ex, i) => (
                            <p key={i} className="font-data text-[9px] text-[#71717A]">
                              • {ex.name} — {ex.duration}
                            </p>
                          ))}
                        </div>
                      </div>
                    )}
                    {day.cooldown && (
                      <div>
                        <span className="font-data text-[9px] uppercase tracking-widest text-[#3b82f6]">
                          {t("programs.COOLDOWN_LABEL")}
                        </span>
                        <div className="mt-1 space-y-1">
                          {day.cooldown.exercises.map((ex, i) => (
                            <p key={i} className="font-data text-[9px] text-[#71717A]">
                              • {ex.name} — {ex.duration}
                            </p>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          ))}
      </div>

      {/* Exercise Rotation Info */}
      <div className="border border-card-border bg-card p-4">
        <div className="flex items-start gap-3">
          <div className="bg-[#71717A]/20 p-1.5 rounded-sm">
            <Info className="h-4 w-4 text-[#71717A]" />
          </div>
          <div className="flex-1">
            <h3 className="font-data text-xs font-bold uppercase tracking-widest text-[#a3a3a3]">
              {t("programs.EXERCISE_ROTATION_TITLE")}
            </h3>
            <p className="mt-1 text-sm text-[#71717A]">
              {t("programs.EXERCISE_ROTATION_DESC")}
            </p>
          </div>
        </div>
      </div>

      {/* Action Row */}
      <div className="border-t-2 border-[#e53e00] pt-6">
        <Button
          onClick={() => onActivate(program)}
          disabled={activating}
          className={cn(
            "w-full rounded-none font-data text-sm font-bold uppercase tracking-widest transition-all",
            activating
              ? "bg-[#2a2a2a] text-[#71717A]"
              : "bg-[#e53e00] text-white hover:bg-[#ff4500]"
          )}
          size="lg"
        >
          {activating ? (
            <>
              <AlertCircle className="mr-2 h-4 w-4 animate-spin" />
              {t("programs.ACTIVATING")}
            </>
          ) : (
            <>
              <Flame className="mr-2 h-4 w-4" />
              {t("programs.START_WEEK_CHALLENGE")}
              <ChevronRight className="ml-2 h-4 w-4" />
            </>
          )}
        </Button>
        
        <p className="mt-3 text-center font-data text-[9px] text-[#525252]">
          {t("programs.START_COMMIT_DESC").replace("{n}", String(currentWeekDays.length))}
        </p>
      </div>
    </div>
  );
}