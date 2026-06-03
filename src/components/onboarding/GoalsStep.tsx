"use client";

import {
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Slider } from "@/components/ui/slider";
import { GOAL_OPTIONS } from "@/lib/constants";
import { Target, Flame, Zap, Heart, Activity } from "lucide-react";
import type { UseFormReturn } from "react-hook-form";
import type { OnboardingFormData } from "./types";
import { useI18n } from "@/components/providers/I18nProvider";

const GOAL_KEY_MAP: Record<string, { label: string; desc: string }> = {
  muscle_building: { label: "onboarding.GOAL_MUSCLE_BUILDING", desc: "onboarding.GOAL_MUSCLE_BUILDING_DESC" },
  strength: { label: "onboarding.GOAL_STRENGTH", desc: "onboarding.GOAL_STRENGTH_DESC" },
  fat_loss: { label: "onboarding.GOAL_FAT_LOSS", desc: "onboarding.GOAL_FAT_LOSS_DESC" },
  endurance: { label: "onboarding.GOAL_ENDURANCE", desc: "onboarding.GOAL_ENDURANCE_DESC" },
  rehabilitation: { label: "onboarding.GOAL_REHABILITATION", desc: "onboarding.GOAL_REHABILITATION_DESC" },
};

const goalIcons = {
  muscle_building: Zap,
  strength: Activity,
  fat_loss: Flame,
  endurance: Heart,
  rehabilitation: Target,
} as const;

interface GoalsStepProps {
  form: UseFormReturn<OnboardingFormData>;
}

export function GoalsStep({ form }: GoalsStepProps) {
  const { t } = useI18n();
  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h2
          className="text-xl font-extrabold uppercase tracking-tight sm:text-2xl"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("onboarding.YOUR_MISSION")}
        </h2>
        <p className="font-data text-xs text-muted-foreground">
          {t("onboarding.MISSION_DESC")}
        </p>
      </div>

      <FormField
        control={form.control}
        name="goalType"
        render={({ field }) => (
          <FormItem>
            <div className="grid gap-2 sm:grid-cols-2">
              {GOAL_OPTIONS.map((goal) => {
                const Icon = goalIcons[goal.value];
                const active = field.value === goal.value;
                const keys = GOAL_KEY_MAP[goal.value];
                return (
                  <button
                    key={goal.value}
                    type="button"
                    onClick={() => field.onChange(goal.value)}
                    className={`flex items-start gap-3 border p-4 text-left transition-colors ${
                      active
                        ? "border-[#e53e00] bg-[#e53e00]/10"
                        : "border-border hover:border-[#e53e00]/40"
                    }`}
                  >
                    <Icon
                      className={`mt-0.5 h-5 w-5 shrink-0 ${active ? "text-[#e53e00]" : "text-muted-foreground"}`}
                    />
                    <div>
                      <div className="font-data text-xs font-bold uppercase tracking-widest">
                        {keys ? t(keys.label) : goal.label}
                      </div>
                      <div className="mt-0.5 font-data text-[10px] text-muted-foreground">
                        {keys ? t(keys.desc) : goal.description}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
            <FormMessage />
          </FormItem>
        )}
      />

      <div className="grid gap-6 sm:grid-cols-2">
        <FormField
          control={form.control}
          name="daysPerWeek"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.DAYS_WEEK")}{" "}
                <span className="font-bold text-foreground">{field.value}</span>
              </FormLabel>
              <Slider
                min={2}
                max={6}
                step={1}
                value={[field.value]}
                onValueChange={([v]) => field.onChange(v)}
              />
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="sessionMinutes"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.SESSION_LENGTH")}{" "}
                <span className="font-bold text-foreground">{field.value} {t("onboarding.MIN")}</span>
              </FormLabel>
              <Slider
                min={20}
                max={90}
                step={5}
                value={[field.value]}
                onValueChange={([v]) => field.onChange(v)}
              />
              <FormMessage />
            </FormItem>
          )}
        />
      </div>
    </div>
  );
}
