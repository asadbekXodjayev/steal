"use client";

import { Flame, Calendar, Trophy, TrendingUp } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { StreakData } from "@/types/progress";
import { useI18n } from "@/components/providers/I18nProvider";

interface StreakTrackerProps {
  data: StreakData;
}

interface StatBoxProps {
  icon: LucideIcon;
  value: number;
  label: string;
}

function StatBox({ icon: Icon, value, label }: StatBoxProps) {
  return (
    <div className="border border-border bg-card p-4">
      <Icon className="mb-2 h-5 w-5 text-[#e53e00]" aria-hidden="true" />
      <div className="font-data text-3xl font-bold tabular-nums text-foreground">
        {value}
      </div>
      <div className="mt-1 h-0.5 w-8 bg-[#e53e00]" aria-hidden="true" />
      <div className="label-section mt-2">{label}</div>
    </div>
  );
}

export function StreakTracker({ data }: StreakTrackerProps) {
  const { t } = useI18n();

  const stats: StatBoxProps[] = [
    { icon: Flame, value: data.currentStreak, label: t("progress.STREAK_DAY_STREAK") },
    { icon: Trophy, value: data.longestStreak, label: t("progress.STREAK_BEST_STREAK") },
    { icon: Calendar, value: data.thisWeekSessions, label: t("progress.STREAK_THIS_WEEK") },
    { icon: TrendingUp, value: data.totalSessions, label: t("progress.STREAK_TOTAL_SESSIONS") },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {stats.map((stat) => (
        <StatBox key={stat.label} {...stat} />
      ))}
    </div>
  );
}
