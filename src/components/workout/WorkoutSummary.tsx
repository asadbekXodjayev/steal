"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Trophy, Clock, Dumbbell, TrendingUp } from "lucide-react";
import { formatDuration, formatWeight } from "@/lib/utils";
import type { ActiveSetInput } from "@/types/session";
import Link from "next/link";
import { useI18n } from "@/components/providers/I18nProvider";

interface WorkoutSummaryProps {
  duration: number; // seconds
  exercises: Array<{
    name: string;
    completedSets: ActiveSetInput[];
  }>;
}

export function WorkoutSummary({ duration, exercises }: WorkoutSummaryProps) {
  const { t } = useI18n();
  const totalSets = exercises.reduce(
    (sum, ex) => sum + ex.completedSets.length,
    0,
  );
  const totalVolume = exercises.reduce(
    (sum, ex) =>
      sum +
      ex.completedSets.reduce((s, set) => s + set.weight * set.reps, 0),
    0,
  );
  const totalReps = exercises.reduce(
    (sum, ex) =>
      sum + ex.completedSets.reduce((s, set) => s + set.reps, 0),
    0,
  );

  return (
    // pb-28 ensures content clears the BottomNav (h-16) on mobile with safe margin
    <div className="mx-auto max-w-md space-y-6 py-8 pb-28 text-center">
      <div className="space-y-2">
        <Trophy className="mx-auto h-12 w-12 text-warning" />
        {/* text-xl on mobile → text-2xl at sm+ to avoid oversized heading on small screens */}
        <h2 className="text-xl sm:text-2xl font-bold">{t("summary.TITLE")}</h2>
        <p className="text-sm text-muted-foreground">
          {t("summary.DESC")}
        </p>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Card className="rounded-none">
          <CardContent className="flex flex-col items-center py-4">
            <Clock className="mb-1 h-5 w-5 text-muted-foreground" />
            <span className="text-lg font-bold">{formatDuration(duration)}</span>
            <span className="text-xs text-muted-foreground">{t("summary.DURATION")}</span>
          </CardContent>
        </Card>
        <Card className="rounded-none">
          <CardContent className="flex flex-col items-center py-4">
            <Dumbbell className="mb-1 h-5 w-5 text-muted-foreground" />
            <span className="text-lg font-bold">{totalSets}</span>
            <span className="text-xs text-muted-foreground">{t("summary.SETS")}</span>
          </CardContent>
        </Card>
        <Card className="rounded-none">
          <CardContent className="flex flex-col items-center py-4">
            <TrendingUp className="mb-1 h-5 w-5 text-muted-foreground" />
            <span className="text-lg font-bold">{formatWeight(totalVolume)}</span>
            <span className="text-xs text-muted-foreground">{t("summary.TOTAL_VOLUME")}</span>
          </CardContent>
        </Card>
        <Card className="rounded-none">
          <CardContent className="flex flex-col items-center py-4">
            <span className="mb-1 text-lg">💪</span>
            <span className="text-lg font-bold">{totalReps}</span>
            <span className="text-xs text-muted-foreground">{t("summary.TOTAL_REPS")}</span>
          </CardContent>
        </Card>
      </div>

      {/* Exercise breakdown */}
      <Card className="rounded-none">
        <CardHeader className="pb-2">
          <CardTitle className="text-sm">{t("summary.EXERCISE_BREAKDOWN")}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {exercises.map((ex, i) => (
            <div
              key={i}
              className="flex items-center justify-between text-sm"
            >
              <span className="text-muted-foreground">{ex.name}</span>
              <Badge variant="secondary" className="rounded-none">
                {ex.completedSets.length} {t("summary.SETS_COUNT")}
              </Badge>
            </div>
          ))}
        </CardContent>
      </Card>

      <div className="flex gap-3">
        <Button asChild className="flex-1 rounded-none">
          <Link href="/dashboard">{t("summary.BACK_TO_DASHBOARD")}</Link>
        </Button>
        <Button asChild variant="outline" className="flex-1 rounded-none">
          <Link href="/profile">{t("summary.VIEW_PROGRESS")}</Link>
        </Button>
      </div>
    </div>
  );
}
