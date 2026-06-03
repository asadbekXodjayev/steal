"use client";

import { useMemo } from "react";
import { ACHIEVEMENT_DEFS } from "@/hooks/useAchievements";
import { formatDate } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";
import type {
  AchievementDef,
  AchievementTier,
  UserAchievement,
} from "@/types/achievement";

interface AchievementsBoardProps {
  unlocked: UserAchievement[];
}

const TIER_COLORS: Record<AchievementTier, string> = {
  bronze: "#b45309",
  silver: "#6b7280",
  gold: "#e53e00",
  platinum: "#c084fc",
};

const TIER_ORDER: Record<AchievementTier, number> = {
  bronze: 0,
  silver: 1,
  gold: 2,
  platinum: 3,
};

interface BadgeProps {
  def: AchievementDef;
  unlockedAt: string | null;
  lockedLabel: string;
}

function Badge({ def, unlockedAt, lockedLabel }: BadgeProps) {
  const tierColor = TIER_COLORS[def.tier];
  const isLocked = unlockedAt === null;

  return (
    <div
      className="relative flex flex-col items-center border border-border bg-card p-4 text-center"
      style={{
        borderTop: `2px solid ${isLocked ? "#2a2a2a" : tierColor}`,
        opacity: isLocked ? 0.4 : 1,
      }}
    >
      <div
        className="font-data flex h-12 w-12 items-center justify-center border tabular-nums"
        style={{
          borderColor: isLocked ? "#2a2a2a" : tierColor,
          color: isLocked ? "#444444" : tierColor,
          fontSize: def.icon.length > 2 ? "0.9rem" : "1.4rem",
          fontWeight: 700,
        }}
        aria-hidden="true"
      >
        {def.icon}
      </div>

      <div
        className="mt-3 text-sm font-bold uppercase tracking-tight text-foreground"
        style={{ fontFamily: "var(--font-heading, system-ui)" }}
      >
        {def.name}
      </div>

      <p className="mt-1 text-[10px] uppercase tracking-[0.06em] sm:tracking-wider text-muted-foreground">
        {def.description}
      </p>

      <div className="font-data mt-3 text-[10px] uppercase tracking-wider">
        {isLocked ? (
          <span className="text-muted-foreground">{lockedLabel}</span>
        ) : (
          <span style={{ color: tierColor }}>{formatDate(unlockedAt)}</span>
        )}
      </div>
    </div>
  );
}

export function AchievementsBoard({ unlocked }: AchievementsBoardProps) {
  const { t } = useI18n();

  const merged = useMemo(() => {
    const unlockedMap = new Map(unlocked.map((u) => [u.id, u.unlockedAt]));
    return Object.values(ACHIEVEMENT_DEFS)
      .map((def) => ({
        def,
        unlockedAt: unlockedMap.get(def.id) ?? null,
      }))
      .sort((a, b) => {
        // Unlocked first, then by tier
        if (a.unlockedAt && !b.unlockedAt) return -1;
        if (!a.unlockedAt && b.unlockedAt) return 1;
        return TIER_ORDER[b.def.tier] - TIER_ORDER[a.def.tier];
      });
  }, [unlocked]);

  const lockedLabel = t("progress.LOCKED");

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {merged.map((entry) => (
        <Badge
          key={entry.def.id}
          def={entry.def}
          unlockedAt={entry.unlockedAt}
          lockedLabel={lockedLabel}
        />
      ))}
    </div>
  );
}
