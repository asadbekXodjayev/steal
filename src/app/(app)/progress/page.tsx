"use client";

import { useMemo, useEffect, useState } from "react";
import dynamic from "next/dynamic";
import {
  useStreakData,
  usePersonalRecords,
  useSessions,
  useAllSets,
  useMuscleDistribution,
} from "@/hooks/useProgress";
import { useAchievements } from "@/hooks/useAchievements";
import { CalendarHeatmap } from "@/components/progress/CalendarHeatmap";
import { MuscleRadar } from "@/components/progress/MuscleRadar";
import { PRWall } from "@/components/progress/PRWall";
import { AchievementsBoard } from "@/components/progress/AchievementsBoard";
import { CounterFX } from "@/components/fx/ImpactFlash";
import { Skeleton } from "@/components/ui/skeleton";
import { calculateVolume, estimate1RM } from "@/lib/utils";
import { PRBoard } from "@/components/progress/PRBoard";
import { useI18n } from "@/components/providers/I18nProvider";

// Recharts-backed charts are heavy (~100KB). Lazy-load them so the chart
// library is split out of the initial progress-page bundle.
const chartFallback = () => <Skeleton className="h-[260px] w-full" />;
const EnhancedVolumeChart = dynamic(
  () => import("@/components/progress/EnhancedVolumeChart").then((m) => m.EnhancedVolumeChart),
  { ssr: false, loading: chartFallback },
);
const ProgressTrendChart = dynamic(
  () => import("@/components/progress/ProgressTrendChart").then((m) => m.ProgressTrendChart),
  { ssr: false, loading: chartFallback },
);
const RepsDistributionChart = dynamic(
  () => import("@/components/progress/RepsDistributionChart").then((m) => m.RepsDistributionChart),
  { ssr: false, loading: chartFallback },
);

// ============================================================================
// LiveClock — ticking monospace HH:MM:SS
// ============================================================================
function LiveClock() {
  const [time, setTime] = useState<string>(() =>
    new Date().toLocaleTimeString("en-GB", { hour12: false, hour: "2-digit", minute: "2-digit" })
  );
  useEffect(() => {
    const id = setInterval(() => {
      setTime(new Date().toLocaleTimeString("en-GB", { hour12: false, hour: "2-digit", minute: "2-digit" }));
    }, 60_000);
    return () => clearInterval(id);
  }, []);
  return (
    <span
      className="stamp"
      style={{
        fontVariantNumeric: "tabular-nums",
        fontSize: 12,
        letterSpacing: "0.15em",
        color: "var(--ink-mid)",
      }}
    >
      {time}
    </span>
  );
}

// ============================================================================
// PanelHeader — compact header for each panel
// ============================================================================
interface PanelHeaderProps {
  label: string;
  sub?: string;
  panelNum?: string;
}
function PanelHeader({ label, sub, panelNum }: PanelHeaderProps) {
  return (
    <div className="flex items-start justify-between mb-2">
      <div>
        <div
          className="stamp"
          style={{ 
            color: "#e5e5e5", 
            letterSpacing: "0.15em", 
            fontSize: 11,
            fontWeight: 700,
          }}
        >
          {label}
        </div>
        {sub && (
          <div
            className="stamp mt-0.5"
            style={{ 
              color: "var(--ink-low)", 
              fontSize: 10, 
              letterSpacing: "0.12em" 
            }}
          >
            {sub}
          </div>
        )}
      </div>
      {panelNum && (
        <span
          className="stamp"
          style={{ 
            color: "var(--ink-low)", 
            fontSize: 10, 
            letterSpacing: "0.08em" 
          }}
        >
          {panelNum}
        </span>
      )}
    </div>
  );
}

