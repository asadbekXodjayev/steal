"use client";

import Link from "next/link";
import { useActivePlan } from "@/hooks/usePlans";
import { usePlanDays } from "@/hooks/usePlans";
import { usePlanDaySession } from "@/hooks/usePlans";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { Dumbbell, Calendar, ArrowRight, CheckCircle2 } from "lucide-react";
import { DAYS_OF_WEEK } from "@/lib/constants";
import { useI18n } from "@/components/providers/I18nProvider";
import { useGuestActivePlan } from "@/hooks/useGuestWorkouts";
import { useGuestPlanDays } from "@/hooks/useGuestWorkouts";
import { useGuestWorkoutSessions } from "@/hooks/useGuestWorkouts";
import { useIsGuestUser } from "@/hooks/useGuestWorkouts";

function PlanDayAction({ dayId, dayLabel, isGuest, t }: { dayId: string; dayLabel: string; isGuest: boolean; t: (p: string) => string }) {
  const { data: session, isLoading } = usePlanDaySession(dayId);
  const { getCompletedSessionForPlanDay } = useGuestWorkoutSessions();
  const guestSession = isGuest ? getCompletedSessionForPlanDay(dayId) : null;

  if (isLoading) {
    return <Skeleton className="h-10 w-full" />;
  }

  if (session || guestSession) {
    return (
      <div className="flex items-center justify-between">
        <span className="font-data text-xs font-semibold uppercase tracking-widest text-[#10B981]">
          {t("workout.COMPLETED")}
        </span>
        <CheckCircle2 className="h-4 w-4 text-[#10B981]" />
      </div>
    );
  }

  return (
    <Button
      asChild
      className="w-full rounded-none bg-[#e53e00] font-data text-xs font-bold uppercase tracking-widest text-white hover:bg-[#ff4500]"
    >
      <Link href={`/workout/${dayId}`}>
        <Dumbbell className="mr-2 h-4 w-4" />
        {t("workout.START_WORKOUT")}
        <ArrowRight className="ml-2 h-4 w-4" />
      </Link>
    </Button>
  );
}

export default function WorkoutIndexPage() {
  const { t } = useI18n();
  const isGuest = useIsGuestUser();
  const { data: plan, isLoading: planLoading } = useActivePlan();
  const { data: days, isLoading: daysLoading } = usePlanDays(plan?.id);
  
  // Guest mode hooks
  const { activePlan: guestActivePlan, isLoading: guestPlanLoading } = useGuestActivePlan();
  const { planDays: guestDays, isLoading: guestDaysLoading } = useGuestPlanDays(guestActivePlan?.id);

  // Use guest data if guest, otherwise use authenticated data
  const currentPlan = isGuest ? guestActivePlan : plan;
  const currentDays = isGuest ? guestDays : days;
  const isLoading = isGuest ? (guestPlanLoading || guestDaysLoading) : (planLoading || daysLoading);

  const today = new Date().getDay() || 7; // 1=Mon, 7=Sun
  const todayDays = currentDays?.filter(
    (d) => d.week === currentPlan?.currentWeek && d.dayOfWeek === today,
  );

  return (
    <div className="space-y-6 py-4 pb-24">
      <div>
        <h1
          className="text-2xl sm:text-3xl font-extrabold uppercase tracking-tight"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("workout.TRAIN")}
        </h1>
        <div className="mt-1 h-0.5 w-12 bg-[#e53e00]" />
        {isGuest && currentPlan && (
          <p className="mt-2 text-xs text-[#71717A] font-data uppercase tracking-widest">
            {t("workout.GUEST_MODE")}
          </p>
        )}
      </div>

      {isLoading ? (
        <Skeleton className="h-48 w-full" />
      ) : !currentPlan ? (
        <div className="border border-dashed border-border p-8 text-center">
          <Dumbbell className="mx-auto h-8 w-8 text-muted-foreground" />
          <p className="mt-2 text-sm text-muted-foreground">{t("workout.NO_ACTIVE_PROGRAM")}</p>
          <Button
            asChild
            className="mt-4 rounded-none bg-[#e53e00] font-data text-xs font-bold uppercase tracking-widest text-white hover:bg-[#ff4500]"
          >
            <Link href="/programs">{t("workout.FIND_A_PROGRAM")}</Link>
          </Button>
        </div>
      ) : (
        <>
          {/* Today's workout */}
          <div className="space-y-3">
            <h2 className="label-section">{t("workout.TODAY")}</h2>
            {todayDays && todayDays.length > 0 ? (
              todayDays.map((day) => (
                <Card key={day.id} className="rounded-none border-border bg-card">
                  <CardHeader className="pb-2">
                    <CardTitle className="flex items-center justify-between text-base">
                      <span
                        className="font-bold uppercase tracking-wide"
                        style={{ fontFamily: "var(--font-heading, system-ui)" }}
                      >
                        {day.label}
                      </span>
                      <div className="flex gap-1">
                        {day.focus.slice(0, 3).map((m) => (
                          <Badge
                            key={m}
                            variant="outline"
                            className="rounded-none border-border font-data text-[10px] uppercase tracking-widest"
                          >
                            {m}
                          </Badge>
                        ))}
                      </div>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <PlanDayAction dayId={day.id} dayLabel={day.label} isGuest={isGuest} t={t} />
                  </CardContent>
                </Card>
              ))
            ) : (
              <div className="border border-border bg-card p-4">
                <p className="font-data text-sm text-muted-foreground uppercase tracking-wide">
                  {t("workout.REST_DAY")}
                </p>
              </div>
            )}
          </div>

          {/* This week's schedule */}
          <div className="space-y-3">
            <h2 className="label-section">{t("workout.WEEK_SCHEDULE").replace("{week}", String(currentPlan.currentWeek))}</h2>
            <div className="space-y-1">
              {currentDays
                ?.filter((d) => d.week === currentPlan.currentWeek)
                .sort((a, b) => a.dayOfWeek - b.dayOfWeek)
                .map((day) => (
                  <Link key={day.id} href={`/workout/${day.id}`}>
                    <div className="flex items-center justify-between border border-border bg-card px-4 py-3 transition-colors hover:border-[#e53e00]/40 hover:bg-[#e53e00]/5">
                      <div className="flex items-center gap-3">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                        <div>
                          <span className="font-data text-xs font-semibold uppercase tracking-widest">
                            {DAYS_OF_WEEK[day.dayOfWeek - 1]}
                          </span>
                          <span className="ml-2 text-sm text-muted-foreground">
                            {day.label}
                          </span>
                        </div>
                      </div>
                      <ArrowRight className="h-4 w-4 text-muted-foreground" />
                    </div>
                  </Link>
                ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}