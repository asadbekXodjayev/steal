"use client";

import { use } from "react";
import { useQuery } from "@tanstack/react-query";
import { getPocketBase } from "@/lib/pocketbase";
import { usePlanDays, usePlanCompletedSessions } from "@/hooks/usePlans";
import { BrandNoiseOverlay } from "@/components/layout/BrandNoiseOverlay";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ExerciseMedia } from "@/components/workout/ExerciseMedia";
import { Calendar, Dumbbell, CheckCircle2, Target, Clock, ChevronRight, Lock } from "lucide-react";
import type { WorkoutPlan, PlanDay } from "@/types/plan";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

// ─── Exercise List Panel ─────────────────────────────────────────────────────
function ExerciseListPanel({ dayId }: { dayId: string }) {
  const pb = getPocketBase();
  const { t } = useI18n();
  const { data: exercises, isLoading } = useQuery({
    queryKey: ["planExercises", dayId],
    queryFn: async () => {
      const records = await pb
        .collection("plan_exercises")
        .getList(1, 50, {
          filter: `planDay="${dayId}"`,
          sort: "order",
          expand: "exercise",
        });
      return records.items;
    },
    enabled: !!dayId,
  });

  if (isLoading) {
    return (
      <div className="space-y-1.5">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="skeleton-steal h-3 w-full" />
        ))}
      </div>
    );
  }

  if (!exercises || exercises.length === 0) {
    return (
      <p className="font-data text-[9px] text-[#525252]">{t("plans.NO_EXERCISES_CONFIGURED")}</p>
    );
  }

  return (
    <div className="space-y-0.5">
      {exercises.slice(0, 5).map((ex, i) => {
        const exName = ex.expand?.exercise?.name ?? ex.name ?? `Exercise ${i + 1}`;
        return (
          <div
            key={ex.id}
            className="flex items-center gap-2 py-1 px-2 hover:bg-[#1a1a1a] transition-colors group"
          >
            {/* Thumb navigates to exercise detail; rest of row is non-interactive */}
            <ExerciseMedia exerciseName={exName} size="thumb" className="shrink-0" />
            <span className="font-data text-[8px] text-[#525252] w-4 shrink-0">
              {String(i + 1).padStart(2, "0")}
            </span>
            <span className="font-data text-[10px] text-[#a3a3a3] flex-1 uppercase tracking-wide group-hover:text-[#e5e5e5] transition-colors truncate">
              {exName}
            </span>
            <span className="font-data text-[9px] text-[#71717A] shrink-0">
              {ex.sets}×{ex.repsMin}
            </span>
          </div>
        );
      })}
      {exercises.length > 5 && (
        <p className="font-data text-[8px] text-[#525252] pl-6">
          +{exercises.length - 5} {t("plans.MORE_EXERCISES")}
        </p>
      )}
    </div>
  );
}

