"use client";

import {
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { ENVIRONMENT_OPTIONS, EQUIPMENT_OPTIONS } from "@/lib/constants";
import { Building2, Home, Trees, Shuffle } from "lucide-react";
import type { UseFormReturn } from "react-hook-form";
import type { OnboardingFormData } from "./types";
import type { EquipmentItem } from "@/types/profile";
import { useI18n } from "@/components/providers/I18nProvider";

const envIcons = {
  gym: Building2,
  home: Home,
  outdoor: Trees,
  mixed: Shuffle,
} as const;

interface EnvironmentStepProps {
  form: UseFormReturn<OnboardingFormData>;
}

export function EnvironmentStep({ form }: EnvironmentStepProps) {
  const { t } = useI18n();
  const environment = form.watch("environment");

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h2
          className="text-xl font-extrabold uppercase tracking-tight sm:text-2xl"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("onboarding.YOUR_ARENA")}
        </h2>
        <p className="font-data text-xs text-muted-foreground">
          {t("onboarding.ARENA_DESC")}
        </p>
      </div>

      <FormField
        control={form.control}
        name="environment"
        render={({ field }) => (
          <FormItem>
            <div className="grid gap-2 sm:grid-cols-2">
              {ENVIRONMENT_OPTIONS.map((env) => {
                const Icon = envIcons[env.value];
                const active = field.value === env.value;
                return (
                  <button
                    key={env.value}
                    type="button"
                    onClick={() => field.onChange(env.value)}
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
                        {env.label}
                      </div>
                      <div className="mt-0.5 font-data text-[10px] text-muted-foreground">
                        {env.description}
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

      {environment && (
        <FormField
          control={form.control}
          name="equipment"
          render={({ field }) => (
            <FormItem>
              <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                {t("onboarding.AVAILABLE_GEAR")}
              </FormLabel>
              <p className="font-data text-[10px] text-muted-foreground">
                {t("onboarding.GEAR_DESC")}
              </p>
              <div className="grid grid-cols-2 gap-1.5 sm:grid-cols-3">
                {EQUIPMENT_OPTIONS.map((eq) => {
                  const selected = (field.value as EquipmentItem[]).includes(eq.value);
                  return (
                    <button
                      key={eq.value}
                      type="button"
                      onClick={() => {
                        const current = field.value as EquipmentItem[];
                        field.onChange(
                          selected
                            ? current.filter((v) => v !== eq.value)
                            : [...current, eq.value],
                        );
                      }}
                      className={`border px-3 py-2 text-left transition-colors ${
                        selected
                          ? "border-[#e53e00] bg-[#e53e00]/10 font-medium"
                          : "border-border text-muted-foreground hover:border-[#e53e00]/40"
                      }`}
                    >
                      <span className="font-data text-xs">{eq.label}</span>
                    </button>
                  );
                })}
              </div>
              <FormMessage />
            </FormItem>
          )}
        />
      )}
    </div>
  );
}
