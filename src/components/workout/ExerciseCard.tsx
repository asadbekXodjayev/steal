"use client";

import { SetRow } from "./SetRow";
import { ExerciseMedia } from "./ExerciseMedia";
import type { ActiveSetInput } from "@/types/session";
import { formatDuration } from "@/lib/utils";
import { Clock, ChevronDown, ChevronUp, BookOpen } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface ExerciseCardProps {
  exerciseName: string;
  exerciseNumber: number;
  sets: number;
  repsMin: number;
  repsMax: number;
  rpeTarget: number;
  restSeconds: number;
  notes: string;
  completedSets: ActiveSetInput[];
  onCompleteSet: (data: ActiveSetInput) => void;
  isActive: boolean;
}

export function ExerciseCard({
  exerciseName,
  exerciseNumber,
  sets,
  repsMin,
  repsMax,
  rpeTarget,
  restSeconds,
  notes,
  completedSets,
  onCompleteSet,
  isActive,
}: ExerciseCardProps) {
  const { t } = useI18n();
  const [collapsed, setCollapsed] = useState(false);
  const [mediaOpen, setMediaOpen] = useState(false);
  const targetReps = repsMin === repsMax ? `${repsMin}` : `${repsMin}–${repsMax}`;
  const allComplete = completedSets.length >= sets;

  const delay = Math.min(exerciseNumber, 5);

  return (
    <div
      className={cn(
        `fade-up fade-up-${delay}`,
        allComplete ? "glass opacity-50" : isActive ? "glass-acc" : "glass",
      )}
    >
      {/* Exercise header */}
      <button
        type="button"
        onClick={() => setCollapsed((c) => !c)}
        className="flex w-full items-center gap-3 p-3 text-left"
      >
        <span className="font-data text-[8px] text-[#2a2a2a] w-5 shrink-0 tabular-nums">
          {String(exerciseNumber).padStart(2, "0")}
        </span>

        <div className="min-w-0 flex-1">
          <p
            className={cn(
              "font-heading truncate text-[15px] font-bold uppercase leading-tight",
              allComplete ? "text-[#333]" : isActive ? "text-[#f0f0f0]" : "text-[#ccc]",
            )}
          >
            {exerciseName}
          </p>
          <div className="mt-0.5 flex items-center gap-2">
            <span className="font-data text-[7px] text-[#333]">
              {sets} × {targetReps}
            </span>
            {restSeconds > 0 && (
              <span className="font-data text-[7px] text-[#333] flex items-center gap-0.5">
                <Clock className="h-2.5 w-2.5" />
                {formatDuration(restSeconds)}
              </span>
            )}
            <span className={cn("font-data text-[7px] tabular-nums", isActive ? "text-[#C2410C]" : "text-[#444]")}>
              {completedSets.length}/{sets}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-1 shrink-0">
          {allComplete && <span className="text-[#22c55e] text-sm">✓</span>}
          {isActive && (
            <span className="tag-pill tag-pill-acc text-[8px]">ACTIVE</span>
          )}
          {!allComplete && !isActive && (
            <span className="font-data text-[14px] text-[#222]">›</span>
          )}
          <button
            type="button"
            onClick={(e) => { e.stopPropagation(); setMediaOpen((o) => !o); }}
            aria-label={mediaOpen ? t("workout.HIDE_TUTORIAL") : t("workout.SHOW_TUTORIAL")}
            className={cn(
              "flex items-center gap-1 px-1.5 py-0.5 font-data text-[8px] uppercase tracking-widest border transition-colors",
              mediaOpen
                ? "border-[rgba(194,65,12,0.5)] text-[#C2410C] bg-[rgba(194,65,12,0.1)]"
                : "border-[rgba(255,255,255,0.08)] text-[#444] hover:border-[rgba(194,65,12,0.3)]",
            )}
          >
            <BookOpen className="h-2.5 w-2.5" />
          </button>
          {collapsed
            ? <ChevronDown className="h-4 w-4 shrink-0 text-[#444]" />
            : <ChevronUp className="h-4 w-4 shrink-0 text-[#444]" />
          }
        </div>
      </button>

      {/* Body */}
      {!collapsed && (
        <div style={{ borderTop: "1px solid rgba(255,255,255,0.05)" }}>
          {/* Media / Tutorial */}
          {mediaOpen ? (
            <div className="p-3" style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
              <ExerciseMedia exerciseName={exerciseName} size="card" />
            </div>
          ) : (
            /* GIF placeholder when media is hidden */
            <div
              className="mx-3 mt-2"
              style={{
                height: 100,
                background: "rgba(0,0,0,0.4)",
                border: "1px dashed rgba(255,255,255,0.06)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                position: "relative",
                overflow: "hidden",
              }}
            >
              <div
                style={{
                  position: "absolute",
                  inset: 0,
                  background:
                    "repeating-linear-gradient(-45deg, rgba(194,65,12,0.03) 0, rgba(194,65,12,0.03) 2px, transparent 2px, transparent 12px)",
                }}
              />
              <div className="relative text-center">
                <div style={{ fontSize: 28, opacity: 0.15 }}>▶</div>
                <span className="font-data block text-[8px] text-[#2a2a2a] mt-1 tracking-widest uppercase">
                  EXERCISE GIF
                </span>
              </div>
            </div>
          )}

          {/* Coach note */}
          {notes?.trim() && (
            <div
              className="px-3 py-2 mx-3 mt-2"
              style={{ borderBottom: "1px solid rgba(255,255,255,0.05)", background: "rgba(0,0,0,0.3)" }}
            >
              <p className="font-data text-xs text-[#444]">{notes}</p>
            </div>
          )}

          {/* Column headers */}
          <div className="grid grid-cols-[2rem_1fr_1fr_2.5rem] gap-2 px-3 py-2">
            <span className="font-data text-[7px] uppercase tracking-widest text-[#222]">SET</span>
            <span className="font-data text-[7px] uppercase tracking-widest text-[#222] text-center">WEIGHT</span>
            <span className="font-data text-[7px] uppercase tracking-widest text-[#222] text-center">REPS</span>
            <span />
          </div>

          {/* Set rows */}
          <div>
            {Array.from({ length: sets }).map((_, i) => (
              <SetRow
                key={i}
                setNumber={i + 1}
                targetReps={targetReps}
                completed={completedSets[i]}
                previousWeight={completedSets[i - 1]?.weight}
                previousReps={completedSets[i - 1]?.reps}
                onComplete={onCompleteSet}
                isActive={isActive && i === completedSets.length}
              />
            ))}
          </div>

          {/* Action buttons — h-10 minimum for 44px touch target on mobile */}
          <div className="flex gap-2 p-3" style={{ borderTop: "1px solid rgba(255,255,255,0.04)" }}>
            <button
              type="button"
              className="btn-ghost flex-1 h-10 sm:h-8 text-[10px]"
              onClick={() => onCompleteSet({ weight: 0, reps: 0, rpe: 7 })}
            >
              + Add Set
            </button>
            <button
              type="button"
              className="btn-forge h-10 sm:h-8 text-[12px]"
              style={{ flex: 2 }}
              onClick={() => {
                const last = completedSets[completedSets.length - 1];
                onCompleteSet({ weight: last?.weight ?? 0, reps: last?.reps ?? 0, rpe: 7 });
              }}
            >
              Log Set ✓
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
