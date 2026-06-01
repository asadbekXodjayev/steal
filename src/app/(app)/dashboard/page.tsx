"use client";

import Link from "next/link";
import { useEffect, useState, useMemo } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useActivePlan, usePlanDays, usePlanExercises, usePlanDaySession } from "@/hooks/usePlans";
import { useStreakData, usePersonalRecords, useSessions, useAllSets } from "@/hooks/useProgress";
import { CounterFX } from "@/components/fx/ImpactFlash";
import { useI18n } from "@/components/providers/I18nProvider";
import {
  Trophy,
  Dumbbell,
  TrendingUp,
  CheckCircle2,
  Play,
  Calendar,
} from "lucide-react";
import { cn } from "@/lib/utils";

// ─── Tactical clock ──────────────────────────────────────────────────────────
function TacticalClock() {
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 60_000);
    return () => clearInterval(id);
  }, []);

  const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
  const dd = String(now.getDate()).padStart(2, "0");
  const mon = months[now.getMonth()];
  const yy = String(now.getFullYear()).slice(2);
  const hh = String(now.getHours()).padStart(2, "0");
  const mm = String(now.getMinutes()).padStart(2, "0");

  return (
    <span className="font-data text-[12px] tracking-widest text-ink-mid tabular-nums">
      {dd}{mon}{yy} {hh}:{mm}
    </span>
  );
}

// ─── KPI Panel ────────────────────────────────────────────────────────────────
interface KpiPanelProps {
  label: string;
  value: number;
  unit?: string;
  subValue?: string;
  icon: React.ReactNode;
  accent?: "orange" | "green" | "blue" | "default";
  tag?: string;
  trend?: "up" | "down" | "neutral";
}

function KpiPanel({ label, value, unit, subValue, icon, accent = "orange", tag = "01", trend }: KpiPanelProps) {
  const textColor =
    accent === "green" ? "#22c55e" :
    accent === "blue"  ? "#3b82f6" :
    "#C2410C";

  const kpiType =
    accent === "green" ? "kpi-grn" :
    accent === "blue"  ? "kpi-blu" :
    "kpi-acc";

  return (
    <div className={`glass kpi ${kpiType} glass-hover fade-up`}>
      <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{label}</span>
      <div
        className="font-heading tabular-nums leading-none"
        style={{ fontSize: 26, fontWeight: 700, color: textColor }}
      >
        <CounterFX value={value} />
      </div>
      {unit && (
        <span className="font-data mt-1 block text-[10px] text-ink-mid uppercase">{unit}</span>
      )}
      {subValue && (
        <span className="font-data mt-0.5 block text-[10px] text-ink-low">{subValue}</span>
      )}
    </div>
  );
}

// ─── Session History Item ─────────────────────────────────────────────────────
interface SessionHistoryItemProps {
  dayLabel: string;
  muscleTags: string[];
  isCompleted: boolean;
  isUpcoming?: boolean;
  isLocked?: boolean;
  dateStr?: string;
  t: (path: string) => string;
}

