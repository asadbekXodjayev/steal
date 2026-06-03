"use client";

import { ChevronLeft, Calendar, Clock, Target, Dumbbell } from "lucide-react";
import { type LegendProgram } from "@/data/legend-programs";
import { BrandNoiseOverlay } from "@/components/layout/BrandNoiseOverlay";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface Props {
  program: LegendProgram;
  onBack: () => void;
}

export function ProgramDetail({ program, onBack }: Props) {
  const { t } = useI18n();
  return (
    <div className="page-enter space-y-6 py-6">
      {/* Back button */}
      <button
        onClick={onBack}
        className="inline-flex items-center gap-1.5 font-data text-[10px] uppercase tracking-widest text-[#71717A] hover:text-[#e5e5e5] transition-colors group"
      >
        <ChevronLeft className="h-3 w-3 transition-transform group-hover:-translate-x-1" />
        {t("programs.BACK_TO_PROGRAMS")}
      </button>

      {/* Header */}
      <div className="relative overflow-hidden border border-[#2a2a2a] bg-[#0a0a0a]">
        <BrandNoiseOverlay />
        <div className="relative z-10 p-6 sm:p-8">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
            <div>
              <p className="font-data text-[10px] font-semibold uppercase tracking-widest text-[#e53e00] mb-2">
                {program.athleteName}
              </p>
              <h1
                className="text-3xl sm:text-4xl font-black uppercase tracking-tight text-[#e5e5e5]"
                style={{ fontFamily: "var(--font-heading, system-ui)" }}
              >
                {program.name}
              </h1>
              <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
            </div>
            
            {/* Quick stats */}
            <div className="grid grid-cols-2 gap-3 shrink-0">
              <div className="border border-[#2a2a2a] bg-[#050505] p-3">
                <Calendar className="h-4 w-4 text-[#e53e00] mb-1" />
                <p className="font-data text-[9px] uppercase tracking-widest text-[#525252]">{t("programs.FREQUENCY_LABEL")}</p>
                <p className="font-data text-[11px] text-[#e5e5e5]">{program.frequency}</p>
              </div>
              <div className="border border-[#2a2a2a] bg-[#050505] p-3">
                <Clock className="h-4 w-4 text-[#e53e00] mb-1" />
                <p className="font-data text-[9px] uppercase tracking-widest text-[#525252]">{t("programs.SESSION_LABEL")}</p>
                <p className="font-data text-[11px] text-[#e5e5e5]">{program.sessionLength}</p>
              </div>
            </div>
          </div>

          {/* Philosophy */}
          <p className="mt-4 text-sm leading-relaxed text-[#a3a3a3]">
            {program.philosophy}
          </p>

          {/* Tags */}
          <div className="mt-4 flex flex-wrap gap-2">
            {program.tags.map((tag) => (
              <span
                key={tag}
                className="px-2 py-1 border border-[#2a2a2a] font-data text-[9px] uppercase tracking-widest text-[#71717A]"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* Program Overview */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <Dumbbell className="h-5 w-5 text-[#e53e00] mb-2" />
            <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-1">{t("programs.SPLIT_LABEL")}</p>
            <p className="font-data text-[11px] text-[#e5e5e5]">{program.split}</p>
          </div>
        </div>

        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <Target className="h-5 w-5 text-[#e53e00] mb-2" />
            <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-1">{t("programs.RECOMMENDED_FOR")}</p>
            <p className="font-data text-[11px] text-[#e5e5e5]">{program.recommendedFor}</p>
          </div>
        </div>

        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <Calendar className="h-5 w-5 text-[#e53e00] mb-2" />
            <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-1">{t("programs.WEEKLY_VOLUME_LABEL")}</p>
            <div className="space-y-0.5">
              {Object.entries(program.weeklyVolume).slice(0, 3).map(([muscle, sets]) => (
                <p key={muscle} className="font-data text-[10px] text-[#a3a3a3] capitalize">
                  {muscle}: {sets}
                </p>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Weekly Schedule */}
      <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
        <BrandNoiseOverlay />
        <div className="relative z-10">
          <div className="flex items-center gap-2 mb-4">
            <div className="h-px flex-1 bg-[#1a1a1a]" />
            <span className="stamp text-[9px] uppercase tracking-widest text-[#525252]">
              {t("programs.WEEKLY_SCHEDULE_HEADING")}
            </span>
            <div className="h-px flex-1 bg-[#1a1a1a]" />
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-2">
            {program.schedule.map((day, idx) => (
              <div
                key={idx}
                className={cn(
                  "border p-2",
                  day.workout.toLowerCase().includes("rest")
                    ? "border-[#2a2a2a] bg-[#050505]"
                    : "border-[#2a2a2a] bg-[#0a0a0a]"
                )}
              >
                <p className="font-data text-[8px] uppercase tracking-widest text-[#525252]">
                  {day.day}
                </p>
                <p
                  className={cn(
                    "font-data text-[9px] uppercase tracking-widest",
                    day.workout.toLowerCase().includes("rest")
                      ? "text-[#71717A]"
                      : "text-[#e5e5e5]"
                  )}
                >
                  {day.workout}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Training Days */}
      <div className="space-y-4">
        <div className="flex items-center gap-4">
          <div className="h-px flex-1 bg-[#2a2a2a]" />
          <span className="font-data text-[10px] uppercase tracking-widest text-[#71717A]">
            {t("programs.TRAINING_DAYS_HEADING")}
          </span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>

        {program.trainingDays.map((day, dayIdx) => (
          <div key={dayIdx} className="border border-[#2a2a2a] bg-[#0a0a0a] relative overflow-hidden">
            <BrandNoiseOverlay />
            
            {/* Day header */}
            <div className="relative z-10 border-b border-[#2a2a2a] bg-[#050505] p-4">
              <p className="font-data text-[10px] font-semibold uppercase tracking-widest text-[#e53e00]">
                {day.name}
              </p>
              <h3
                className="text-lg font-black uppercase tracking-tight text-[#e5e5e5]"
                style={{ fontFamily: "var(--font-heading, system-ui)" }}
              >
                {day.focus}
              </h3>
            </div>

            {/* Exercises */}
            <div className="relative z-10 p-4 space-y-4">
              {day.exercises.map((exercise, exIdx) => (
                <div key={exIdx} className="border border-[#2a2a2a] bg-[#050505] p-3">
                  <div className="flex items-start justify-between gap-3 mb-2">
                    <h4 className="font-data text-[11px] font-bold uppercase tracking-widest text-[#e5e5e5]">
                      {exercise.name}
                    </h4>
                    <span className="shrink-0 font-data text-[8px] text-[#e53e00]">
                      #{exIdx + 1}
                    </span>
                  </div>

                  {/* Exercise image placeholder */}
                  <div className="relative aspect-video w-full bg-[#111] border border-[#2a2a2a] flex items-center justify-center mb-3">
                    <span className="stamp text-[10px] text-[#525252] tracking-widest">
                      [IMAGE: {exercise.imagePlaceholder}]
                    </span>
                  </div>

                  {/* Exercise details */}
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    <div>
                      <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-0.5">{t("programs.SETS_LABEL")}</p>
                      <p className="font-data text-[10px] text-[#a3a3a3]">{exercise.sets}</p>
                    </div>
                    <div>
                      <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-0.5">{t("programs.REPS_LABEL")}</p>
                      <p className="font-data text-[10px] text-[#a3a3a3]">{exercise.reps}</p>
                    </div>
                    <div>
                      <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-0.5">{t("programs.REST_LABEL")}</p>
                      <p className="font-data text-[10px] text-[#a3a3a3]">{exercise.rest}</p>
                    </div>
                    {exercise.tempo && (
                      <div>
                        <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-0.5">{t("programs.TEMPO_LABEL")}</p>
                        <p className="font-data text-[10px] text-[#a3a3a3]">{exercise.tempo}</p>
                      </div>
                    )}
                  </div>

                  {/* Notes */}
                  <p className="mt-2 font-data text-[9px] text-[#71717A]">
                    {exercise.notes}
                  </p>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Progression & Recovery */}
      <div className="grid sm:grid-cols-2 gap-4">
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-4">
              <div className="h-px flex-1 bg-[#1a1a1a]" />
              <span className="stamp text-[9px] uppercase tracking-widest text-[#525252]">
                {t("programs.PROGRESSION_HEADING")}
              </span>
              <div className="h-px flex-1 bg-[#1a1a1a]" />
            </div>

            <ul className="space-y-2">
              {program.progression.map((item, idx) => (
                <li key={idx} className="flex gap-2">
                  <span className="shrink-0 w-1 h-1 mt-1.5 bg-[#e53e00] rounded-full" />
                  <p className="font-data text-[10px] text-[#a3a3a3]">{item}</p>
                </li>
              ))}
            </ul>

            <div className="mt-4 pt-4 border-t border-[#2a2a2a]">
              <p className="font-data text-[8px] uppercase tracking-widest text-[#525252] mb-1">{t("programs.DELOAD_LABEL")}</p>
              <p className="font-data text-[10px] text-[#71717A]">{program.deload}</p>
            </div>
          </div>
        </div>

        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-4 relative overflow-hidden">
          <BrandNoiseOverlay />
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-4">
              <div className="h-px flex-1 bg-[#1a1a1a]" />
              <span className="stamp text-[9px] uppercase tracking-widest text-[#525252]">
                {t("programs.RECOVERY_HEADING")}
              </span>
              <div className="h-px flex-1 bg-[#1a1a1a]" />
            </div>

            <ul className="space-y-2">
              {program.recovery.map((item, idx) => (
                <li key={idx} className="flex gap-2">
                  <span className="shrink-0 w-1 h-1 mt-1.5 bg-[#e53e00] rounded-full" />
                  <p className="font-data text-[10px] text-[#a3a3a3]">{item}</p>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
