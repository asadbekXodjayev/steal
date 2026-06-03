"use client";

import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";
import type { PersonalRecord } from "@/types/progress";

interface PRBoardProps {
  records: PersonalRecord[];
  className?: string;
}

export function PRBoard({ records, className }: PRBoardProps) {
  const { t } = useI18n();

  const COLS = [
    t("progress.COL_EXERCISE"),
    t("progress.COL_WEIGHT"),
    t("progress.COL_REPS"),
  ];

  if (records.length === 0) {
    return (
      <div className={cn("flex items-center justify-center py-10", className)}>
        <span className="font-data text-sm text-[#A3A3A3] tracking-[0.15em] uppercase">
          {t("progress.NO_RECORDS_YET")}
        </span>
      </div>
    );
  }

  return (
    <div
      className={cn("overflow-hidden", className)}
      role="table"
      aria-label={t("progress.PR_BOARD_ARIA")}
      style={{
        display: "grid",
        gridTemplateColumns: "2fr 1fr 1fr",
        gap: 1,
      }}
    >
      {/* Header row */}
      {COLS.map((h) => (
        <div
          key={h}
          role="columnheader"
          style={{ padding: "6px 10px", background: "rgba(0,0,0,0.5)" }}
        >
          <span className="font-data text-xs text-[#525252] tracking-[0.1em] uppercase" style={{ fontSize: '11px' }}>{h}</span>
        </div>
      ))}

      {/* Data rows */}
      {records.map((pr, i) => {
        const bg = i % 2 === 0 ? "rgba(255,255,255,0.05)" : "rgba(0,0,0,0.3)";
        const baseCellStyle = {
          padding: "8px 10px",
          background: bg,
          borderBottom: "1px solid rgba(255,255,255,0.05)",
        };

        return [
          <div key={`${i}-0`} role="cell" style={baseCellStyle}>
            <span className="font-data text-sm text-[#A3A3A3] uppercase leading-tight block truncate" style={{ fontSize: '13px' }}>
              {pr.exerciseName}
            </span>
          </div>,
          <div key={`${i}-1`} role="cell" style={baseCellStyle}>
            <span className="font-data text-lg font-bold text-[#e53e00]" style={{ fontSize: '16px' }}>
              {Math.round(pr.weight)} kg
            </span>
          </div>,
          <div key={`${i}-2`} role="cell" style={baseCellStyle}>
            <span className="font-data text-sm text-[#A3A3A3]" style={{ fontSize: '13px' }}>
              {pr.reps}
            </span>
          </div>,
        ];
      })}
    </div>
  );
}