function SessionHistoryItem({ dayLabel, muscleTags, isCompleted, isUpcoming, isLocked, dateStr, t }: SessionHistoryItemProps) {
  return (
    <div className={cn(
      "flex items-center gap-3 py-2 px-3 border border-[#2a2a2a] relative overflow-hidden",
      isCompleted ? "bg-[#0a0a0a]" : isLocked ? "bg-[#0a0a0a]" : "bg-[#111111]"
    )}>
      {isCompleted && (
        <div className="absolute inset-0 bg-[#10b981]/5 pointer-events-none" />
      )}
      {isUpcoming && !isLocked && (
        <div className="absolute inset-0 bg-[#e53e00]/5 pointer-events-none" />
      )}
      {isLocked && (
        <div className="absolute inset-0 bg-[#2a2a2a]/10 pointer-events-none" />
      )}
      
      <div className="relative z-10 flex items-center gap-3 flex-1">
        {isCompleted ? (
          <div className="flex items-center justify-center w-8 h-8 bg-[#10b981]/10 border border-[#10b981]/30">
            <CheckCircle2 className="h-4 w-4 text-[#10b981]" />
          </div>
        ) : isLocked ? (
          <div className="flex items-center justify-center w-8 h-8 bg-[#525252]/10 border border-[#525252]/30">
            <Calendar className="h-4 w-4 text-[#525252]" />
          </div>
        ) : (
          <div className="flex items-center justify-center w-8 h-8 bg-[#e53e00]/10 border border-[#e53e00]/30">
            <Calendar className="h-4 w-4 text-[#e53e00]" />
          </div>
        )}
        
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className={cn(
              "font-data text-xs font-bold uppercase tracking-wide",
              isCompleted ? "text-[#a3a3a3]" : isLocked ? "text-[#525252]" : "text-[#e5e5e5]"
            )}>
              {dayLabel}
            </span>
            {isCompleted && (
              <span className="stamp text-[10px] text-[#10b981]">{t("dashboard.DONE")}</span>
            )}
            {isUpcoming && !isLocked && (
              <span className="stamp text-[10px] text-[#e53e00]">{t("dashboard.NEXT")}</span>
            )}
            {isLocked && (
              <span className="stamp text-[10px] text-ink-low">{t("dashboard.LOCKED")}</span>
            )}
          </div>
          {muscleTags.length > 0 && (
            <div className="flex gap-1 mt-0.5">
              {muscleTags.slice(0, 3).map((tag) => (
                <span key={tag} className={cn(
                  "px-1 py-0.5 border font-data text-[10px] uppercase tracking-[0.08em] sm:tracking-widest",
                  isLocked
                    ? "border-[#2a2a2a] text-[#3a3a3a]"
                    : "border-[#2a2a2a] text-[#525252]"
                )}>
                  {tag}
                </span>
              ))}
            </div>
          )}
        </div>
        
        {dateStr && !isLocked && (
          <span className="font-data text-[11px] text-ink-low">{dateStr}</span>
        )}
        {isLocked && (
          <span className="font-data text-[11px] text-ink-dim">--</span>
        )}
      </div>
    </div>
  );
}