// ============================================================================
// KPI Panel — single stat with trend indicator
// ============================================================================
interface KPIPanelProps {
  label: string;
  value: number | string;
  subValue?: string;
  trend?: "up" | "down" | "neutral";
  panelNum: string;
  accent?: "orange" | "green" | "blue";
}
function KPIPanel({ label, value, subValue, trend, panelNum, accent = "orange" }: KPIPanelProps) {
  const accentColors = {
    orange: { border: "#e53e00", text: "#e53e00", dot: "#e53e00" },
    green: { border: "#10b981", text: "#10b981", dot: "#10b981" },
    blue: { border: "#3b82f6", text: "#3b82f6", dot: "#3b82f6" },
  };
  const colors = accentColors[accent];

  const kpiType = accent === "green" ? "kpi-grn" : accent === "blue" ? "kpi-blu" : "kpi-acc";
  return (
    <div className={`glass kpi ${kpiType} glass-hover fade-up`}>
      <span className="font-data mb-1.5 block text-[10px] tracking-[0.18em] text-ink-low uppercase">{label}</span>
      <div
        className="font-heading leading-none"
        style={{ fontSize: 26, fontWeight: 700, color: colors.text }}
      >
        <CounterFX value={typeof value === "number" ? value : parseInt(value.toString()) || 0} />
      </div>
      {subValue && (
        <span className="font-data mt-1 block text-[10px] text-ink-mid">{subValue}</span>
      )}
    </div>
  );
}

// ============================================================================
// SignalLost — error state panel
// ============================================================================
function SignalLost({ onRetry, t }: { onRetry?: () => void; t: (p: string) => string }) {
  return (
    <div
      className="border border-[#ef4444]/40 bg-[#0a0a0a] flex flex-col items-center justify-center py-16 gap-4"
      style={{ borderLeft: "3px solid #ef4444" }}
    >
      <div
        className="stamp"
        style={{ fontSize: 14, letterSpacing: "0.3em", color: "#ef4444" }}
      >
        {t("progress.SIGNAL_LOST")}
      </div>
      <div className="stamp" style={{ color: "#525252", fontSize: 10 }}>
        {t("progress.SIGNAL_LOST_DESC")}
      </div>
      {onRetry && (
        <button
          onClick={onRetry}
          className="stamp"
          style={{
            color: "#e5e5e5",
            border: "1px solid #ef4444",
            padding: "6px 16px",
            fontSize: 10,
            letterSpacing: "0.2em",
            background: "transparent",
            cursor: "pointer",
            marginTop: 4,
          }}
        >
          {t("progress.RETRY")}
        </button>
      )}
    </div>
  );
}

// ============================================================================
// SkeletonGrid — loading state
// ============================================================================
function SkeletonGrid() {
  return (
    <div className="space-y-3">
      {/* Hero */}
      <Skeleton className="skeleton-steal h-20 rounded-none" />
      {/* KPI row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[1, 2, 3, 4].map((i) => (
          <Skeleton key={i} className="skeleton-steal h-28 rounded-none" />
        ))}
      </div>
      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
        <Skeleton className="skeleton-steal h-64 rounded-none lg:col-span-2" />
        <Skeleton className="skeleton-steal h-64 rounded-none" />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
        <Skeleton className="skeleton-steal h-56 rounded-none" />
        <Skeleton className="skeleton-steal h-56 rounded-none" />
      </div>
      {/* PR Wall */}
      <Skeleton className="skeleton-steal h-48 rounded-none" />
      {/* Bottom strip */}
      <Skeleton className="skeleton-steal h-16 rounded-none" />
    </div>
  );
}

// ============================================================================
// EmptyState — when no data exists
// ============================================================================
function EmptyState({ t }: { t: (p: string) => string }) {
  return (
    <div className="glass flex flex-col items-center justify-center py-20 gap-6">
      <div className="stamp" style={{ fontSize: 14, letterSpacing: "0.3em", color: "#525252", textAlign: "center" }}>
        {t("progress.NO_DATA_ACQUIRED")}
      </div>
      <div className="stamp" style={{ fontSize: 10, letterSpacing: "0.2em", color: "#71717A", textAlign: "center" }}>
        {t("progress.NO_DATA_DESC")}
      </div>
    </div>
  );
}

