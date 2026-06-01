"use client";

import { useFieldArray, type UseFormReturn } from "react-hook-form";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Plus, X } from "lucide-react";
import type { OnboardingFormData } from "./types";
import { useI18n } from "@/components/providers/I18nProvider";

interface LimitationsStepProps {
  form: UseFormReturn<OnboardingFormData>;
}

export function LimitationsStep({ form }: LimitationsStepProps) {
  const { t } = useI18n();
  const { fields, append, remove } = useFieldArray({
    control: form.control,
    name: "limitations",
  });

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h2
          className="text-xl font-extrabold uppercase tracking-tight sm:text-2xl"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("onboarding.INJURIES_TITLE")}
        </h2>
        <p className="font-data text-xs text-muted-foreground">
          {t("onboarding.INJURIES_DESC")}
        </p>
      </div>

      <div className="space-y-3">
        {fields.map((field, index) => (
          <div
            key={field.id}
            className="relative space-y-3 border border-border bg-card p-4"
          >
            <button
              type="button"
              onClick={() => remove(index)}
              className="absolute right-3 top-3 p-1 text-muted-foreground hover:text-foreground"
              aria-label={t("onboarding.REMOVE_INJURY")}
            >
              <X className="h-4 w-4" />
            </button>

            <div className="grid gap-3 sm:grid-cols-2">
              <FormField
                control={form.control}
                name={`limitations.${index}.area`}
                render={({ field: f }) => (
                  <FormItem>
                    <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                      {t("onboarding.AREA")}
                    </FormLabel>
                    <FormControl>
                      <Input
                        placeholder={t("onboarding.AREA_PLACEHOLDER")}
                        className="rounded-none border-border bg-input font-data text-sm"
                        {...f}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name={`limitations.${index}.severity`}
                render={({ field: f }) => (
                  <FormItem>
                    <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                      {t("onboarding.SEVERITY")}
                    </FormLabel>
                    <Select onValueChange={f.onChange} value={f.value}>
                      <FormControl>
                        <SelectTrigger className="rounded-none border-border bg-input font-data text-sm">
                          <SelectValue />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="rounded-none border-border bg-card">
                        <SelectItem value="mild" className="font-data text-sm">{t("onboarding.MINOR")}</SelectItem>
                        <SelectItem value="moderate" className="font-data text-sm">{t("onboarding.MODERATE")}</SelectItem>
                        <SelectItem value="severe" className="font-data text-sm">{t("onboarding.SEVERE")}</SelectItem>
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name={`limitations.${index}.notes`}
              render={({ field: f }) => (
                <FormItem>
                  <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
                    {t("onboarding.INJURY_NOTES")}
                  </FormLabel>
                  <FormControl>
                    <Input
                      placeholder={t("onboarding.INJURY_NOTES_PLACEHOLDER")}
                      className="rounded-none border-border bg-input font-data text-sm"
                      {...f}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>
        ))}

        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => append({ area: "", severity: "mild", notes: "" })}
          className="rounded-none border-border font-data text-xs font-bold uppercase tracking-widest hover:border-[#e53e00]/40"
        >
          <Plus className="mr-2 h-4 w-4" />
          {t("onboarding.ADD_INJURY")}
        </Button>
      </div>

      <FormField
        control={form.control}
        name="injuryHistory"
        render={({ field }) => (
          <FormItem>
            <FormLabel className="font-data text-xs uppercase tracking-widest text-muted-foreground">
              {t("onboarding.INJURY_HISTORY")}
            </FormLabel>
            <FormControl>
              <Textarea
                placeholder={t("onboarding.OTHER_NOTES")}
                rows={3}
                className="rounded-none border-border bg-input font-data text-sm"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
