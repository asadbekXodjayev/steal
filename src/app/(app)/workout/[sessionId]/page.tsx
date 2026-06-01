"use client";

import { use, useState, useEffect, useMemo } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { getPocketBase } from "@/lib/pocketbase";
import { useRestTimer } from "@/hooks/useRestTimer";
import { useWorkoutStore } from "@/stores/workout-store";
import { ExerciseCard } from "@/components/workout/ExerciseCard";
import { RestTimer } from "@/components/workout/RestTimer";
import { MoodCheck } from "@/components/workout/MoodCheck";
import { WorkoutSummary } from "@/components/workout/WorkoutSummary";
import { Skeleton } from "@/components/ui/skeleton";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import { Clock, CheckCircle2 } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";
import { formatDuration } from "@/lib/utils";
import type { PlanDay, PlanExercise } from "@/types/plan";
import type { MoodLevel, ActiveSetInput } from "@/types/session";
import { useGuestPlanDays } from "@/hooks/useGuestWorkouts";
import { useGuestWorkoutSessions } from "@/hooks/useGuestWorkouts";
import { useIsGuestUser } from "@/hooks/useGuestWorkouts";
import { useGuestActivePlan } from "@/hooks/useGuestWorkouts";
import type { GuestSession } from "@/hooks/useGuestWorkouts";

