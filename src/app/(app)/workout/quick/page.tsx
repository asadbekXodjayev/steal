"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { Plus, X, Check, ChevronDown, ChevronUp, Zap, Loader2, History } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";
import { ExercisePickerModal } from "@/components/plans/ExercisePickerModal";
import { getPocketBase } from "@/lib/pocketbase";
import { toast } from "sonner";
import type { LibraryExercise } from "@/types/exercise";
import {
  type HistoryEntry,
  readExerciseHistory,
  normalizeName,
  persistWorkoutSession,
} from "@/lib/workout-history";

// ─── Types ────────────────────────────────────────────────────────────────────

interface QuickSet {
  weight: string;
  reps: string;
  rpe: number;
  completed: boolean;
}

interface QuickExercise {
  uid: string;
  exercise: LibraryExercise | null;
  name: string;
  sets: QuickSet[];
  prev: HistoryEntry | null;
}

type Mood = "great" | "good" | "okay" | "rough" | "terrible";

const MOOD_OPTIONS: { value: Mood; emoji: string }[] = [
  { value: "great",    emoji: "💪" },
  { value: "good",     emoji: "😊" },
  { value: "okay",     emoji: "😐" },
  { value: "rough",    emoji: "😔" },
  { value: "terrible", emoji: "😞" },
];

function moodToEnergy(mood: Mood | null): number {
  const map: Record<Mood, number> = { great: 5, good: 4, okay: 3, rough: 2, terrible: 1 };
  return mood ? map[mood] : 3;
}

function newSet(): QuickSet {
  return { weight: "", reps: "", rpe: 8, completed: false };
}

function newExercise(ex: LibraryExercise, prev: HistoryEntry | null): QuickExercise {
  return { uid: crypto.randomUUID(), exercise: ex, name: ex.name, sets: [newSet()], prev };
}

// ─── SetRow ───────────────────────────────────────────────────────────────────