// ─── Skeleton grid ────────────────────────────────────────────────────────────
function SkeletonGrid() {
  return (
    <div className="space-y-6 py-6">
      <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-5">
        <div className="skeleton-steal h-6 w-64 mb-2" />
        <div className="skeleton-steal h-4 w-40" />
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="border border-[#2a2a2a] bg-[#0a0a0a] p-3 min-h-[140px]">
            <div className="skeleton-steal h-3 w-20 mb-4" />
            <div className="skeleton-steal h-12 w-16" />
          </div>
        ))}
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
        <div className="lg:col-span-8 border border-[#2a2a2a] bg-[#0a0a0a] p-4 sm:p-6 min-h-[200px] lg:min-h-[280px]">
          <div className="skeleton-steal h-4 w-32 mb-4" />
          <div className="skeleton-steal h-8 w-56 mb-3" />
          <div className="space-y-2">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="skeleton-steal h-3 w-full" />
            ))}
          </div>
        </div>
        <div className="lg:col-span-4 border border-[#2a2a2a] bg-[#0a0a0a] p-4 sm:p-5 min-h-[200px] lg:min-h-[280px]">
          <div className="skeleton-steal h-3 w-24 mb-4" />
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="skeleton-steal h-10 w-full" />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Active Mission panel ─────────────────────────────────────────────────────
function ActiveMissionPanel({ planId, t }: { planId: string; t: (path: string) => string }) {
  const { data: days, isLoading } = usePlanDays(planId);
  const { data: sessions } = useSessions();
  const today = new Date().getDay() || 7;

  // Find the next session in line (first uncompleted one)
  const nextSessionDay = useMemo(() => {
    if (!days || days.length === 0) return null;
    
    // Sort days by week first, then by dayOfWeek
    const sortedDays = [...days].sort((a, b) => {
      if (a.week !== b.week) return a.week - b.week;
      return a.dayOfWeek - b.dayOfWeek;
    });

    // Create a map of completed planDay IDs
    const completedPlanDayIds = new Set(
      sessions
        ?.filter(s => s.status === 'completed')
        .map(s => s.planDay)
        .filter((id): id is string => !!id) || []
    );

    // Find the first uncompleted session; null means program is fully complete
    return sortedDays.find(d => !completedPlanDayIds.has(d.id)) ?? null;
  }, [days, sessions]);

  const { data: exercises, isLoading: exLoading } = usePlanExercises(
    nextSessionDay?.id
  );
  const { data: completedSession } = usePlanDaySession(nextSessionDay?.id);

  if (isLoading || exLoading) {
    return (
      <div className="space-y-2">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="skeleton-steal h-4 w-full" />
        ))}
      </div>
    );
  }

  if (!nextSessionDay) {
    if (days && days.length > 0) {
      return (
        <div className="flex flex-col gap-3 py-2">
          <div className="flex items-center gap-2 text-[#10b981]">
            <CheckCircle2 className="h-4 w-4" />
            <span className="font-data text-sm font-bold uppercase tracking-widest">{t("dashboard.PROGRAM_COMPLETE")}</span>
          </div>
          <p className="stamp text-[10px] text-[#525252]">{t("dashboard.ALL_SESSIONS_COMPLETED")}</p>
        </div>
      );
    }
    return (
      <p className="stamp text-[10px] text-[#525252]">{t("dashboard.NO_TRAINING_DAYS_CONFIGURED")}</p>
    );
  }

  const estMinutes = exercises
    ? Math.round((exercises.reduce((acc, ex) => acc + ex.sets * (ex.restSeconds + 45), 0)) / 60)
    : 0;

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3 flex-wrap">
        <span className="stamp text-[11px] tracking-[0.18em] text-ink-low">{t("dashboard.DAY")}</span>
        <span className="font-data text-sm font-bold text-[#e5e5e5] uppercase tracking-widest">
          {nextSessionDay.label}
        </span>
        {nextSessionDay.focus.length > 0 && (
          <div className="flex gap-1">
            {nextSessionDay.focus.map((f: string) => (
              <span
                key={f}
                className="px-2 py-0.5 border border-[#2a2a2a] font-data text-[10px] uppercase tracking-widest text-ink-low"
              >
                {f}
              </span>
            ))}
          </div>
        )}
        {completedSession && (
          <div className="flex items-center gap-1.5 text-[#10b981]">
            <CheckCircle2 className="h-3.5 w-3.5" />
            <span className="font-data text-[10px] uppercase tracking-widest">{t("dashboard.COMPLETED")}</span>
          </div>
        )}
      </div>

      {exercises && exercises.length > 0 && (
        <div className="space-y-1.5">
          <div className="h-px bg-[#1a1a1a]" />
          {exercises.slice(0, 6).map((ex, i) => {
            const exName = ex.expand?.exercise?.name ?? ex.name ?? ex.exercise;
            return (
              <div
                key={ex.id}
                className="flex items-center gap-3 py-1.5 px-2 hover:bg-[#1a1a1a] transition-colors group"
              >
                <span className="stamp text-[10px] text-ink-low w-5 shrink-0">
                  {String(i + 1).padStart(2, "0")}
                </span>
                <span className="font-data text-xs text-[#e5e5e5] flex-1 uppercase tracking-wide group-hover:text-[#e53e00] transition-colors truncate">
                  {exName}
                </span>
                <span className="stamp text-[10px] text-ink-low shrink-0">
                  {ex.sets}×{ex.repsMin}
                  {ex.repsMin !== ex.repsMax ? `-${ex.repsMax}` : ""}
                </span>
              </div>
            );
          })}
          {exercises.length > 6 && (
            <p className="stamp text-[10px] text-ink-low pl-2">
              +{exercises.length - 6} {t("dashboard.MORE")}
            </p>
          )}
        </div>
      )}

      {estMinutes > 0 && (
        <div className="flex items-center gap-2 pt-1">
          <span className="stamp text-[10px] text-ink-low">{t("dashboard.EST_MIN").replace("MIN", `${estMinutes} MIN`)}</span>
        </div>
      )}

      <Link
        href={`/workout/${nextSessionDay.id}`}
        className={cn(
          "btn-forge w-full h-9 text-[12px] font-heading mt-1",
          completedSession && "opacity-60 pointer-events-none"
        )}
      >
        {completedSession ? (
          <><CheckCircle2 className="mr-2 h-3.5 w-3.5" />[ {t("dashboard.COMPLETED")} ]</>
        ) : (
          <><Play className="mr-2 h-3.5 w-3.5" />[ {t("dashboard.DEPLOY_START").replace("[", "").replace("]", "")} ]</>
        )}
      </Link>
    </div>
  );
}

