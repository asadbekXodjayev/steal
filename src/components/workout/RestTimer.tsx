"use client";

import { Button } from "@/components/ui/button";
import { formatDuration } from "@/lib/utils";
import { Timer, X, Plus, Minus } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

interface RestTimerProps {
  secondsLeft: number;
  isRunning: boolean;
  onStart: (seconds: number) => void;
  onStop: () => void;
  defaultSeconds: number;
}

export function RestTimer({
  secondsLeft,
  isRunning,
  onStart,
  onStop,
  defaultSeconds,
}: RestTimerProps) {
  const { t } = useI18n();
  if (!isRunning && secondsLeft === 0) return null;

  const progress = isRunning
    ? ((defaultSeconds - secondsLeft) / defaultSeconds) * 100
    : 100;

  return (
    // bottom-16 = above BottomNav (h-16); add extra pb-safe for devices with home indicator
    <div className="fixed inset-x-0 bottom-16 z-40 md:bottom-0">
      <div className="mx-auto max-w-md px-4 pb-4">
        <div className="border border-border bg-card p-4 shadow-lg">
          {/* Progress bar — squared corners to match brand */}
          <div className="mb-3 h-1 overflow-hidden bg-muted">
            <div
              className="h-full bg-foreground transition-all duration-1000"
              style={{ width: `${progress}%` }}
            />
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Timer className="h-4 w-4 text-muted-foreground" />
              <span className="text-2xl font-bold tabular-nums">
                {formatDuration(secondsLeft)}
              </span>
            </div>

            <div className="flex items-center gap-1">
              {isRunning && (
                <>
                  {/* ≥44px touch target on mobile, compact at sm+ */}
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-10 w-10 sm:h-8 sm:w-8"
                    onClick={() => onStart(secondsLeft - 15)}
                    disabled={secondsLeft <= 15}
                    aria-label={t("workout.SUBTRACT_15_SECONDS")}
                  >
                    <Minus className="h-4 w-4 sm:h-3 sm:w-3" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-10 w-10 sm:h-8 sm:w-8"
                    onClick={() => onStart(secondsLeft + 15)}
                    aria-label={t("workout.ADD_15_SECONDS")}
                  >
                    <Plus className="h-4 w-4 sm:h-3 sm:w-3" />
                  </Button>
                </>
              )}
              <Button
                variant="ghost"
                size="icon"
                className="h-10 w-10 sm:h-8 sm:w-8"
                onClick={onStop}
                aria-label={t("workout.SKIP_REST")}
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          </div>

          {secondsLeft === 0 && (
            <p className="mt-2 text-center text-sm font-medium text-success">
              {t("workout.REST_COMPLETE")}
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
