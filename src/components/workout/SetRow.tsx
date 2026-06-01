"use client";

import { useState } from "react";
import type { ActiveSetInput } from "@/types/session";
import { Check } from "lucide-react";

interface SetRowProps {
  setNumber: number;
  targetReps: string;
  previousWeight?: number;
  previousReps?: number;
  completed?: ActiveSetInput;
  onComplete: (data: ActiveSetInput) => void;
  isActive?: boolean;
}

export function SetRow({
  setNumber,
  targetReps,
  previousWeight,
  previousReps,
  completed,
  onComplete,
  isActive = false,
}: SetRowProps) {
  const [weight, setWeight] = useState(completed?.weight ?? previousWeight ?? 0);
  const [reps, setReps] = useState(completed?.reps ?? previousReps ?? 0);

  const isCompleted = !!completed;

  function handleComplete() {
    if (reps === 0 && weight === 0) return;
    onComplete({ weight, reps, rpe: 7 });
  }

  if (isCompleted) {
    return (
      <div
        // Use min-w-0 on the row so it doesn't overflow the card at 360px
        className="grid grid-cols-[2rem_1fr_1fr_2.5rem] items-center gap-2 px-3 py-2 mb-1 min-w-0"
        style={{
          border: "1px solid rgba(34,197,94,0.2)",
          background: "rgba(34,197,94,0.04)",
        }}
      >
        <span className="font-data text-[9px] text-[#222] tabular-nums">{setNumber}</span>
        <span className="font-data text-sm font-bold tabular-nums text-[#e0e0e0] text-center">
          {completed.weight > 0 ? completed.weight : "—"}
        </span>
        <span className="font-data text-sm font-bold tabular-nums text-[#e0e0e0] text-center">
          {completed.reps}
        </span>
        {/* ≥44px touch target on mobile, shrinks at sm+ */}
        <div
          className="flex h-10 w-10 sm:h-7 sm:w-7 items-center justify-center"
          style={{ border: "1.5px solid rgba(34,197,94,0.4)", background: "rgba(34,197,94,0.1)" }}
        >
          <span style={{ color: "#22c55e", fontSize: 14 }}>✓</span>
        </div>
      </div>
    );
  }

  return (
    <div
      className="grid grid-cols-[2rem_1fr_1fr_2.5rem] items-center gap-2 px-3 py-2 mb-1 transition-all min-w-0"
      style={
        isActive
          ? { border: "1px solid rgba(194,65,12,0.4)", background: "rgba(194,65,12,0.06)" }
          : { border: "1px solid rgba(255,255,255,0.05)", background: "transparent" }
      }
    >
      <span className="font-data text-[9px] text-[#222] tabular-nums">{setNumber}</span>

      {/* Weight input — h-10 on mobile for comfortable tapping, h-7 at sm+ */}
      <input
        type="number"
        inputMode="decimal"
        min={0}
        step={2.5}
        value={weight || ""}
        onChange={(e) => setWeight(Number(e.target.value))}
        placeholder={previousWeight ? String(previousWeight) : "kg"}
        className="h-10 sm:h-7 w-full text-center font-data text-sm font-bold tabular-nums focus:outline-none"
        style={
          isActive
            ? {
                border: "1px solid rgba(194,65,12,0.5)",
                color: "#C2410C",
                background: "rgba(194,65,12,0.08)",
              }
            : {
                border: "1px solid rgba(255,255,255,0.08)",
                color: "#e0e0e0",
                background: "rgba(0,0,0,0.5)",
              }
        }
        aria-label={`Set ${setNumber} weight`}
      />

      {/* Reps input — h-10 on mobile for comfortable tapping, h-7 at sm+ */}
      <input
        type="number"
        inputMode="numeric"
        min={0}
        max={100}
        value={reps || ""}
        onChange={(e) => setReps(Number(e.target.value))}
        placeholder={previousReps ? String(previousReps) : targetReps}
        className="h-10 sm:h-7 w-full text-center font-data text-sm font-bold tabular-nums focus:outline-none"
        style={
          isActive
            ? {
                border: "1px solid rgba(194,65,12,0.5)",
                color: "#C2410C",
                background: "rgba(194,65,12,0.08)",
              }
            : {
                border: "1px solid rgba(255,255,255,0.08)",
                color: "#e0e0e0",
                background: "rgba(0,0,0,0.5)",
              }
        }
        aria-label={`Set ${setNumber} reps`}
      />

      {/* Done button — h-10 w-10 on mobile, h-7 w-7 at sm+ */}
      <button
        type="button"
        onClick={handleComplete}
        disabled={reps === 0 && weight === 0}
        className="flex h-10 w-10 sm:h-7 sm:w-7 items-center justify-center transition-colors disabled:opacity-30"
        style={{
          border: `1.5px solid ${(reps > 0 || weight > 0) ? "#C2410C" : "rgba(255,255,255,0.08)"}`,
          background: (reps > 0 || weight > 0) ? "rgba(194,65,12,0.1)" : "transparent",
        }}
        aria-label={`Log set ${setNumber}`}
      >
        {isActive && (reps > 0 || weight > 0) ? (
          <span style={{ color: "#C2410C", fontSize: 14 }}>✓</span>
        ) : (
          <Check className="h-3.5 w-3.5" style={{ color: (reps > 0 || weight > 0) ? "#C2410C" : "#333" }} />
        )}
      </button>
    </div>
  );
}