// ─── Session History Panel ────────────────────────────────────────────────────
function SessionHistoryPanel({ planId, t }: { planId: string; t: (path: string) => string }) {
  const { data: days, isLoading } = usePlanDays(planId);
  const { data: sessions } = useSessions();

  const today = new Date().getDay() || 7; // 1=Monday, 7=Sunday

  // Calculate upcoming session dates
  function getNextSessionDate(dayOfWeek: number, weekOffset: number = 0): string {
    const now = new Date();
    const currentDay = now.getDay() || 7;
    let daysUntil = dayOfWeek - currentDay;
    if (daysUntil <= 0) daysUntil += 7;
    daysUntil += weekOffset * 7;
    
    const nextDate = new Date(now);
    nextDate.setDate(now.getDate() + daysUntil);
    
    const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
    const dd = String(nextDate.getDate()).padStart(2, "0");
    const mon = months[nextDate.getMonth()];
    return `${dd}${mon}`;
  }

  // Get the sequential index of a plan day (for ordering)
  function getDaySequenceIndex(day: any): number {
    return (day.week - 1) * 7 + (day.dayOfWeek - 1);
  }

  // Build session history data
  const sessionHistory = useMemo(() => {
    if (!days) return { upcoming: [], completed: [] };

    // Create a map of completed planDay IDs with their completion status
    const completedSessionMap = new Map(
      sessions
        ?.filter(s => s.status === 'completed')
        .map(s => [s.planDay, true]) || []
    );

    // Sort days by week first, then by dayOfWeek for proper sequential order
    const sortedDays = [...days].sort((a, b) => {
      if (a.week !== b.week) return a.week - b.week;
      return a.dayOfWeek - b.dayOfWeek;
    });

    // Find the FIRST uncompleted session - this is the current active session
    const firstUncompletedIndex = sortedDays.findIndex(d => !completedSessionMap.has(d.id));
    const startIndex = firstUncompletedIndex >= 0 ? firstUncompletedIndex : 0;

    const upcoming: Array<Omit<SessionHistoryItemProps, "t"> & { dateStr: string; isLocked: boolean }> = [];
    const completed: Omit<SessionHistoryItemProps, "t">[] = [];

    // Function to calculate the next date for a given day of week
    function calculateSessionDate(dayOfWeek: number, sessionIndex: number): string {
      const now = new Date();
      const currentDay = now.getDay() || 7; // 1=Monday, 7=Sunday
      
      // Calculate days until the target day of week
      let daysUntil = dayOfWeek - currentDay;
      if (daysUntil <= 0) daysUntil += 7;
      
      // Add week offset based on session position
      // For sessions in the same week pattern, calculate based on actual day differences
      const weekOffset = Math.floor(sessionIndex / sortedDays.filter(d => d.week === 1).length);
      daysUntil += weekOffset * 7;
      
      const targetDate = new Date(now);
      targetDate.setDate(now.getDate() + daysUntil);
      
      const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
      const dd = String(targetDate.getDate()).padStart(2, "0");
      const mon = months[targetDate.getMonth()];
      return `${dd}${mon}`;
    }

    // Collect upcoming sessions (starting from the first uncompleted one)
    let collectedCount = 0;
    
    for (let i = startIndex; i < sortedDays.length && collectedCount < 3; i++) {
      const day = sortedDays[i];
      const isCompleted = completedSessionMap.has(day.id);
      
      if (!isCompleted) {
        const dateStr = calculateSessionDate(day.dayOfWeek, collectedCount);
        
        upcoming.push({
          dayLabel: day.label,
          muscleTags: Array.isArray(day.focus) ? day.focus : [],
          isCompleted: false,
          isUpcoming: collectedCount === 0, // Only the first one is "NEXT"
          dateStr,
          isLocked: collectedCount > 0, // All after the first are locked
        });
        collectedCount++;
      }
    }

    // Collect completed sessions (last 2 completed, in reverse order)
    const allCompleted = sortedDays
      .filter(d => completedSessionMap.has(d.id))
      .slice(-2)
      .reverse();
    
    for (const day of allCompleted) {
      completed.push({
        dayLabel: day.label,
        muscleTags: Array.isArray(day.focus) ? day.focus : [],
        isCompleted: true,
      });
    }

    return { upcoming, completed };
  }, [days, sessions, today]);

  if (isLoading) {
    return (
      <div className="space-y-2">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="skeleton-steal h-10 w-full" />
        ))}
      </div>
    );
  }

  if (!days || days.length === 0) {
    return (
      <p className="stamp text-[10px] text-[#525252]">{t("dashboard.NO_SCHEDULE_DATA")}</p>
    );
  }

  return (
    <div className="space-y-3">
      {/* Upcoming section */}
      <div>
        <div className="flex items-center gap-2 mb-2">
          <span className="stamp text-[10px] tracking-[0.18em] text-[#e53e00]">{t("dashboard.UPCOMING")}</span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>
        <div className="space-y-1.5">
          {sessionHistory.upcoming.length > 0 ? (
            sessionHistory.upcoming.map((item, i) => (
              <SessionHistoryItem key={i} {...item} t={t} />
            ))
          ) : (
            <p className="stamp text-[10px] text-ink-low py-2">{t("dashboard.ALL_SESSIONS_COMPLETED")}</p>
          )}
        </div>
      </div>

      {/* Completed section */}
      <div>
        <div className="flex items-center gap-2 mb-2">
          <span className="stamp text-[10px] tracking-[0.18em] text-[#10b981]">{t("dashboard.COMPLETED")}</span>
          <div className="h-px flex-1 bg-[#2a2a2a]" />
        </div>
        <div className="space-y-1.5">
          {sessionHistory.completed.length > 0 ? (
            sessionHistory.completed.map((item, i) => (
              <SessionHistoryItem key={i} {...item} t={t} />
            ))
          ) : (
            <p className="stamp text-[10px] text-ink-low py-2">{t("dashboard.NO_COMPLETED_SESSIONS_YET")}</p>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Recent activity feed ─────────────────────────────────────────────────────
function RecentFeed({ t }: { t: (path: string) => string }) {
  const { data: sessions, isLoading: sessionsLoading } = useSessions();
  const { data: allSets, isLoading: setsLoading } = useAllSets();

  const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];

  // Combine loading states
  const isLoading = sessionsLoading || setsLoading;

  // Get recent completed sessions sorted by completion date
  const recentSessions = useMemo(() => {
    if (!sessions || sessions.length === 0) return [];
    return [...sessions]
      .sort((a, b) => {
        const dateA = new Date(a.completedAt ?? a.startedAt ?? a.created).getTime();
        const dateB = new Date(b.completedAt ?? b.startedAt ?? b.created).getTime();
        return dateB - dateA;
      })
      .slice(0, 5);
  }, [sessions]);

  const sessionStats = useMemo(() => {
    const stats = new Map<string, { volume: number; setCount: number }>();

    for (const set of allSets ?? []) {
      const current = stats.get(set.session) ?? { volume: 0, setCount: 0 };
      current.volume += set.weight * set.reps;
      current.setCount += 1;
      stats.set(set.session, current);
    }

    return stats;
  }, [allSets]);

  function formatTacticalDate(dateStr: string) {
    const d = new Date(dateStr);
    const dd = String(d.getDate()).padStart(2, "0");
    const mon = months[d.getMonth()];
    const yy = String(d.getFullYear()).slice(2);
    const hh = String(d.getHours()).padStart(2, "0");
    const mm = String(d.getMinutes()).padStart(2, "0");
    return `${dd}${mon}${yy} ${hh}${mm}`;
  }

  function getSessionVolume(sessionId: string): string {
    const total = sessionStats.get(sessionId)?.volume ?? 0;
    if (total === 0) return "—";
    return (total / 1000).toFixed(1) + "T";
  }

  function getSessionSetCount(sessionId: string): number {
    return sessionStats.get(sessionId)?.setCount ?? 0;
  }

  function getPlanDayLabel(session: any): string {
    // Try to get the plan day label from session expand data
    if (session.expand?.planDay?.label) {
      return session.expand.planDay.label;
    }
    // Fallback to session notes or status
    if (session.sessionNotes) {
      return session.sessionNotes.toUpperCase().slice(0, 20);
    }
    return "WORKOUT";
  }

  if (isLoading) {
    return (
      <div className="space-y-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="skeleton-steal h-8 w-full" />
        ))}
      </div>
    );
  }

  if (!recentSessions.length) {
    return (
      <div className="border border-dashed border-[#2a2a2a] p-6 text-center">
        <span className="stamp text-[10px] text-ink-low">{t("dashboard.NO_SESSION_HISTORY")}</span>
      </div>
    );
  }

  return (
    <div className="space-y-0">
      {recentSessions.map((session, i) => {
        const sets = getSessionSetCount(session.id);
        const volume = getSessionVolume(session.id);
        const dateStr = formatTacticalDate(session.completedAt ?? session.startedAt ?? session.created);
        const planDayLabel = getPlanDayLabel(session);
        
        return (
          <div
            key={session.id}
            className={cn(
              "flex items-center gap-3 py-2.5 px-3 hover:bg-[#1a1a1a] transition-colors",
              i < recentSessions.length - 1 && "border-b border-[#1a1a1a]"
            )}
          >
            <span className="font-data text-[9px] sm:text-[10px] text-[#525252] tabular-nums shrink-0 w-20 sm:w-28">
              {dateStr}
            </span>
            <span className="text-[#2a2a2a] select-none">—</span>
            <span className="font-data text-[11px] text-[#a3a3a3] uppercase tracking-wide flex-1 truncate">
              {planDayLabel}
            </span>
            <span className="font-data text-[10px] text-[#71717A] shrink-0">
              {sets} {t("dashboard.SETS")}
            </span>
            <span className="font-data text-[10px] text-[#e53e00] shrink-0 w-12 text-right">
              {volume}
            </span>
          </div>
        );
      })}
    </div>
  );
}