export default function WorkoutSessionPage({
  params,
}: {
  params: Promise<{ sessionId: string }>;
}) {
  const { sessionId } = use(params);
  const pb = getPocketBase();
  const timer = useRestTimer();
  const store = useWorkoutStore();
  const isGuest = useIsGuestUser();
  const { t } = useI18n();

  const [mood, setMood] = useState<MoodLevel | null>(null);
  const [notes, setNotes] = useState("");
  const [isFinishing, setIsFinishing] = useState(false);
  const [showSummary, setShowSummary] = useState(false);
  const [summaryData, setSummaryData] = useState<{
    exercises: Array<{ name: string; completedSets: ActiveSetInput[] }>;
    duration: number;
  } | null>(null);
  const queryClient = useQueryClient();

  // Guest mode state
  const { activePlan: guestActivePlan } = useGuestActivePlan();
  const { planDays } = useGuestPlanDays(guestActivePlan?.id);
  const { saveSession: saveGuestSession } = useGuestWorkoutSessions();

  // Find guest plan day by sessionId
  const guestPlanDay = useMemo(() => {
    return planDays.find((d) => d.id === sessionId);
  }, [planDays, sessionId]);

  // Convert guest exercises to plan exercises format
  const guestExercises = useMemo(() => {
    if (!guestPlanDay) return [];
    return guestPlanDay.exercises.map((ex, i) => ({
      id: ex.id,
      planDay: ex.planDayId,
      exercise: "",
      name: ex.name,
      order: ex.order,
      sets: ex.sets,
      repsMin: ex.repsMin,
      repsMax: ex.repsMax,
      rpeTarget: ex.rpeTarget,
      restSeconds: ex.restSeconds,
      notes: ex.notes || "",
      substitutions: [],
      created: new Date().toISOString(),
      updated: new Date().toISOString(),
    }));
  }, [guestPlanDay]);

  // For authenticated users
  const [elapsedSeconds, setElapsedSeconds] = useState(() => {
    if (store.startedAt) {
      return Math.max(0, Math.floor((Date.now() - new Date(store.startedAt).getTime()) / 1000));
    }
    return 0;
  });

  const { data: planDay, isLoading: dayLoading } = useQuery<PlanDay>({
    queryKey: ["planDay", sessionId],
    queryFn: () => pb.collection("plan_days").getOne<PlanDay>(sessionId),
    enabled: !isGuest,
  });

  const { data: planExercises, isLoading: exLoading } = useQuery<PlanExercise[]>({
    queryKey: ["planExercises", sessionId],
    queryFn: async () => {
      const records = await pb
        .collection("plan_exercises")
        .getList<PlanExercise>(1, 50, {
          filter: `planDay="${sessionId}"`,
          sort: "order",
          expand: "exercise",
        });
      return records.items;
    },
    enabled: !!sessionId && !isGuest,
  });

  // Use guest data if guest, otherwise authenticated data
  const currentPlanDay = isGuest ? guestPlanDay : planDay;
  const currentExercises = isGuest ? guestExercises : (planExercises ?? []);
  const isLoading = isGuest ? false : (dayLoading || exLoading);

  // Initialise the store for this session ONCE
  useEffect(() => {
    if (!currentExercises || currentExercises.length === 0) return;
    const current = useWorkoutStore.getState();
    if (
      current.sessionId === sessionId &&
      current.exercises.length === currentExercises.length
    ) {
      return;
    }
    current.startSession(
      sessionId,
      sessionId,
      currentExercises.map((ex: any, i) => ({
        exerciseId: ex.expand?.exercise?.id ?? ex.id,
        exerciseName:
          ex.name?.trim() ||
          ex.expand?.exercise?.name ||
          ex.notes?.trim() ||
          `Exercise ${i + 1}`,
        targetSets: ex.sets,
        completedSets: [],
      })),
    );
  }, [currentExercises, sessionId]);

  // Tick every second
  useEffect(() => {
    if (showSummary) return;
    const interval = setInterval(() => setElapsedSeconds((s) => s + 1), 1000);
    return () => clearInterval(interval);
  }, [showSummary]);

  // Resolve exercise display name
  const getExerciseName = (ex: any, i: number): string =>
    ex.name?.trim() ||
    ex.expand?.exercise?.name ||
    store.exercises[i]?.exerciseName ||
    `Exercise ${i + 1}`;

  function handleCompleteSet(exerciseIndex: number, data: ActiveSetInput) {
    store.completeSet(exerciseIndex, data);
    const ex = currentExercises[exerciseIndex];
    if (ex?.restSeconds) timer.start(ex.restSeconds);
    toast.success(t("workout.SET_LOGGED"), { duration: 1500 });
  }

  async function handleFinishWorkout() {
    setIsFinishing(true);
    try {
      const currentUserId = pb.authStore.record?.id;

      if (isGuest) {
        // Guest mode - save to localStorage
        const guestSession: GuestSession = {
          id: `session_${Date.now()}`,
          planDayId: sessionId,
          planId: guestPlanDay?.planId || "",
          startedAt: store.startedAt ?? new Date(Date.now() - elapsedSeconds * 1000).toISOString(),
          completedAt: new Date().toISOString(),
          status: "completed",
          mood: mood || undefined,
          energyLevel:
            mood === "great" ? 5 : mood === "good" ? 4 : mood === "okay" ? 3 : mood === "rough" ? 2 : 1,
          sessionNotes: notes,
          exercises: store.exercises.map((ex, i) => ({
            exerciseId: ex.exerciseId,
            exerciseName: ex.exerciseName || getExerciseName(currentExercises[i], i),
            targetSets: ex.targetSets,
            completedSets: ex.completedSets,
          })),
        };

        saveGuestSession(guestSession);
        store.endSession();

        setSummaryData({
          exercises: store.exercises.map((ex, i) => ({
            name: ex.exerciseName || getExerciseName(currentExercises[i], i),
            completedSets: ex.completedSets,
          })),
          duration: elapsedSeconds,
        });

        setShowSummary(true);
        toast.success(t("workout.SESSION_SAVED_LOCAL"));
      } else {
        // Authenticated mode - save to PocketBase
        // Create the session record
        const session = await pb.collection("workout_sessions").create({
          user: currentUserId,
          planDay: sessionId,
          plan: planDay?.plan || "",
          startedAt: store.startedAt ?? new Date(Date.now() - elapsedSeconds * 1000).toISOString(),
          completedAt: new Date().toISOString(),
          status: "completed",
          mood,
          energyLevel:
            mood === "great" ? 5 : mood === "good" ? 4 : mood === "okay" ? 3 : mood === "rough" ? 2 : 1,
          sessionNotes: notes,
        });

        // Save all sets
        let totalSetsSaved = 0;
        for (let i = 0; i < store.exercises.length; i++) {
          const ex = store.exercises[i];
          // Only send exercise relation if it came from a verified exercises-collection expand
          const verifiedExerciseId = planExercises?.[i]?.expand?.exercise?.id ?? null;
          for (let s = 0; s < ex.completedSets.length; s++) {
            const set = ex.completedSets[s];
            const exerciseRelation = verifiedExerciseId ? { exercise: verifiedExerciseId } : {};
            await pb.collection("session_sets").create({
              session: session.id,
              ...exerciseRelation,
              setNumber: s + 1,
              reps: set.reps,
              weight: set.weight,
              rpe: set.rpe,
              completed: true,
              notes: set.notes || "",
            });
            totalSetsSaved++;
          }
        }

        // Save summary data BEFORE clearing the store
        const exercisesSummary = store.exercises.map((ex, i) => ({
          name: ex.exerciseName || getExerciseName(planExercises?.[i] ?? ({} as PlanExercise), i),
          completedSets: ex.completedSets,
        }));
        
        store.endSession();
        
        // Set summary data before showing summary
        setSummaryData({
          exercises: exercisesSummary,
          duration: elapsedSeconds,
        });
        
        // Invalidate all relevant queries to refresh UI
        await queryClient.invalidateQueries({ queryKey: ["progressData", currentUserId] });
        await queryClient.invalidateQueries({ queryKey: ["activePlan", currentUserId] });
        await queryClient.invalidateQueries({ queryKey: ["plans", currentUserId] });
        await queryClient.invalidateQueries({ queryKey: ["planDaySession", sessionId, currentUserId] });
        if (planDay?.plan) {
          await queryClient.invalidateQueries({ queryKey: ["planCompletedDays", planDay.plan] });
        }

        // Advance currentWeek if all days in this week are now completed
        if (planDay?.plan) {
          try {
            const planRecord = await pb.collection("workout_plans").getOne<{ id: string; currentWeek: number; durationWeeks: number }>(planDay.plan);
            const finishedWeek = planDay.week;

            if (finishedWeek === planRecord.currentWeek && planRecord.currentWeek < planRecord.durationWeeks) {
              const weekDays = await pb.collection("plan_days").getFullList<{ id: string }>({
                filter: `plan="${planDay.plan}" && week=${finishedWeek}`,
                fields: "id",
              });

              const completedSessions = await pb.collection("workout_sessions").getFullList<{ planDay: string }>({
                filter: `plan="${planDay.plan}" && user="${currentUserId}" && status="completed"`,
                fields: "planDay",
              });

              const completedPlanDayIds = new Set(completedSessions.map((s) => s.planDay));
              const allDaysComplete = weekDays.every((d) => completedPlanDayIds.has(d.id));

              if (allDaysComplete) {
                await pb.collection("workout_plans").update(planDay.plan, { currentWeek: planRecord.currentWeek + 1 });
                await queryClient.invalidateQueries({ queryKey: ["plans", currentUserId] });
                await queryClient.invalidateQueries({ queryKey: ["activePlan", currentUserId] });
                toast.success(t("workout.WEEK_UNLOCKED").replace("{w}", String(planRecord.currentWeek + 1)));
              }
            }
          } catch {
            toast.error(t("workout.SAVE_FAILED"));
          }
        }

        setShowSummary(true);
        toast.success(t("workout.SESSION_SAVED"));
      }
    } catch {
      toast.error(t("workout.SAVE_FAILED"));
    } finally {
      setIsFinishing(false);
    }
  }

  if (showSummary && summaryData) {
    return (
      <WorkoutSummary
        duration={summaryData.duration}
        exercises={summaryData.exercises}
      />
    );
  }

  if (isLoading) {
    return (
      <div className="space-y-4 py-4">
        <Skeleton className="skeleton-steal h-8 w-48 rounded-none" />
        <Skeleton className="skeleton-steal h-64 rounded-none" />
        <Skeleton className="skeleton-steal h-64 rounded-none" />
      </div>
    );
  }

  if (!currentExercises || currentExercises.length === 0) {
    return (
      <div className="py-16 text-center">
        <p className="font-data text-sm uppercase tracking-widest text-muted-foreground">
          {t("workout.NO_EXERCISES")}
        </p>
      </div>
    );
  }

  const totalSets = store.exercises.reduce((sum, ex) => sum + ex.completedSets.length, 0);
  const targetSets = store.exercises.reduce((sum, ex) => sum + ex.targetSets, 0);
  const progressPct = targetSets > 0 ? Math.round((totalSets / targetSets) * 100) : 0;

  return (
    <div className="space-y-3 py-2 pb-28">
      {/* Sticky header */}
      <div
        className="glass-dark sticky top-14 z-10 -mx-4 px-4 py-2 flex items-center gap-3"
        style={{ borderBottom: "1px solid rgba(255,255,255,0.06)" }}
      >
        <div className="flex-1">
          <h1 className="font-heading text-xl font-bold uppercase text-[#f0f0f0] leading-none">
            {currentPlanDay?.label || "WORKOUT"}
          </h1>
          <span className="font-data mt-0.5 block text-[10px] text-ink-low tracking-widest uppercase">
            {isGuest ? t("workout.GUEST_MODE") : `${totalSets} / ${targetSets} ${t("workout.SETS")} · ${formatDuration(elapsedSeconds)}`}
          </span>
        </div>
        {/* Rest timer display */}
        <div className="glass-acc px-3 py-1.5 text-center shrink-0">
          <span className="font-data block text-[10px] text-[#EA580C] tracking-widest uppercase">REST</span>
          <span className="font-data font-bold text-[#C2410C] tabular-nums" style={{ fontSize: "clamp(15px, 4.5vw, 18px)", lineHeight: 1 }}>
            {timer.isRunning ? String(Math.floor(timer.secondsLeft / 60)).padStart(2, "0") + ":" + String(timer.secondsLeft % 60).padStart(2, "0") : "--:--"}
          </span>
        </div>
      </div>

      {/* 5-segment progress bar */}
      <div className="flex gap-1">
        {currentExercises.slice(0, 5).map((_, i) => {
          const exSets = store.exercises[i]?.completedSets.length ?? 0;
          const done = exSets >= (currentExercises[i]?.sets ?? 1);
          const active = store.currentExerciseIndex === i;
          return (
            <div key={i} className="flex-1 h-[3px] rounded-none" style={{
              background: done
                ? "#22c55e"
                : active
                ? "linear-gradient(90deg,#C2410C,#EA580C)"
                : "rgba(255,255,255,0.06)",
              boxShadow: active ? "0 0 8px rgba(194,65,12,0.5)" : undefined,
            }} />
          );
        })}
      </div>

      {/* Exercise list */}
      <div className="space-y-2">
        {currentExercises.map((ex, i) => (
          <ExerciseCard
            key={ex.id}
            exerciseName={getExerciseName(ex, i)}
            exerciseNumber={i + 1}
            sets={ex.sets}
            repsMin={ex.repsMin}
            repsMax={ex.repsMax}
            rpeTarget={ex.rpeTarget}
            restSeconds={ex.restSeconds}
            notes={ex.notes}
            completedSets={store.exercises[i]?.completedSets ?? []}
            onCompleteSet={(data) => handleCompleteSet(i, data)}
            isActive={store.currentExerciseIndex === i}
          />
        ))}
      </div>

      {/* Finish section */}
      <div className="glass p-4 space-y-4">
        <h2 className="font-heading text-base font-black uppercase tracking-widest text-[#e5e5e5]">
          {t("workout.WRAP_IT_UP")}
        </h2>

        <MoodCheck value={mood} onChange={setMood} label={t("workout.HOW_IT_GO")} />

        <div className="space-y-1.5">
          <label
            className="font-data text-xs font-semibold uppercase tracking-widest text-[#525252]"
            htmlFor="session-notes"
          >
            {t("workout.NOTES")}
          </label>
          <Textarea
            id="session-notes"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder={t("workout.NOTES_PLACEHOLDER")}
            rows={2}
            className="rounded-none border-[rgba(255,255,255,0.08)] bg-[rgba(0,0,0,0.4)] font-data text-sm"
          />
        </div>

        <button
          onClick={handleFinishWorkout}
          disabled={isFinishing || totalSets === 0}
          className="btn-forge w-full h-10 text-sm disabled:opacity-40"
        >
          <CheckCircle2 className="mr-2 h-4 w-4" />
          {isFinishing ? t("workout.SAVING") : t("workout.FINISH_SESSION")}
        </button>

        {totalSets === 0 && (
          <p className="text-center font-data text-xs text-[#525252]">
            {t("workout.LOG_AT_LEAST_ONE")}
          </p>
        )}
      </div>

      {/* Rest timer controls */}
      <RestTimer
        secondsLeft={timer.secondsLeft}
        isRunning={timer.isRunning}
        onStart={timer.start}
        onStop={timer.reset}
        defaultSeconds={90}
      />
    </div>
  );
}
