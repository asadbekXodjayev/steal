"use client";

import { MOOD_OPTIONS } from "@/lib/constants";
import { cn } from "@/lib/utils";
import type { MoodLevel } from "@/types/session";
import { useI18n } from "@/components/providers/I18nProvider";

// Map mood value → mood.* translation key suffix
const MOOD_LABEL_KEYS: Record<string, string> = {
  great:    "mood.GREAT_LABEL",
  good:     "mood.GOOD_LABEL",
  okay:     "mood.OKAY_LABEL",
  rough:    "mood.ROUGH_LABEL",
  terrible: "mood.TERRIBLE_LABEL",
};

interface MoodCheckProps {
  value: MoodLevel | null;
  onChange: (mood: MoodLevel) => void;
  label: string;
}

export function MoodCheck({ value, onChange, label }: MoodCheckProps) {
  const { t } = useI18n();

  return (
    <div className="space-y-2">
      <p className="text-sm font-medium">{label}</p>
      <div className="flex gap-2">
        {MOOD_OPTIONS.map((option) => {
          const moodLabel = t(MOOD_LABEL_KEYS[option.value] ?? "mood.OKAY_LABEL");
          return (
            <button
              key={option.value}
              type="button"
              onClick={() => onChange(option.value as MoodLevel)}
              // Squared corners — no rounded-*; min h-10 for 44px touch target on mobile
              className={cn(
                "flex flex-1 flex-col items-center gap-1 border p-3 transition-colors min-h-[44px]",
                value === option.value
                  ? "border-foreground bg-accent"
                  : "border-border hover:border-foreground/30",
              )}
              aria-label={moodLabel}
            >
              <span className="text-xl">{option.emoji}</span>
              <span className="text-xs text-muted-foreground">{moodLabel}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