// ============================================================================
// Main page
// ============================================================================
export default function ProgressPage() {
  const {
    data: sessions,
    isLoading: sessionsLoading,
    isError: sessionsError,
    refetch: refetchSessions,
  } = useSessions();
  const {
    data: allSets,
    isLoading: setsLoading,
    isError: setsError,
    refetch: refetchSets,
  } = useAllSets();
  const muscleData = useMuscleDistribution();
  const muscleLoading = false; // Computed data, no loading state
  const streakData = useStreakData();
  const personalRecords = usePersonalRecords();
  const achievements = useAchievements();
  const { t } = useI18n();

  const sessionMetrics = useMemo(() => {
    const metrics = new Map<
      string,
      { volume: number; rpeSum: number; rpeCount: number; totalSets: number; maxE1RM: number }
    >();

    for (const set of allSets ?? []) {
      const current = metrics.get(set.session) ?? {
        volume: 0,
        rpeSum: 0,
        rpeCount: 0,
        totalSets: 0,
        maxE1RM: 0,
      };
      const volume = calculateVolume(1, set.reps, set.weight);
      const e1rm = estimate1RM(set.weight, set.reps);

      current.volume += volume;
      current.totalSets += 1;
      if (set.rpe > 0) {
        current.rpeSum += set.rpe;
        current.rpeCount += 1;
      }
      if (e1rm > current.maxE1RM) {
        current.maxE1RM = e1rm;
      }

      metrics.set(set.session, current);
    }

    return metrics;
  }, [allSets]);

  // -- Volume data for enhanced chart --
  const enhancedVolumeData = useMemo(() => {
    if (!sessions || sessions.length === 0) return [];

    // Group by week
    const weekMap = new Map<string, { ts: number; volume: number; sessions: number; rpeSum: number; rpeCount: number }>();
    for (const session of sessions) {
      const metrics = sessionMetrics.get(session.id);
      const d = new Date(session.completedAt ?? session.startedAt);
      const weekStart = new Date(d);
      weekStart.setDate(d.getDate() - d.getDay());
      weekStart.setHours(0, 0, 0, 0);
      const key = weekStart.toISOString().slice(0, 10);

      const existing = weekMap.get(key);
      if (existing) {
        existing.volume += metrics?.volume ?? 0;
        existing.sessions += 1;
        existing.rpeSum += metrics?.rpeSum ?? 0;
        existing.rpeCount += metrics?.rpeCount ?? 0;
      } else {
        weekMap.set(key, {
          ts: weekStart.getTime(),
          volume: metrics?.volume ?? 0,
          sessions: 1,
          rpeSum: metrics?.rpeSum ?? 0,
          rpeCount: metrics?.rpeCount ?? 0,
        });
      }
    }

    return Array.from(weekMap.entries())
      .map(([week, data]) => ({
        week: new Date(week).toLocaleDateString("en-US", { month: "short", day: "numeric" }),
        volume: Math.round(data.volume),
        avgRpe: data.rpeCount > 0 ? data.rpeSum / data.rpeCount : 0,
        sessions: data.sessions,
        ts: data.ts,
      }))
      .sort((a, b) => a.ts - b.ts)
      .slice(-8);
  }, [sessionMetrics, sessions]);

  // -- Progress trend data --
  const progressTrendData = useMemo(() => {
    if (!sessions || sessions.length === 0) return [];

    const weekMap = new Map<string, { maxE1RM: number; rpeSum: number; rpeCount: number; totalSets: number }>();

    for (const session of sessions) {
      const metrics = sessionMetrics.get(session.id);
      if (!metrics) continue;

      const d = new Date(session.completedAt ?? session.startedAt);
      const weekStart = new Date(d);
      weekStart.setDate(d.getDate() - d.getDay());
      weekStart.setHours(0, 0, 0, 0);
      const weekKey = weekStart.toISOString().slice(0, 10);

      const entry = weekMap.get(weekKey) ?? { maxE1RM: 0, rpeSum: 0, rpeCount: 0, totalSets: 0 };
      if (metrics.maxE1RM > entry.maxE1RM) entry.maxE1RM = metrics.maxE1RM;
      entry.rpeSum += metrics.rpeSum;
      entry.rpeCount += metrics.rpeCount;
      entry.totalSets += metrics.totalSets;
      weekMap.set(weekKey, entry);
    }

    return Array.from(weekMap.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([weekKey, data]) => ({
        week: new Date(weekKey).toLocaleDateString("en-US", { month: "short", day: "numeric" }),
        maxE1RM: Math.round(data.maxE1RM * 10) / 10,
        avgRpe: data.rpeCount > 0 ? Math.round((data.rpeSum / data.rpeCount) * 10) / 10 : 0,
        totalSets: data.totalSets,
      }))
      .slice(-8);
  }, [sessionMetrics, sessions]);

  // -- Reps distribution data --
  const repsDistributionData = useMemo(() => {
    if (!allSets || allSets.length === 0) return [];

    const repRanges = [
      { label: "1-3", min: 1, max: 3 },
      { label: "4-5", min: 4, max: 5 },
      { label: "6-8", min: 6, max: 8 },
      { label: "9-10", min: 9, max: 10 },
      { label: "11-12", min: 11, max: 12 },
      { label: "13+", min: 13, max: 999 },
    ];

    return repRanges.map(range => ({
      reps: range.label,
      count: allSets.filter(s => s.reps >= range.min && s.reps <= range.max).length,
    })).filter(d => d.count > 0);
  }, [allSets]);

  // -- Heatmap sessions prop with volume --
  const heatmapSessions = useMemo(() => {
    if (!sessions) return [];
    return sessions.map((s) => {
      return {
        completedAt: s.completedAt ?? s.startedAt,
        startedAt: s.startedAt,
        volume: sessionMetrics.get(s.id)?.volume ?? 0,
      };
    });
  }, [sessionMetrics, sessions]);

  // -- Pentagon radar: 5-axis muscle groups --
  const muscleRadarData = useMemo(() => {
    if (!muscleData || muscleData.length === 0) return [];

    // Map individual muscle groups to the 5 radar categories
    const GROUP_MAP: Record<string, string> = {
      // BACK category
      'BACK': 'BACK',
      'TRAP': 'BACK',
      // CHEST category
      'CHEST': 'CHEST',
      // SHOULDERS category
      'SHOULDER': 'SHOULDERS',
      // ARMS category
      'BICEP': 'ARMS',
      'TRICEP': 'ARMS',
      // LEGS category
      'QUAD': 'LEGS',
      'HAMSTRING': 'LEGS',
      'GLUTE': 'LEGS',
      'CALF': 'LEGS',
    };

    const grouped: Record<string, number> = { BACK: 0, CHEST: 0, SHOULDERS: 0, ARMS: 0, LEGS: 0 };

    for (const d of muscleData) {
      const groupName = GROUP_MAP[d.name.toUpperCase()] || null;
      if (groupName) {
        grouped[groupName] += d.volume;
      }
    }

    const maxVol = Math.max(...Object.values(grouped));
    if (maxVol === 0) return [];

    return Object.entries(grouped).map(([label, vol]) => ({
      label,
      value: Math.round((vol / maxVol) * 100),
      volumeKg: Math.round(vol),
    }));
  }, [muscleData]);

  // -- Donut: push / pull / legs split --
  const splitCounts = useMemo(() => {
    if (!muscleData || muscleData.length === 0) return { push: 1, pull: 1, legs: 1 };

    const PUSH_MUSCLES = ["CHEST", "SHOULDER"];
    const PULL_MUSCLES = ["BACK", "BICEP", "TRAP"];
    const LEGS_MUSCLES = ["QUAD", "HAMSTRING", "GLUTE", "CALF"];

    let push = 0;
    let pull = 0;
    let legs = 0;

    for (const d of muscleData) {
      const name = d.name.toUpperCase();
      if (PUSH_MUSCLES.includes(name)) push += d.volume;
      else if (PULL_MUSCLES.includes(name)) pull += d.volume;
      else if (LEGS_MUSCLES.includes(name)) legs += d.volume;
      else push += d.volume; // default to push for unmatched
    }

    return { push: push || 1, pull: pull || 1, legs: legs || 1 };
  }, [muscleData]);

  // -- Top exercises for LiftProgressionChart --
  const topExerciseIds = useMemo(
    () => personalRecords.slice(0, 3).map((pr) => pr.exerciseId),
    [personalRecords]
  );
  const exerciseNames = useMemo(() => {
    const map: Record<string, string> = {};
    for (const pr of personalRecords) {
      map[pr.exerciseId] = pr.exerciseName;
    }
    return map;
  }, [personalRecords]);

  // -- PR Wall data --
  const prWallData = useMemo(() => {
    return personalRecords.slice(0, 5).map((pr) => ({
      exerciseName: pr.exerciseName,
      weight: pr.weight,
      reps: pr.reps,
      date: pr.date,
      estimated1RM: pr.estimated1RM
    }));
  }, [personalRecords]);

  // -- HUD bottom strip derivations --
  const hudStats = useMemo(() => {
    if (!allSets || allSets.length === 0)
      return { totalReps: 0, avgRpe: 0, heaviestWeight: 0, heaviestReps: 0, heaviestRpe: 0, totalVolume: 0 };

    let totalReps = 0;
    let rpeSum = 0;
    let rpeCount = 0;
    let heaviestWeight = 0;
    let heaviestReps = 0;
    let heaviestRpe = 0;
    let totalVolume = 0;

    for (const set of allSets) {
      totalReps += set.reps;
      totalVolume += calculateVolume(1, set.reps, set.weight);
      if (set.rpe > 0) {
        rpeSum += set.rpe;
        rpeCount++;
      }
      if (set.weight > heaviestWeight) {
        heaviestWeight = set.weight;
        heaviestReps = set.reps;
        heaviestRpe = set.rpe;
      }
    }

    return {
      totalReps,
      avgRpe: rpeCount > 0 ? Math.round((rpeSum / rpeCount) * 10) / 10 : 0,
      heaviestWeight,
      heaviestReps,
      heaviestRpe,
      totalVolume,
    };
  }, [allSets]);

  // -- Total volume for gauge --
  const totalVolume = useMemo(() => {
    if (!allSets || allSets.length === 0) return 0;
    return Math.round(allSets.reduce((acc, s) => acc + calculateVolume(1, s.reps, s.weight), 0));
  }, [allSets]);

  // -- Calculate trends --
  const calculateTrend = (current: number, previous: number): "up" | "down" | "neutral" => {
    if (previous === 0) return current > 0 ? "up" : "neutral";
    const change = ((current - previous) / previous) * 100;
    if (change > 5) return "up";
    if (change < -5) return "down";
    return "neutral";
  };

  const isLoading = sessionsLoading || setsLoading;
  const isError = sessionsError || setsError;

  const handleRetry = () => {
    void refetchSessions();
    void refetchSets();
  };

  // -- Error state --
  if (isError) {
    return (
      <div className="space-y-6 py-6">
        <div>
          <h1 className="text-3xl font-extrabold uppercase tracking-tight text-[#e5e5e5]" style={{ fontFamily: "var(--font-heading, system-ui)" }}>
            {t("progress.STATS")}
          </h1>
          <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
        </div>
        <SignalLost onRetry={handleRetry} t={t} />
      </div>
    );
  }

  // -- Loading state --
  if (isLoading) {
    return (
      <div className="space-y-6 py-6">
        <div>
          <h1 className="text-3xl font-extrabold uppercase tracking-tight text-[#e5e5e5]" style={{ fontFamily: "var(--font-heading, system-ui)" }}>
            {t("progress.STATS")}
          </h1>
          <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
        </div>
        <SkeletonGrid />
      </div>
    );
  }

  // -- Empty state --
  if (!sessions || sessions.length === 0) {
    return (
      <div className="space-y-6 py-6">
        <div>
          <h1 className="text-3xl font-extrabold uppercase tracking-tight text-[#e5e5e5]" style={{ fontFamily: "var(--font-heading, system-ui)" }}>
            {t("progress.STATS")}
          </h1>
          <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
        </div>
        <EmptyState t={t} />
      </div>
    );
  }

  // ============================================================================
  // Full tactical readout render
  // ============================================================================
  return (
    <div className="space-y-6 py-6">
      {/* ── HERO HEADER ────────────────────────────────────────────── */}
      <div className="border-b border-[#2a2a2a] pb-4">
        <div className="flex items-center justify-between">
          <div>
            <h1
              className="text-3xl font-extrabold uppercase tracking-tight text-[#e5e5e5]"
              style={{ fontFamily: "var(--font-heading, system-ui)" }}
            >
              {t("progress.STATS")}
            </h1>
            <div className="mt-2" style={{ height: 2, width: 32, background: "linear-gradient(90deg,#C2410C,transparent)", boxShadow: "0 0 8px #C2410C" }} />
          </div>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <span className="stamp" style={{ color: "var(--ink-low)", fontSize: 11, letterSpacing: "0.15em" }}>
                {t("progress.LAST_SYNC")}
              </span>
              <LiveClock />
            </div>
          </div>
        </div>
      </div>

      {/* ── KPI ROW ────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <KPIPanel
          label={t("progress.TOTAL_SESSIONS")}
          value={streakData.totalSessions}
          subValue={t("progress.LIFETIME")}
          trend="up"
          panelNum="01"
          accent="orange"
        />
        <KPIPanel
          label={t("progress.CURRENT_STREAK")}
          value={streakData.currentStreak}
          subValue={`${t("progress.BEST")}: ${streakData.longestStreak}D`}
          trend={streakData.currentStreak > 0 ? "up" : "neutral"}
          panelNum="02"
          accent="green"
        />
        <KPIPanel
          label={t("progress.TOTAL_VOLUME")}
          value={Math.round(totalVolume / 1000)}
          subValue={`${Math.round(totalVolume).toLocaleString()} KG`}
          trend="up"
          panelNum="03"
          accent="orange"
        />
        <KPIPanel
          label={t("progress.THIS_MONTH")}
          value={streakData.thisMonthSessions}
          subValue={`${streakData.thisWeekSessions} ${t("progress.THIS_WK")}`}
          trend="up"
          panelNum="04"
          accent="blue"
        />
      </div>

      {/* ── MAIN CHARTS ROW ────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
        {/* Enhanced Volume Chart — spans 2 columns on large screens */}
        <div className="lg:col-span-2">
          <div className="glass p-3">
            <div>
              <PanelHeader 
                label={t("progress.WEEKLY_VOLUME")}
                sub={t("progress.LAST_8_WEEKS")} 
                panelNum="05"
              />
              <EnhancedVolumeChart data={enhancedVolumeData} />
            </div>
          </div>
        </div>

        {/* Progress Trend Chart */}
        <div>
          <div className="glass p-3">
            <div>
              <PanelHeader
                label={t("progress.PROGRESS_TREND")}
                sub="e1RM vs RPE"
                panelNum="06"
              />
              <ProgressTrendChart data={progressTrendData} />
            </div>
          </div>
        </div>
      </div>

      {/* ── SECONDARY CHARTS ROW ────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-3">
        {/* Calendar Heatmap */}
        <div className="glass p-3">
          <div>
            <PanelHeader
              label={t("progress.CONTACT_MATRIX")}
              sub={`YEAR ${new Date().getFullYear()}`}
              panelNum="07"
            />
            <div className="overflow-x-auto">
              <CalendarHeatmap sessions={heatmapSessions} />
            </div>
          </div>
        </div>

        {/* Reps Distribution */}
        <div className="glass p-3">
          <div>
            <PanelHeader 
              label={t("progress.REP_DISTRIBUTION")}
              sub={t("progress.INTENSITY_PROFILE")} 
              panelNum="08"
            />
            <RepsDistributionChart data={repsDistributionData} />
          </div>
        </div>
      </div>

      {/* ── MUSCLE BALANCE ────────────────────────────────────────────── */}
      <div className="glass p-3">
        <PanelHeader
          label={t("progress.MUSCLE_BALANCE")}
          sub={t("progress.TRAINING_DISTRIBUTION")}
          panelNum="09"
        />
        {muscleLoading ? (
          <Skeleton className="skeleton-steal h-48 rounded-none" />
        ) : muscleRadarData.length === 0 ? (
          <div className="flex items-center justify-center py-16">
            <span className="stamp" style={{ color: "#525252", letterSpacing: "0.2em" }}>
              {t("progress.NO_MUSCLE_DATA")}
            </span>
          </div>
        ) : (
          <MuscleRadar data={muscleRadarData} />
        )}
      </div>

      {/* ── PR BOARD TABLE ────────────────────────────────────────────── */}
      <div className="glass p-3 fade-up fade-up-4">
        <PanelHeader
          label={t("progress.PR_WALL")}
          sub="ALL-TIME BESTS"
          panelNum="10"
        />
        <PRBoard records={personalRecords.slice(0, 8)} />
      </div>

      {/* ── PR WALL CARDS ────────────────────────────────────────────── */}
      <div className="fade-up fade-up-5">
        <div className="flex items-center gap-2 mb-3">
          <span className="font-data text-[10px] text-ink-low tracking-[0.18em] uppercase">Recent Records</span>
          <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.06)" }} />
        </div>
        <PRWall prs={prWallData} />
      </div>

        {/* ── ACHIEVEMENTS ────────────────────────────────────────────── */}
      <div className="glass p-3">
        <div>
          <PanelHeader 
            label={t("progress.MERIT_BOARD")}
            sub={t("progress.ACHIEVEMENTS_UNLOCKED")}
            panelNum="11"
          />
          <AchievementsBoard unlocked={achievements} />
        </div>
      </div>

      {/* ── BOTTOM HUD STRIP ────────────────────────────────────────────── */}
      <div className="pt-4" style={{ borderTop: "2px solid #C2410C" }}>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="flex flex-col gap-1">
            <span className="stamp" style={{ color: "#71717A", fontSize: 9, letterSpacing: "0.1em" }}>
              {t("progress.TOTAL_REPS")}
            </span>
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: "clamp(1.2rem, 2.5vw, 1.6rem)",
                fontWeight: 800,
                fontVariantNumeric: "tabular-nums",
                color: "#e5e5e5",
                lineHeight: 1,
              }}
            >
              <CounterFX value={hudStats.totalReps} />
            </span>
            <span className="stamp" style={{ color: "#e53e00", fontSize: 9 }}>
              {t("progress.REPS_LOGGED")}
            </span>
          </div>

          <div className="flex flex-col gap-1 md:border-l md:border-[#2a2a2a] md:pl-4">
            <span className="stamp" style={{ color: "#71717A", fontSize: 9, letterSpacing: "0.1em" }}>
              {t("progress.AVG_RPE")}
            </span>
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: "clamp(1.2rem, 2.5vw, 1.6rem)",
                fontWeight: 800,
                fontVariantNumeric: "tabular-nums",
                color: hudStats.avgRpe >= 8 ? "#e53e00" : "#e5e5e5",
                lineHeight: 1,
              }}
            >
              {hudStats.avgRpe > 0 ? hudStats.avgRpe.toFixed(1) : "—"}
            </span>
            <span className="stamp" style={{ color: "#71717A", fontSize: 9 }}>
              {t("progress.INTENSITY_10")}
            </span>
          </div>

          <div className="flex flex-col gap-1 md:border-l md:border-[#2a2a2a] md:pl-4">
            <span className="stamp" style={{ color: "#71717A", fontSize: 9, letterSpacing: "0.1em" }}>
              {t("progress.HEAVIEST_SET")}
            </span>
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: "clamp(1.2rem, 2.5vw, 1.6rem)",
                fontWeight: 800,
                fontVariantNumeric: "tabular-nums",
                color: "#10b981",
                lineHeight: 1,
              }}
            >
              {hudStats.heaviestWeight > 0 ? hudStats.heaviestWeight : "—"}
            </span>
            <span className="stamp" style={{ color: "#71717A", fontSize: 9 }}>
              {hudStats.heaviestWeight > 0
                ? `KG × ${hudStats.heaviestReps} @ RPE ${hudStats.heaviestRpe}`
                : t("progress.NO_DATA")}
            </span>
          </div>

          <div className="flex flex-col gap-1 md:border-l md:border-[#2a2a2a] md:pl-4">
            <span className="stamp" style={{ color: "#71717A", fontSize: 9, letterSpacing: "0.1em" }}>
              {t("progress.TOTAL_VOLUME")}
            </span>
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: "clamp(1.2rem, 2.5vw, 1.6rem)",
                fontWeight: 800,
                fontVariantNumeric: "tabular-nums",
                color: "#e53e00",
                lineHeight: 1,
              }}
            >
              {Math.round(hudStats.totalVolume / 1000)}
            </span>
            <span className="stamp" style={{ color: "#e53e00", fontSize: 9 }}>
              {t("progress.TONNE")}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