function SetRow({
  set,
  index,
  prev,
  weightLabel,
  repsLabel,
  completeLabel,
  removeSetLabel,
  onChange,
  onRemove,
}: {
  set: QuickSet;
  index: number;
  prev: HistoryEntry | null;
  weightLabel: string;
  repsLabel: string;
  completeLabel: string;
  removeSetLabel: string;
  onChange: (patch: Partial<QuickSet>) => void;
  onRemove: () => void;
}) {
  // Use the matching previous set; fall back to last one if more sets added
  const prevSets = prev?.sets ?? [];
  const prevSet = prevSets.length > 0
    ? (prevSets[index] ?? prevSets[prevSets.length - 1])
    : null;

  const hasHint = !!prevSet;

  return (
    <div
      className={cn(
        "flex items-center gap-2 py-2 border-b border-[#1a1a1a] last:border-0 transition-opacity",
        set.completed && "opacity-40",
      )}
    >
      <span className={cn(
        "w-5 font-data text-[10px] font-bold tabular-nums text-[#525252] shrink-0",
        set.completed && "line-through",
      )}>
        {index + 1}
      </span>

      {/* Weight */}
      <div className="flex items-center gap-1 flex-1">
        <input
          type="number"
          inputMode="decimal"
          value={set.weight}
          onChange={(e) => onChange({ weight: e.target.value })}
          placeholder={prevSet ? String(prevSet.weight) : "0"}
          className={cn(
            "w-full min-w-0 bg-[#111] border px-2 py-2 font-data text-[13px] font-bold text-center text-[#e5e5e5] focus:outline-none tabular-nums transition-colors",
            hasHint && !set.weight
              ? "border-[#e53e00]/25 placeholder:text-[#e53e00]/50 focus:border-[#e53e00]/60"
              : "border-[#2a2a2a] placeholder:text-[#525252] focus:border-[#e53e00]/60",
          )}
          disabled={set.completed}
        />
        <span className="font-data text-[9px] uppercase tracking-widest text-[#525252] shrink-0">
          {weightLabel}
        </span>
      </div>

      <span className="text-[#525252] text-xs shrink-0">×</span>

      {/* Reps */}
      <div className="flex items-center gap-1 flex-1">
        <input
          type="number"
          inputMode="numeric"
          value={set.reps}
          onChange={(e) => onChange({ reps: e.target.value })}
          placeholder={prevSet ? String(prevSet.reps) : "0"}
          className={cn(
            "w-full min-w-0 bg-[#111] border px-2 py-2 font-data text-[13px] font-bold text-center text-[#e5e5e5] focus:outline-none tabular-nums transition-colors",
            hasHint && !set.reps
              ? "border-[#e53e00]/25 placeholder:text-[#e53e00]/50 focus:border-[#e53e00]/60"
              : "border-[#2a2a2a] placeholder:text-[#525252] focus:border-[#e53e00]/60",
          )}
          disabled={set.completed}
        />
        <span className="font-data text-[9px] uppercase tracking-widest text-[#525252] shrink-0">
          {repsLabel}
        </span>
      </div>

      {/* Complete toggle — h-10 w-10 on mobile (≥44px), h-9 w-9 at sm+ */}
      <button
        type="button"
        onClick={() => onChange({ completed: !set.completed })}
        className={cn(
          "h-10 w-10 sm:h-9 sm:w-9 shrink-0 flex items-center justify-center border transition-all",
          set.completed
            ? "border-[#10B981] bg-[#10B981]/10 text-[#10B981]"
            : "border-[#2a2a2a] text-[#525252] hover:border-[#10B981]/60 hover:text-[#10B981]",
        )}
        aria-label={completeLabel}
      >
        <Check className="h-4 w-4" />
      </button>

      {/* Remove set — h-10 w-10 on mobile (≥44px), h-9 w-9 at sm+ */}
      <button
        type="button"
        onClick={onRemove}
        className="h-10 w-10 sm:h-9 sm:w-9 shrink-0 flex items-center justify-center text-[#525252] hover:text-destructive transition-colors"
        aria-label={removeSetLabel}
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}

// ─── ExerciseBlock ─────────────────────────────────────────────────────────────

function ExerciseBlock({
  ex,
  onUpdateSet,
  onAddSet,
  onRemoveSet,
  onRemoveExercise,
  t,
}: {
  ex: QuickExercise;
  onUpdateSet: (setIdx: number, patch: Partial<QuickSet>) => void;
  onAddSet: () => void;
  onRemoveSet: (setIdx: number) => void;
  onRemoveExercise: () => void;
  t: (key: string) => string;
}) {
  const [collapsed, setCollapsed] = useState(false);
  const completedCount = ex.sets.filter((s) => s.completed).length;

  // Build progression string: "60×10 → 65×8 → 70×6"
  const progression = ex.prev?.sets
    ?.map((s) => `${s.weight}${t("quickWorkout.WEIGHT_KG")}×${s.reps}`)
    .join(" → ");

  return (
    <div className="border border-[#2a2a2a] bg-[#0a0a0a] overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-3 px-3 py-2.5 border-b border-[#1a1a1a]">
        {ex.exercise?.gif || ex.exercise?.image ? (
          <div className="relative h-10 w-10 shrink-0 overflow-hidden bg-[#111]">
            <Image
              src={ex.exercise.gif || ex.exercise.image}
              alt={ex.name}
              fill
              className="object-cover"
              sizes="40px"
              unoptimized={ex.exercise.gif?.endsWith(".gif")}
            />
          </div>
        ) : (
          <div className="h-10 w-10 shrink-0 flex items-center justify-center bg-[#111] border border-[#2a2a2a]">
            <Zap className="h-4 w-4 text-[#525252]" />
          </div>
        )}

        <div className="flex-1 min-w-0">
          <p className="font-data text-[11px] font-bold uppercase tracking-wide text-[#e5e5e5] truncate">
            {ex.name}
          </p>
          <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 mt-0.5">
            {progression && (
              <span className="flex items-center gap-1 font-data text-[9px] tracking-widest text-[#e53e00]/60">
                <History className="h-2.5 w-2.5 shrink-0" />
                {progression}
              </span>
            )}
            {completedCount > 0 && (
              <span className="font-data text-[9px] uppercase tracking-widest text-[#10B981]">
                {t("quickWorkout.SETS_LOGGED").replace("{n}", String(completedCount))}
              </span>
            )}
          </div>
        </div>

        {/* h-10 w-10 on mobile for ≥44px touch target, compact at sm+ */}
        <button
          type="button"
          onClick={() => setCollapsed((c) => !c)}
          className="h-10 w-10 sm:h-8 sm:w-8 shrink-0 flex items-center justify-center text-[#525252] hover:text-[#e5e5e5] transition-colors"
        >
          {collapsed ? <ChevronDown className="h-4 w-4" /> : <ChevronUp className="h-4 w-4" />}
        </button>
        <button
          type="button"
          onClick={onRemoveExercise}
          className="h-10 w-10 sm:h-8 sm:w-8 shrink-0 flex items-center justify-center text-[#525252] hover:text-destructive transition-colors"
          aria-label={t("quickWorkout.REMOVE_EXERCISE")}
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      {!collapsed && (
        <div className="px-3 pb-2">
          <div>
            {ex.sets.map((set, si) => (
              <SetRow
                key={si}
                set={set}
                index={si}
                prev={ex.prev}
                weightLabel={t("quickWorkout.WEIGHT_KG")}
                repsLabel={t("quickWorkout.REPS")}
                completeLabel={t("quickWorkout.COMPLETE_SET")}
                removeSetLabel={t("quickWorkout.REMOVE_SET")}
                onChange={(patch) => onUpdateSet(si, patch)}
                onRemove={() => onRemoveSet(si)}
              />
            ))}
          </div>
          <button
            type="button"
            onClick={onAddSet}
            className="mt-2 w-full py-1.5 font-data text-[9px] font-bold uppercase tracking-widest text-[#e53e00] border border-dashed border-[#e53e00]/30 hover:border-[#e53e00]/60 transition-colors"
          >
            {t("quickWorkout.ADD_SET")}
          </button>
        </div>
      )}
    </div>
  );
}

// ─── SessionTimer ─────────────────────────────────────────────────────────────

function SessionTimer({ startedAt }: { startedAt: number }) {
  const [elapsed, setElapsed] = useState(0);
  useEffect(() => {
    const id = setInterval(() => setElapsed(Math.floor((Date.now() - startedAt) / 1000)), 1000);
    return () => clearInterval(id);
  }, [startedAt]);
  const h = Math.floor(elapsed / 3600);
  const m = Math.floor((elapsed % 3600) / 60);
  const s = elapsed % 60;
  const fmt = h > 0
    ? `${h}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
    : `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
  return (
    <span className="font-data text-[13px] font-bold tabular-nums tracking-widest text-[#e53e00]">
      {fmt}
    </span>
  );
}

// ─── Main Page ─────────────────────────────────────────────────────────────────

export default function QuickWorkoutPage() {
  const { t } = useI18n();
  const router = useRouter();
  const startedAt = useRef(Date.now());

  const [exercises, setExercises] = useState<QuickExercise[]>([]);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [showFinish, setShowFinish] = useState(false);
  const [mood, setMood] = useState<Mood | null>(null);
  const [notes, setNotes] = useState("");
  const [saving, setSaving] = useState(false);
  const [showDiscard, setShowDiscard] = useState(false);

  const totalCompleted = exercises.reduce(
    (acc, ex) => acc + ex.sets.filter((s) => s.completed).length,
    0,
  );

  const handlePickExercise = useCallback((ex: LibraryExercise) => {
    const history = readExerciseHistory();
    const prev = history[normalizeName(ex.name)] ?? null;
    setExercises((prev_) => [...prev_, newExercise(ex, prev)]);
  }, []);

  const handleUpdateSet = useCallback(
    (exIdx: number, setIdx: number, patch: Partial<QuickSet>) => {
      setExercises((prev) =>
        prev.map((ex, i) =>
          i !== exIdx
            ? ex
            : { ...ex, sets: ex.sets.map((s, j) => (j !== setIdx ? s : { ...s, ...patch })) },
        ),
      );
    },
    [],
  );

  const handleAddSet = useCallback((exIdx: number) => {
    setExercises((prev) =>
      prev.map((ex, i) => (i !== exIdx ? ex : { ...ex, sets: [...ex.sets, newSet()] })),
    );
  }, []);

  const handleRemoveSet = useCallback((exIdx: number, setIdx: number) => {
    setExercises((prev) =>
      prev.map((ex, i) => {
        if (i !== exIdx) return ex;
        const next = ex.sets.filter((_, j) => j !== setIdx);
        return { ...ex, sets: next.length ? next : [newSet()] };
      }),
    );
  }, []);

  const handleRemoveExercise = useCallback((exIdx: number) => {
    setExercises((prev) => prev.filter((_, i) => i !== exIdx));
  }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      const pb = getPocketBase();
      const userId = pb.authStore.record?.id;
      if (!userId) throw new Error("Not authenticated");

      const session = await pb.collection("workout_sessions").create({
        user: userId,
        planDay: null,
        plan: null,
        startedAt: new Date(startedAt.current).toISOString(),
        completedAt: new Date().toISOString(),
        status: "completed",
        mood: mood ?? null,
        energyLevel: moodToEnergy(mood),
        sessionNotes: notes,
      });

      for (const ex of exercises) {
        for (let i = 0; i < ex.sets.length; i++) {
          const s = ex.sets[i];
          if (!s.completed) continue;
          await pb.collection("session_sets").create({
            session: session.id,
            setNumber: i + 1,
            reps: Number(s.reps) || 0,
            weight: Number(s.weight) || 0,
            rpe: s.rpe,
            completed: true,
            notes: ex.name,
          });
        }
      }

      persistWorkoutSession(exercises, session.id, startedAt.current, mood, notes);

      toast.success(t("quickWorkout.SAVED"));
      router.push("/plans");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : t("common.SAVE_FAILED"));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="flex flex-col min-h-[100dvh] bg-[#050505] pb-24">
      {/* Top bar */}
      <div className="sticky top-0 z-30 flex items-center justify-between border-b border-[#2a2a2a] bg-[#050505]/95 backdrop-blur px-4 py-3">
        <SessionTimer startedAt={startedAt.current} />
        <span className="font-data text-[10px] font-bold uppercase tracking-widest text-[#71717A]">
          {t("quickWorkout.TITLE")}
        </span>
        <button
          type="button"
          onClick={() => exercises.length === 0 ? router.back() : setShowDiscard(true)}
          className="font-data text-[9px] uppercase tracking-widest text-[#525252] hover:text-[#e5e5e5] transition-colors"
        >
          {t("quickWorkout.DISCARD")}
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 px-4 py-4 space-y-3">
        {exercises.length === 0 ? (
          <div className="flex flex-col items-center justify-center min-h-[50vh] gap-4 text-center">
            <div className="h-16 w-16 border border-dashed border-[#2a2a2a] flex items-center justify-center">
              <Zap className="h-6 w-6 text-[#525252]" />
            </div>
            <div>
              <p className="font-data text-[11px] font-bold uppercase tracking-widest text-[#e5e5e5]">
                {t("quickWorkout.EMPTY_STATE")}
              </p>
              <p className="mt-1 font-data text-[9px] uppercase tracking-widest text-[#525252]">
                {t("quickWorkout.EMPTY_DESC")}
              </p>
            </div>
          </div>
        ) : (
          exercises.map((ex, exIdx) => (
            <ExerciseBlock
              key={ex.uid}
              ex={ex}
              onUpdateSet={(si, patch) => handleUpdateSet(exIdx, si, patch)}
              onAddSet={() => handleAddSet(exIdx)}
              onRemoveSet={(si) => handleRemoveSet(exIdx, si)}
              onRemoveExercise={() => handleRemoveExercise(exIdx)}
              t={t}
            />
          ))
        )}
      </div>

      {/* Bottom bar */}
      <div className="fixed bottom-0 left-0 right-0 z-20 border-t border-[#2a2a2a] bg-[#050505]/95 backdrop-blur px-4 py-3 flex items-center gap-3">
        <button
          type="button"
          onClick={() => setPickerOpen(true)}
          className="flex-1 flex min-w-0 items-center justify-center gap-1.5 border border-[#2a2a2a] py-3 font-data text-[10px] font-bold uppercase tracking-wide text-[#e5e5e5] hover:border-[#e53e00]/50 transition-colors"
        >
          <Plus className="h-3.5 w-3.5 shrink-0" />
          <span className="truncate">{t("quickWorkout.ADD_EXERCISE")}</span>
        </button>
        {exercises.length > 0 && (
          <button
            type="button"
            onClick={() => setShowFinish(true)}
            className="flex-1 flex min-w-0 items-center justify-center gap-1.5 bg-[#e53e00] py-3 font-data text-[10px] font-bold uppercase tracking-wide text-white hover:bg-[#ff4500] transition-colors"
          >
            <span className="truncate">{t("quickWorkout.FINISH")}</span>
          </button>
        )}
      </div>

      <ExercisePickerModal
        open={pickerOpen}
        onClose={() => setPickerOpen(false)}
        onSelect={handlePickExercise}
      />

      {/* Finish panel */}
      {showFinish && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70">
          <div className="w-full max-w-lg border-t border-[#2a2a2a] bg-[#0a0a0a] p-5 space-y-5">
            <div className="flex items-center justify-between">
              <span className="font-data text-[11px] font-bold uppercase tracking-widest text-[#e53e00]">
                {t("quickWorkout.HOW_DID_IT_FEEL")}
              </span>
              <button onClick={() => setShowFinish(false)} className="text-[#71717A] hover:text-[#e5e5e5]">
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="flex justify-between gap-2">
              {MOOD_OPTIONS.map((m) => (
                <button
                  key={m.value}
                  type="button"
                  onClick={() => setMood(mood === m.value ? null : m.value)}
                  className={cn(
                    "flex-1 flex flex-col items-center gap-1 border py-3 transition-all",
                    mood === m.value ? "border-[#e53e00] bg-[#e53e00]/10" : "border-[#2a2a2a] hover:border-[#525252]",
                  )}
                >
                  <span className="text-xl">{m.emoji}</span>
                </button>
              ))}
            </div>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder={t("quickWorkout.NOTES_PLACEHOLDER")}
              rows={2}
              className="w-full bg-[#111] border border-[#2a2a2a] px-3 py-2 font-data text-[11px] text-[#e5e5e5] placeholder:text-[#525252] focus:outline-none focus:border-[#e53e00]/60 resize-none"
            />
            <div className="flex items-center gap-3 border border-[#1a1a1a] bg-[#050505] px-3 py-2">
              <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
                {exercises.length} {exercises.length === 1 ? t("quickWorkout.EXERCISE_SINGULAR") : t("quickWorkout.EXERCISES_LABEL")}
              </span>
              <div className="h-3 w-px bg-[#2a2a2a]" />
              <span className="font-data text-[9px] uppercase tracking-widest text-[#10B981]">
                {t("quickWorkout.SETS_LOGGED").replace("{n}", String(totalCompleted))}
              </span>
            </div>
            <button
              type="button"
              onClick={handleSave}
              disabled={saving}
              className="w-full bg-[#e53e00] py-4 font-data text-[11px] font-bold uppercase tracking-wide text-white hover:bg-[#ff4500] transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {saving ? (
                <><Loader2 className="h-4 w-4 animate-spin" />{t("quickWorkout.SAVING")}</>
              ) : t("quickWorkout.SAVE_SESSION")}
            </button>
          </div>
        </div>
      )}

      {/* Discard confirmation */}
      {showDiscard && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4">
          <div className="w-full max-w-sm border border-[#8B0000]/50 bg-[#0a0a0a] p-6 space-y-4">
            <p className="font-data text-[11px] uppercase tracking-widest text-[#e5e5e5]">
              {t("quickWorkout.DISCARD_CONFIRM")}
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowDiscard(false)}
                className="flex-1 border border-[#2a2a2a] py-3 font-data text-[10px] font-bold uppercase tracking-widest text-[#e5e5e5] hover:bg-[#1a1a1a] transition-colors"
              >
                {t("quickWorkout.KEEP_GOING")}
              </button>
              <button
                onClick={() => router.back()}
                className="flex-1 bg-[#8B0000] py-3 font-data text-[10px] font-bold uppercase tracking-widest text-white hover:bg-[#9F1239] transition-colors"
              >
                {t("quickWorkout.DISCARD")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