// ─── Day Card ────────────────────────────────────────────────────────────────
function DayCard({
  day,
  isCurrentWeek,
  isCompleted,
  isLocked,
}: {
  day: PlanDay;
  isCurrentWeek: boolean;
  isCompleted: boolean;
  isLocked: boolean;
}) {
  const { t } = useI18n();
  return (
    <div
      className={cn(
        "border bg-[#0a0a0a] relative overflow-hidden transition-all",
        isCompleted
          ? "border-[#10b981]/40"
          : !isLocked && isCurrentWeek
          ? "border-[#e53e00]/40"
          : isLocked
          ? "border-[#2a2a2a] opacity-50"
          : "border-[#2a2a2a]"
      )}
    >
      <BrandNoiseOverlay />
      {isCompleted && (
        <div className="absolute inset-0 bg-[#10b981]/5 pointer-events-none" />
      )}
      {isLocked && (
        <div className="absolute inset-0 bg-[#0a0a0a]/70 pointer-events-none" />
      )}
      <div className="relative z-10 p-4">
        {/* Header */}
        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="font-data text-[10px] font-bold uppercase tracking-widest" style={{ color: isCompleted ? "#10b981" : "#e5e5e5" }}>
                {t(`daysOfWeek.${(["MON","TUE","WED","THU","FRI","SAT","SUN"] as const)[day.dayOfWeek - 1]}`)}
              </span>
              <span className="text-[#2a2a2a]">—</span>
              <span className="font-data text-[10px] font-semibold uppercase tracking-wide text-[#a3a3a3]">
                {day.label}
              </span>
            </div>
            {Array.isArray(day.focus) && day.focus.length > 0 && (
              <div className="flex gap-1 mt-1.5">
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
          {/* Inline status */}
          {isCompleted ? (
            <div className="flex items-center gap-1.5">
              <div className="bg-[#10b981]/10 p-1 rounded-sm">
                <CheckCircle2 className="h-3.5 w-3.5 text-[#10b981]" />
              </div>
              <span className="font-data text-[9px] font-bold uppercase tracking-widest text-[#10b981]">
                {t("plans.COMPLETED")}
              </span>
            </div>
          ) : isLocked ? (
            <div className="flex items-center gap-1.5">
              <div className="bg-[#2a2a2a] p-1 rounded-sm">
                <Lock className="h-3.5 w-3.5 text-[#525252]" />
              </div>
              <span className="font-data text-[9px] text-[#525252]">{t("plans.LOCKED")}</span>
            </div>
          ) : (
            <div className="flex items-center gap-1.5">
              <div className="bg-[#e53e00]/10 p-1 rounded-sm">
                <Clock className="h-3.5 w-3.5 text-[#e53e00]" />
              </div>
              <span className="font-data text-[9px] font-bold uppercase tracking-widest text-[#e53e00]">{t("plans.READY")}</span>
            </div>
          )}
        </div>

        {/* Divider */}
        <div className="h-px bg-[#1a1a1a] mb-3" />

        {/* Exercise list */}
        <div className="mb-3">
          <div className="flex items-center gap-2 mb-2">
            <Target className="h-3 w-3 text-[#525252]" />
            <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
              {t("plans.EXERCISES_LABEL")}
            </span>
          </div>
          <ExerciseListPanel dayId={day.id} />
        </div>

        {/* Action row */}
        <div className="flex items-center justify-between pt-3 border-t border-[#1a1a1a]">
          <span className="font-data text-[9px] text-[#525252]">
            {t("plans.WEEK")} {day.week}
          </span>
          {isCompleted ? (
            <span className="font-data text-[9px] font-bold uppercase tracking-widest text-[#10b981]">
              <CheckCircle2 className="inline h-3.5 w-3.5 mr-1" />
              {t("plans.DONE")}
            </span>
          ) : isLocked ? (
            <span className="font-data text-[9px] text-[#525252]">
              <Lock className="inline h-3 w-3 mr-1" />
              {t("plans.LOCKED")}
            </span>
          ) : (
            <Button
              asChild
              className="rounded-none bg-[#e53e00] font-data text-[10px] font-bold uppercase tracking-widest text-white hover:bg-[#ff4500] h-8 px-3"
            >
              <Link href={`/workout/${day.id}`}>
                {t("plans.START")}
                <ChevronRight className="ml-1 h-3 w-3" />
              </Link>
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Skeleton Grid ───────────────────────────────────────────────────────────
function SkeletonGrid() {
  return (
    <div className="space-y-4 py-4">
      <div className="space-y-2">
        <Skeleton className="skeleton-steal h-8 w-64" />
        <Skeleton className="skeleton-steal h-4 w-96" />
        <div className="flex gap-4">
          <Skeleton className="skeleton-steal h-4 w-24" />
          <Skeleton className="skeleton-steal h-4 w-32" />
        </div>
      </div>
      <div className="space-y-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="border border-[#2a2a2a] bg-[#0a0a0a] p-4">
            <Skeleton className="skeleton-steal h-4 w-full mb-3" />
            <Skeleton className="skeleton-steal h-4 w-3/4 mb-3" />
            <Skeleton className="skeleton-steal h-8 w-full" />
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Main page ───────────────────────────────────────────────────────────────
export default function PlanDetailPage({
  params,
}: {
  params: Promise<{ planId: string }>;
}) {
  const { planId } = use(params);
  const pb = getPocketBase();
  const { t } = useI18n();

  const { data: plan, isLoading: planLoading } = useQuery<WorkoutPlan>({
    queryKey: ["plan", planId],
    queryFn: () => pb.collection("workout_plans").getOne<WorkoutPlan>(planId),
  });

  const { data: days, isLoading: daysLoading } = usePlanDays(planId);
  const { data: completedDayIds, isLoading: sessionsLoading } = usePlanCompletedSessions(planId);

  if (planLoading || daysLoading || sessionsLoading) {
    return <SkeletonGrid />;
  }

  if (!plan) {
    return (
      <div className="border border-[#ef4444]/40 bg-[#0a0a0a] flex flex-col items-center justify-center py-20 gap-4" style={{ borderLeft: "3px solid #ef4444" }}>
        <div className="stamp text-[14px] tracking-[0.3em] text-[#ef4444]">{t("plans.NOT_FOUND")}</div>
        <div className="stamp text-[10px] text-[#525252]">{t("plans.PROGRAM_NOT_EXIST")}</div>
      </div>
    );
  }

  // Group days by week
  const weeks = new Map<number, PlanDay[]>();
  days?.forEach((day) => {
    const weekDays = weeks.get(day.week) ?? [];
    weekDays.push(day);
    weeks.set(day.week, weekDays);
  });

  const totalDays = days?.length ?? 0;

  return (
    <div className="space-y-6 py-6">
      {/* ── Hero Header ───────────────────────────────────────────────────── */}
      <div className="border-b border-[#2a2a2a] pb-4">
        <div className="flex items-start justify-between gap-4 flex-wrap">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="stamp text-[9px] tracking-[0.3em] text-[#525252]">{t("plans.ACTIVE_MISSION")}</span>
              <div className="h-px w-8 bg-[#2a2a2a]" />
              <span className="stamp text-[8px] text-[#10b981] tracking-widest">{t("plans.ONLINE")}</span>
            </div>
            <h1
              className="text-3xl sm:text-4xl font-black uppercase tracking-tight text-[#e5e5e5]"
              style={{ fontFamily: "var(--font-heading, system-ui)" }}
            >
              {plan.title}
            </h1>
            <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
          </div>
          <div className="flex flex-col items-end gap-1 shrink-0">
            <div className="flex items-center gap-2">
              <span className="stamp text-[9px] tracking-[0.15em] text-[#525252]">{t("plans.STATUS")}</span>
              <span className={cn(
                "font-data text-[9px] font-bold uppercase tracking-widest px-2 py-0.5",
                plan.status === "active" ? "bg-[#10b981]/10 text-[#10b981]" : "bg-[#525252]/10 text-[#71717A]"
              )}>
                {plan.status ? t(`enums.planStatus.${plan.status}`) : "—"}
              </span>
            </div>
          </div>
        </div>

        {/* Meta row */}
        <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="flex items-center gap-2">
            <div className="bg-[#2a2a2a] p-1.5 rounded-sm">
              <Calendar className="h-3.5 w-3.5 text-[#525252]" />
            </div>
            <div>
              <div className="font-data text-[9px] text-[#525252]">{t("plans.DURATION")}</div>
              <div className="font-data text-xs text-[#a3a3a3]">{t("plans.WEEK")} {plan.currentWeek} / {plan.durationWeeks}</div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="bg-[#2a2a2a] p-1.5 rounded-sm">
              <Dumbbell className="h-3.5 w-3.5 text-[#525252]" />
            </div>
            <div>
              <div className="font-data text-[9px] text-[#525252]">{t("plans.TOTAL_DAYS")}</div>
              <div className="font-data text-xs text-[#a3a3a3]">{totalDays} {t("plans.TRAINING")}</div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="bg-[#2a2a2a] p-1.5 rounded-sm">
              <Target className="h-3.5 w-3.5 text-[#525252]" />
            </div>
            <div>
              <div className="font-data text-[9px] text-[#525252]">{t("plans.GOAL")}</div>
              <div className="font-data text-xs text-[#a3a3a3]">{plan.goalType ? t(`enums.goalType.${plan.goalType}`) : "N/A"}</div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="bg-[#2a2a2a] p-1.5 rounded-sm">
              <Clock className="h-3.5 w-3.5 text-[#525252]" />
            </div>
            <div>
              <div className="font-data text-[9px] text-[#525252]">{t("plans.ENVIRONMENT")}</div>
              <div className="font-data text-xs text-[#a3a3a3]">{plan.environment ? t(`enums.environment.${plan.environment}`) : "N/A"}</div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Weekly breakdown ─────────────────────────────────────────────── */}
      <div className="space-y-4">
        <div className="flex items-center gap-4">
          <div className="h-px flex-1 bg-[#2a2a2a]" />
          <span className="font-data text-[10px] uppercase tracking-widest text-[#71717A]">
            {t("plans.TRAINING_SCHEDULE")}
          </span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>

        {Array.from(weeks.entries()).sort(([a], [b]) => a - b).map(([weekNum, weekDays]) => {
          const isCurrentWeek = weekNum === plan.currentWeek;
          const isFutureWeek = weekNum > plan.currentWeek;
          const sortedDays = weekDays?.sort((a, b) => a.dayOfWeek - b.dayOfWeek) ?? [];

          // Sequential locking: within current week, only the first
          // uncompleted day is open. Past weeks are all open (or completed).
          // Future weeks are fully locked.
          let nextOpenFound = false;

          return (
            <div key={weekNum} className="space-y-3">
              {/* Week header */}
              <div className="flex items-center gap-3">
                <div className={cn(
                  "w-1 h-6",
                  isCurrentWeek ? "bg-[#e53e00]" : "bg-[#2a2a2a]"
                )} />
                <div>
                  <span className={cn(
                    "font-data text-xs font-bold uppercase tracking-widest",
                    isCurrentWeek ? "text-[#e5e5e5]" : "text-[#525252]"
                  )}>
                    {t("plans.WEEK")} {weekNum}
                  </span>
                  <span className="font-data text-[9px] text-[#71717A] ml-2">
                    {sortedDays.length} {t("plans.DAYS")}
                  </span>
                </div>
                {isCurrentWeek && (
                  <span className="stamp text-[8px] text-[#e53e00] tracking-widest">{t("plans.CURRENT")}</span>
                )}
              </div>

              {/* Week days grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {sortedDays.map((day) => {
                  const dayCompleted = completedDayIds?.includes(day.id) ?? false;

                  let dayLocked: boolean;
                  if (isFutureWeek) {
                    dayLocked = true;
                  } else if (dayCompleted) {
                    dayLocked = false;
                  } else if (isCurrentWeek) {
                    // First uncompleted day in current week is open
                    if (!nextOpenFound) {
                      nextOpenFound = true;
                      dayLocked = false;
                    } else {
                      dayLocked = true;
                    }
                  } else {
                    // Past week — all unlocked
                    dayLocked = false;
                  }

                  return (
                    <DayCard
                      key={day.id}
                      day={day}
                      isCurrentWeek={isCurrentWeek}
                      isCompleted={dayCompleted}
                      isLocked={dayLocked}
                    />
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>

      {/* ── Bottom HUD ────────────────────────────────────────────────────── */}
      <div className="border-t-2 border-[#e53e00] pt-4">
        <div className="grid grid-cols-3">
          <div className="px-4 py-2 text-center border-r border-[#1a1a1a]">
            <p className="stamp text-[8px] text-[#525252] mb-1">{t("plans.LAST_SYNC")}</p>
            <p className="font-data text-[10px] text-[#71717A]">{t("plans.LIVE")}</p>
          </div>
          <div className="px-4 py-2 text-center border-r border-[#1a1a1a]">
            <p className="stamp text-[8px] text-[#525252] mb-1">{t("plans.PROGRESS")}</p>
            <p className="font-data text-[10px] text-[#71717A]">
              {Math.round((plan.currentWeek / plan.durationWeeks) * 100)}%
            </p>
          </div>
          <div className="px-4 py-2 text-center">
            <p className="stamp text-[8px] text-[#525252] mb-1">{t("plans.PLAN_ID")}</p>
            <p className="font-data text-[10px] text-[#71717A] truncate">{planId.slice(0, 8)}</p>
          </div>
        </div>
      </div>
    </div>
  );
}