"use client";

import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { FITNESS_LEVELS } from "@/lib/constants";
import type { UseFormReturn } from "react-hook-form";
import type { OnboardingFormData } from "./types";
import { useI18n } from "@/components/providers/I18nProvider";

const FITNESS_LEVEL_KEY_MAP: Record<string, { label: string; desc: string }> = {
  beginner: { label: "onboarding.FITNESS_BEGINNER", desc: "onboarding.FITNESS_BEGINNER_DESC" },
  intermediate: { label: "onboarding.FITNESS_INTERMEDIATE", desc: "onboarding.FITNESS_INTERMEDIATE_DESC" },
  advanced: { label: "onboarding.FITNESS_ADVANCED", desc: "onboarding.FITNESS_ADVANCED_DESC" },
};

interface ProfileStepProps {
  form: UseFormReturn<OnboardingFormData>;
}

export function ProfileStep({ form }: ProfileStepProps) {
  const { t } = useI18n();
  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h2
          className="text-xl font-extrabold uppercase tracking-tight sm:text-2xl"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("onboarding.YOUR_STATS")}
        </h2>
        <p className="font-data text-xs text-muted-foreground">
          {t("onboarding.STATS_DESC")}
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <FormField
          control={form.control}
          name="age"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.AGE")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={13}
                  max={100}
                  placeholder="25"
                  className="rounded-none border-border bg-input font-data text-sm"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="gender"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.GENDER")}
              </FormLabel>
              <Select onValueChange={field.onChange} value={field.value}>
                <FormControl>
                  <SelectTrigger className="rounded-none border-border bg-input font-data text-sm">
                    <SelectValue placeholder={t("onboarding.GENDER_SELECT")} />
                  </SelectTrigger>
                </FormControl>
                <SelectContent className="rounded-none border-border bg-card">
                  <SelectItem value="male" className="font-data text-sm">{t("onboarding.MALE")}</SelectItem>
                  <SelectItem value="female" className="font-data text-sm">{t("onboarding.FEMALE")}</SelectItem>
                  <SelectItem value="other" className="font-data text-sm">{t("onboarding.OTHER")}</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="height"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.HEIGHT_CM")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={100}
                  max={250}
                  placeholder="175"
                  className="rounded-none border-border bg-input font-data text-sm"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="weight"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.WEIGHT_KG")}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  min={30}
                  max={300}
                  placeholder="75"
                  className="rounded-none border-border bg-input font-data text-sm"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </div>

      <FormField
        control={form.control}
        name="fitnessLevel"
        render={({ field }) => (
          <FormItem>
            <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
              {t("onboarding.EXPERIENCE")}
            </FormLabel>
            <p className="font-data text-[10px] text-muted-foreground">
              {t("onboarding.EXPERIENCE_DESC")}
            </p>
            <div className="grid gap-2 sm:grid-cols-3">
              {FITNESS_LEVELS.map((level) => {
                const keys = FITNESS_LEVEL_KEY_MAP[level.value];
                return (
                  <button
                    key={level.value}
                    type="button"
                    onClick={() => field.onChange(level.value)}
                    className={`border p-4 text-left transition-colors ${
                      field.value === level.value
                        ? "border-[#e53e00] bg-[#e53e00]/10"
                        : "border-border hover:border-[#e53e00]/40"
                    }`}
                  >
                    <div className="font-data text-xs font-bold uppercase tracking-widest">
                      {keys ? t(keys.label) : level.label}
                    </div>
                    <div className="mt-1 font-data text-[10px] text-muted-foreground">
                      {keys ? t(keys.desc) : level.description}
                    </div>
                  </button>
                );
              })}
            </div>
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