// ─── Recent PRs strip ──────────────────────────────────────────────────────────
function RecentPRs({ t }: { t: (path: string) => string }) {
  const records = usePersonalRecords();

  const top3 = records.slice(0, 3);

  const months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
  function formatShortDate(dateStr: string) {
    const d = new Date(dateStr);
    return `${String(d.getDate()).padStart(2, "0")}${months[d.getMonth()]}${String(d.getFullYear()).slice(2)}`;
  }

  if (!top3.length) {
    return (
      <div className="border border-dashed border-[#2a2a2a] p-6 text-center">
        <span className="stamp text-[10px] text-ink-low">{t("dashboard.NO_PRS_YET")}</span>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {top3.map((pr, i) => (
        <div
          key={pr.exerciseId}
          className="flex items-center gap-3 py-1.5"
          style={{ borderBottom: "1px solid rgba(255,255,255,0.04)" }}
        >
          <span className="stamp text-[10px] text-ink-low w-5 shrink-0">
            {String(i + 1).padStart(2, "0")}
          </span>
          <div className="flex-1 min-w-0">
            <p className="font-data text-[10px] text-[#e5e5e5] uppercase tracking-wide truncate">
              {pr.exerciseName}
            </p>
            <p className="stamp text-[10px] text-ink-low mt-0.5">
              {formatShortDate(pr.date)}
            </p>
          </div>
          <span className="font-data text-xs font-bold text-[#e53e00] shrink-0">
            {pr.weight}kg×{pr.reps}
          </span>
        </div>
      ))}
    </div>
  );
}

// ─── Main page ────────────────────────────────────────────────────────────────
export default function DashboardPage() {
  const { user } = useAuth();
  const { data: activePlan, isLoading: planLoading } = useActivePlan();
  const streakData = useStreakData();
  const personalRecords = usePersonalRecords();
  const { data: allSets } = useAllSets();
  const { data: sessions } = useSessions();
  const { data: planDays } = usePlanDays(activePlan?.id);
  const { t } = useI18n();

  const firstName = (user?.name?.split(" ")[0] ?? "OPERATOR").toUpperCase();

  const totalVolumeTons = useMemo(() => {
    if (!allSets) return 0;
    const total = allSets.reduce((acc, s) => acc + (s.weight * s.reps), 0);
    return Math.round(total / 1000);
  }, [allSets]);

  const prsThisMonth = useMemo(() => {
    const monthStart = new Date();
    monthStart.setDate(1);
    monthStart.setHours(0, 0, 0, 0);
    return personalRecords.filter((pr) => new Date(pr.date) >= monthStart).length;
  }, [personalRecords]);

  // Derive displayed week from the first uncompleted session — never stale
  const displayWeek = useMemo(() => {
    if (!planDays || !activePlan) return activePlan?.currentWeek ?? 1;
    const completedIds = new Set(
      sessions
        ?.filter(s => s.plan === activePlan.id)
        .map(s => s.planDay)
        .filter((id): id is string => !!id) ?? []
    );
    const sorted = [...planDays].sort((a, b) =>
      a.week !== b.week ? a.week - b.week : a.dayOfWeek - b.dayOfWeek
    );
    const nextDay = sorted.find(d => !completedIds.has(d.id));
    return nextDay?.week ?? activePlan.currentWeek;
  }, [planDays, sessions, activePlan]);

  if (planLoading) {
    return <SkeletonGrid />;
  }

  return (
    <div className="relative space-y-[14px] py-4 scroll-forge">
      {/* ── Hero strip ─────────────────────────────────────────────────────── */}
      <div
        className="fade-up pb-3 flex items-end justify-between flex-wrap gap-3"
        style={{ borderBottom: "1px solid rgba(255,255,255,0.06)" }}
      >
        <div>
          <span className="font-data mb-1.5 block text-[10px] tracking-[0.24em] text-ink-low uppercase">
            {t("dashboard.STEEL_THERAPY")}
          </span>
          <h1
            className="font-heading uppercase leading-none text-[#f0f0f0]"
            style={{ fontSize: "clamp(22px, 6vw, 32px)", fontWeight: 700, letterSpacing: "-0.01em" }}
          >
            {t("dashboard.OPERATIONS_DASHBOARD")}
          </h1>
          <div
            className="mt-2"
            style={{
              height: 2,
              width: 32,
              background: "linear-gradient(90deg, #C2410C, transparent)",
              boxShadow: "0 0 8px #C2410C",
            }}
          />
        </div>
        <div className="text-right">
          <span className="font-data block text-[11px] text-ink-low">{t("dashboard.OPERATOR")}: {firstName}</span>
          <TacticalClock />
        </div>
      </div>

      {/* ── KPI row ────────────────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-1.5 sm:gap-2">
        <div className="glass kpi kpi-grn glass-hover fade-up fade-up-1">
          <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.CURRENT_STREAK")}</span>
          <div className="font-heading leading-none" style={{ fontSize: 26, fontWeight: 700, color: "#22c55e" }}>
            <CounterFX value={streakData.currentStreak} />
          </div>
          <span className="font-data mt-1 block text-[10px] text-ink-mid uppercase">{t("dashboard.DAYS")}</span>
        </div>
        <div className="glass kpi kpi-acc glass-hover fade-up fade-up-2">
          <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.THIS_WEEK")}</span>
          <div className="font-heading leading-none" style={{ fontSize: 26, fontWeight: 700, color: "#C2410C" }}>
            <CounterFX value={streakData.thisWeekSessions} />
          </div>
          <span className="font-data mt-1 block text-[10px] text-ink-mid uppercase">{t("dashboard.SESSIONS")}</span>
        </div>
        <div className="glass kpi kpi-acc glass-hover fade-up fade-up-3">
          <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.TOTAL_VOLUME")}</span>
          <div className="font-heading leading-none" style={{ fontSize: 26, fontWeight: 700, color: "#C2410C" }}>
            <CounterFX value={totalVolumeTons} />
          </div>
          <span className="font-data mt-1 block text-[10px] text-ink-mid uppercase">{t("dashboard.TONNES_LIFTED")}</span>
        </div>
        <div className="glass kpi kpi-blu glass-hover fade-up fade-up-4">
          <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.PRS_THIS_MONTH")}</span>
          <div className="font-heading leading-none" style={{ fontSize: 26, fontWeight: 700, color: "#3b82f6" }}>
            <CounterFX value={prsThisMonth} />
          </div>
          <span className="font-data mt-1 block text-[10px] text-ink-mid uppercase">{t("dashboard.RECORDS_SET")}</span>
        </div>
      </div>

      {/* ── Main 3-col grid ──────────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-2 lg:gap-[10px]">
        {/* Active Mission */}
        <div className="glass-acc forge-pulse fade-up fade-up-2 p-4 space-y-3 min-h-[240px] sm:min-h-[320px]">
          <div className="flex items-center gap-2 mb-1">
            <span className="font-data text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.MISSION_BRIEFING")}</span>
            <div className="h-px flex-1" style={{ background: "rgba(255,255,255,0.06)" }} />
            {activePlan && (
              <span className="font-data text-[10px] text-[#22c55e] tracking-widest">{t("dashboard.ACTIVE")}</span>
            )}
          </div>

          {activePlan ? (
            <>
              <div>
                <h2 className="font-heading text-2xl font-black uppercase text-[#f0f0f0] leading-tight">
                  {activePlan.title}
                </h2>
                <span className="mt-1 block font-data text-[10px] text-ink-low">
                  WK {displayWeek} / {activePlan.durationWeeks} · {activePlan.goalType?.replace(/_/g, " ")}
                </span>
              </div>
              <div style={{ height: 1, background: "rgba(255,255,255,0.06)" }} />
              <ActiveMissionPanel planId={activePlan.id} t={t} />
            </>
          ) : (
            <div className="flex flex-col gap-4 py-6">
              <span className="font-data text-[10px] text-[#525252]">{t("dashboard.NO_ACTIVE_MISSION_ASSIGNED")}</span>
              <h2 className="font-heading text-xl font-black uppercase text-[#e5e5e5]">{t("dashboard.NO_ACTIVE_PROGRAM")}</h2>
              <p className="text-sm text-[#71717A] max-w-sm">{t("dashboard.NO_PROGRAM_DESC")}</p>
              <div className="flex gap-3 flex-wrap">
                <Link
                  href="/programs"
                  className="btn-forge h-9 px-4 text-[11px] font-heading"
                >
                  <Dumbbell className="mr-2 h-3 w-3" />
                  {t("dashboard.FIND_A_PROGRAM").replace("[", "").replace("]", "")}
                </Link>
                <Link
                  href="/plans"
                  className="btn-ghost h-9 px-4 text-[11px] font-heading"
                >
                  {t("dashboard.BROWSE_TEMPLATES")}
                </Link>
              </div>
            </div>
          )}
        </div>

        {/* Week Schedule + Upcoming */}
        <div className="glass fade-up fade-up-3 p-4 min-h-[240px] sm:min-h-[320px]">
          <div className="flex items-center gap-2 mb-3">
            <span className="font-data text-[10px] tracking-[0.18em] text-ink-low uppercase">Week {displayWeek}</span>
            <div className="h-px flex-1" style={{ background: "rgba(255,255,255,0.06)" }} />
          </div>
          {activePlan ? (
            <SessionHistoryPanel planId={activePlan.id} t={t} />
          ) : (
            <span className="font-data text-[10px] text-[#525252]">{t("dashboard.NO_ACTIVE_PROGRAM")}</span>
          )}
        </div>

        {/* Activity Log + Recent PRs */}
        <div className="flex flex-col gap-[8px] min-h-[240px] sm:min-h-[320px]">
          <div className="glass fade-up fade-up-4 p-4 flex-1">
            <div className="flex items-center gap-2 mb-3">
              <span className="font-data text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.ACTIVITY_LOG")}</span>
              <div className="h-px flex-1" style={{ background: "rgba(255,255,255,0.06)" }} />
              <Link href="/progress" className="font-data text-[10px] text-ink-low hover:text-[#C2410C] transition-colors">
                {t("dashboard.VIEW_ALL")}
              </Link>
            </div>
            <RecentFeed t={t} />
          </div>
          <div className="glass fade-up fade-up-5 p-4">
            <div className="flex items-center gap-2 mb-3">
              <span className="font-data text-[10px] tracking-[0.18em] text-ink-low uppercase">{t("dashboard.RECENT_PRS")}</span>
              <div className="h-px flex-1" style={{ background: "rgba(255,255,255,0.06)" }} />
              <Trophy className="h-3 w-3 text-[#444]" />
            </div>
            <RecentPRs t={t} />
          </div>
        </div>
      </div>

      {/* ── HUD strip ──────────────────────────────────────────────────────── */}
      <div
        className="flex"
        style={{
          borderTop: "2px solid #C2410C",
          background: "rgba(0,0,0,0.6)",
          backdropFilter: "blur(20px)",
        }}
      >
        {[
          [t("dashboard.LAST_SYNC"), t("dashboard.LIVE")],
          [t("dashboard.DEVICE"), t("dashboard.WEB")],
          [t("dashboard.BUILD"), "STEEL v2"],
        ].map(([label, val], i) => (
          <div
            key={i}
            className="flex-1 px-2 py-1.5 text-center"
            style={{ borderRight: i < 2 ? "1px solid rgba(255,255,255,0.04)" : undefined }}
          >
            <span className="font-data block text-[10px] tracking-[0.12em] text-ink-low uppercase">{label}</span>
            <span className="font-data mt-0.5 block text-[11px] text-ink-mid uppercase">{val}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
