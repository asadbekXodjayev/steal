"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import { X, Zap, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";
import { readSessionLog, type SessionLogEntry } from "@/lib/workout-history";

const MOOD_EMOJI: Record<string, string> = {
  great: "💪", good: "😊", okay: "😐", rough: "😔", terrible: "😞",
};

function formatDuration(seconds: number): string {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h}h ${m}m`;
  if (m > 0) return `${m}m`;
  return `${seconds}s`;
}

function formatDate(iso: string, t: (key: string) => string): string {
  const d = new Date(iso);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - d.getTime()) / 86400000);
  if (diffDays === 0) return t("common.TODAY");
  if (diffDays === 1) return t("common.YESTERDAY");
  if (diffDays < 7) return t("common.DAYS_AGO").replace("{n}", String(diffDays));
  return d.toLocaleDateString(undefined, { month: "short", day: "numeric" });
}

function SessionDetailModal({
  session,
  onClose,
  t,
}: {
  session: SessionLogEntry;
  onClose: () => void;
  t: (key: string) => string;
}) {
  const totalSets = session.exercises.reduce((a, ex) => a + ex.sets.length, 0);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/80 p-0 sm:p-4"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <div className="relative flex h-[95svh] sm:h-[85svh] md:h-[75vh] w-full sm:max-w-lg flex-col border border-[#2a2a2a] bg-[#0a0a0a] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-[#2a2a2a] px-4 py-3 shrink-0">
          <div>
            <span className="font-data text-[10px] font-bold uppercase tracking-widest text-[#e53e00]">
              {formatDate(session.date, t)}
            </span>
            <div className="flex items-center gap-3 mt-0.5">
              <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
                {formatDuration(session.duration)}
              </span>
              <span className="font-data text-[9px] uppercase tracking-widest text-[#525252]">
                {session.exercises.length} {t("quickWorkout.EXERCISES_LABEL")}
              </span>
              <span className="font-data text-[9px] uppercase tracking-widest text-[#10B981]">
                {t("quickWorkout.SETS_LOGGED").replace("{n}", String(totalSets))}
              </span>
            </div>
          </div>
          <div className="flex items-center gap-3">
            {session.mood && (
              <span className="text-lg">{MOOD_EMOJI[session.mood]}</span>
            )}
            <button
              onClick={onClose}
              className="text-[#71717A] hover:text-[#e5e5e5] transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Exercise list */}
        <div className="flex-1 overflow-y-auto divide-y divide-[#1a1a1a]">
          {session.exercises.map((ex, i) => (
            <div key={i} className="px-4 py-3">
              {/* Exercise name + thumbnail */}
              <div className="flex items-center gap-3 mb-2">
                {ex.image ? (
                  <div className="relative h-9 w-9 shrink-0 overflow-hidden bg-[#111]">
                    <Image
                      src={ex.image}
                      alt={ex.name}
                      fill
                      className="object-cover"
                      sizes="36px"
                      unoptimized={ex.image.endsWith(".gif")}
                    />
                  </div>
                ) : (
                  <div className="h-9 w-9 shrink-0 flex items-center justify-center bg-[#111] border border-[#2a2a2a]">
                    <Zap className="h-3.5 w-3.5 text-[#525252]" />
                  </div>
                )}
                <p className="font-data text-[11px] font-bold uppercase tracking-wide text-[#e5e5e5] truncate">
                  {ex.name}
                </p>
              </div>

              {/* Set breakdown */}
              <div className="flex flex-wrap gap-2 pl-12">
                {ex.sets.map((s, si) => (
                  <div
                    key={si}
                    className="flex items-center gap-1 bg-[#111] border border-[#1a1a1a] px-2 py-1"
                  >
                    <span className="font-data text-[8px] text-[#525252] tabular-nums">
                      {si + 1}
                    </span>
                    <span className="font-data text-[9px] font-bold text-[#e5e5e5] tabular-nums">
                      {s.weight}
                      <span className="text-[#525252] font-normal">kg</span>
                      {" × "}
                      {s.reps}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          ))}

          {/* Notes */}
          {session.notes && (
            <div className="px-4 py-3">
              <p className="font-data text-[9px] uppercase tracking-widest text-[#525252] mb-1">
                {t("quickWorkout.NOTES_PLACEHOLDER")}
              </p>
              <p className="font-data text-[11px] text-[#71717A]">{session.notes}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export function SessionHistory() {
  const { t } = useI18n();
  const [sessions, setSessions] = useState<SessionLogEntry[]>([]);
  const [selected, setSelected] = useState<SessionLogEntry | null>(null);

  useEffect(() => {
    setSessions(readSessionLog());
  }, []);

  if (sessions.length === 0) {
    return (
      <div className="border border-dashed border-[#2a2a2a] bg-[#0a0a0a] p-12 text-center">
        <Zap className="mx-auto h-8 w-8 text-[#525252] mb-3" />
        <p className="font-data text-[10px] font-bold uppercase tracking-widest text-[#525252]">
          {t("quickWorkout.SESSION_EMPTY")}
        </p>
        <p className="mt-1 font-data text-[9px] uppercase tracking-widest text-[#3a3a3a]">
          {t("quickWorkout.SESSION_EMPTY_DESC")}
        </p>
      </div>
    );
  }

  return (
    <>
      <div className="space-y-2">
        {sessions.map((session) => {
          const totalSets = session.exercises.reduce((a, ex) => a + ex.sets.length, 0);
          return (
            <button
              key={session.id}
              type="button"
              onClick={() => setSelected(session)}
              className="group w-full text-left border border-[#2a2a2a] bg-[#0a0a0a] hover:border-[#e53e00]/40 transition-colors overflow-hidden"
            >
              {/* Top row */}
              <div className="flex items-center justify-between px-4 py-3 border-b border-[#1a1a1a]">
                <div className="flex items-center gap-3">
                  {session.mood && (
                    <span className="text-base leading-none">
                      {MOOD_EMOJI[session.mood]}
                    </span>
                  )}
                  <div>
                    <p className="font-data text-[11px] font-bold uppercase tracking-widest text-[#e5e5e5]">
                      {formatDate(session.date, t)}
                    </p>
                    <p className="font-data text-[9px] uppercase tracking-widest text-[#525252] mt-0.5">
                      {formatDuration(session.duration)}
                      {"  ·  "}
                      {session.exercises.length}{" "}
                      {t("quickWorkout.EXERCISES_LABEL").toLowerCase()}
                      {"  ·  "}
                      <span className="text-[#10B981]">
                        {t("quickWorkout.SETS_LOGGED").replace("{n}", String(totalSets))}
                      </span>
                    </p>
                  </div>
                </div>
                <ChevronRight className="h-3.5 w-3.5 text-[#525252] group-hover:text-[#e53e00] transition-colors" />
              </div>

              {/* Exercise thumbnails + names */}
              <div className="flex items-center gap-2 px-4 py-2.5 overflow-x-auto scrollbar-custom">
                {session.exercises.slice(0, 5).map((ex, i) => (
                  <div key={i} className="flex items-center gap-1.5 shrink-0">
                    {ex.image ? (
                      <div className="relative h-7 w-7 overflow-hidden bg-[#111]">
                        <Image
                          src={ex.image}
                          alt={ex.name}
                          fill
                          className="object-cover"
                          sizes="28px"
                          unoptimized={ex.image.endsWith(".gif")}
                        />
                      </div>
                    ) : (
                      <div className="h-7 w-7 flex items-center justify-center bg-[#111] border border-[#1a1a1a]">
                        <Zap className="h-3 w-3 text-[#525252]" />
                      </div>
                    )}
                    <span className="font-data text-[8px] uppercase tracking-widest text-[#71717A] max-w-[60px] truncate">
                      {ex.name}
                    </span>
                  </div>
                ))}
                {session.exercises.length > 5 && (
                  <span className="font-data text-[8px] uppercase tracking-widest text-[#525252] shrink-0">
                    +{session.exercises.length - 5}
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {selected && (
        <SessionDetailModal
          session={selected}
          onClose={() => setSelected(null)}
          t={t}
        />
      )}
    </>
  );
}
