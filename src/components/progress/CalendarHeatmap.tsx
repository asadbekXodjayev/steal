"use client";

import { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface HeatmapSession {
  completedAt: string;
  startedAt: string;
  volume?: number;
}

interface CalendarHeatmapProps {
  sessions: HeatmapSession[];
}

interface TooltipState {
  visible: boolean;
  x: number;
  y: number;
  label: string;
}

const DAYS = 7;
const CELL_SIZE = 10;
const GAP = 2;
const DAY_INITIALS = ["S", "M", "T", "W", "T", "F", "S"];

function getIntensityColor(volume: number, maxVolume: number, count: number): string {
  if (count === 0) return "rgba(255,255,255,0.04)";
  if (maxVolume > 0) {
    const ratio = volume / maxVolume;
    if (ratio < 0.25) return "rgba(194,65,12,0.12)";
    if (ratio < 0.6)  return "rgba(194,65,12,0.55)";
    return "#C2410C";
  }
  if (count === 1) return "rgba(194,65,12,0.12)";
  if (count >= 2)  return "#C2410C";
  return "rgba(194,65,12,0.55)";
}

function formatMonthLabel(date: Date): string {
  return date.toLocaleString("en-US", { month: "short" }).toUpperCase();
}

export function CalendarHeatmap({ sessions }: CalendarHeatmapProps) {
  const { t } = useI18n();
  const [tooltip, setTooltip] = useState<TooltipState>({
    visible: false,
    x: 0,
    y: 0,
    label: "",
  });

  const { grid, monthLabels, maxVolume, weeks } = useMemo(() => {
    // Build a map of date-string -> { volume, count }
    const dayMap = new Map<string, { volume: number; count: number }>();

    for (const s of sessions) {
      const dateStr = s.completedAt
        ? s.completedAt.slice(0, 10)
        : s.startedAt.slice(0, 10);
      const existing = dayMap.get(dateStr) ?? { volume: 0, count: 0 };
      dayMap.set(dateStr, {
        volume: existing.volume + (s.volume ?? 0),
        count: existing.count + 1,
      });
    }

    // Grid spans Jan 1 – Dec 31 of the current year,
    // padded to full Sunday-aligned weeks.
    const currentYear = new Date().getFullYear();

    const jan1 = new Date(currentYear, 0, 1);
    jan1.setHours(0, 0, 0, 0);
    const dec31 = new Date(currentYear, 11, 31);
    dec31.setHours(0, 0, 0, 0);

    // First Sunday on or before Jan 1
    const gridStart = new Date(jan1);
    gridStart.setDate(jan1.getDate() - jan1.getDay());

    // Last Saturday on or after Dec 31
    const gridEnd = new Date(dec31);
    gridEnd.setDate(dec31.getDate() + (6 - dec31.getDay()));

    const totalDays = Math.round((gridEnd.getTime() - gridStart.getTime()) / 86400000) + 1;
    const weeks = totalDays / 7;

    let maxVol = 0;
    const cells: { date: Date; volume: number; count: number }[][] = [];

    for (let w = 0; w < weeks; w++) {
      const week: { date: Date; volume: number; count: number }[] = [];
      for (let d = 0; d < DAYS; d++) {
        const date = new Date(gridStart);
        date.setDate(gridStart.getDate() + w * 7 + d);
        const dateStr = date.toISOString().slice(0, 10);
        const data = dayMap.get(dateStr) ?? { volume: 0, count: 0 };
        if (data.volume > maxVol) maxVol = data.volume;
        week.push({ date, volume: data.volume, count: data.count });
      }
      cells.push(week);
    }

    // Build month labels: find the first week where a new month starts
    const labels: { weekIndex: number; label: string }[] = [];
    let lastMonth = -1;
    for (let w = 0; w < weeks; w++) {
      const month = cells[w][0].date.getMonth();
      if (month !== lastMonth) {
        labels.push({ weekIndex: w, label: formatMonthLabel(cells[w][0].date) });
        lastMonth = month;
      }
    }

    return { grid: cells, monthLabels: labels, maxVolume: maxVol, weeks };
  }, [sessions]);

  const colWidth = CELL_SIZE + GAP;
  const rowHeight = CELL_SIZE + GAP;
  const leftOffset = 20; // for day-of-week initials
  const topOffset = 18; // for month labels

  function handleMouseEnter(
    e: React.MouseEvent<SVGRectElement>,
    date: Date,
    volume: number,
    count: number
  ) {
    if (count === 0 && volume === 0) return;
    const rect = (e.target as SVGRectElement).getBoundingClientRect();
    const dateLabel = date
      .toLocaleString("en-US", { month: "short", day: "numeric" })
      .toUpperCase();
    const sessionWord = count > 1 ? t("progress.HEATMAP_SESSIONS") : t("progress.HEATMAP_SESSION");
    const volumeLabel = volume > 0 ? `${volume.toLocaleString()} KG` : `${count} ${sessionWord.toUpperCase()}`;
    setTooltip({
      visible: true,
      x: rect.left + rect.width / 2,
      y: rect.top - 8,
      label: `${dateLabel} — ${volumeLabel}`,
    });
  }

  function handleMouseLeave() {
    setTooltip((prev) => ({ ...prev, visible: false }));
  }

  const svgWidth = leftOffset + weeks * colWidth;
  const svgHeight = topOffset + DAYS * rowHeight;

  return (
    <div className="relative select-none">
      {/* Tooltip */}
      {tooltip.visible && (
        <div
          className="fixed z-50 pointer-events-none"
          style={{ left: tooltip.x, top: tooltip.y, transform: "translate(-50%, -100%)" }}
        >
          <div
            className="stamp px-2 py-1 text-[10px]"
            style={{
              background: "var(--surface-3)",
              border: "1px solid var(--border-strong)",
              borderTop: "2px solid var(--rust)",
              color: "var(--ink-high)",
              whiteSpace: "nowrap",
            }}
          >
            {tooltip.label}
          </div>
        </div>
      )}

      <svg
        width={svgWidth}
        height={svgHeight}
        style={{ display: "block", overflow: "visible" }}
        aria-label={t("progress.HEATMAP_ARIA")}
        role="img"
      >
        {/* Month labels */}
        {monthLabels.map(({ weekIndex, label }) => (
          <text
            key={`month-${weekIndex}`}
            x={leftOffset + weekIndex * colWidth}
            y={topOffset - 6}
            style={{
              fontSize: "10px",
              fontFamily: "var(--font-mono, monospace)",
              textTransform: "uppercase",
              fill: "rgba(163,163,163,0.9)",
              letterSpacing: "0.1em",
            }}
          >
            {label}
          </text>
        ))}

        {/* Day-of-week initials — M W F only */}
        {[1, 3, 5].map((d) => (
          <text
            key={`dow-${d}`}
            x={leftOffset - 6}
            y={topOffset + d * rowHeight + CELL_SIZE / 2 + 3}
            textAnchor="end"
            style={{
              fontSize: "10px",
              fontFamily: "var(--font-mono, monospace)",
              fill: "rgba(163,163,163,0.9)",
              textTransform: "uppercase",
            }}
          >
            {DAY_INITIALS[d]}
          </text>
        ))}

        {/* Cells */}
        {grid.map((week, w) =>
          week.map((cell, d) => {
            const color = getIntensityColor(cell.volume, maxVolume, cell.count);
            const sessionWord = cell.count !== 1 ? t("progress.HEATMAP_SESSIONS") : t("progress.HEATMAP_SESSION");
            return (
              <rect
                key={`${w}-${d}`}
                x={leftOffset + w * colWidth}
                y={topOffset + d * rowHeight}
                width={CELL_SIZE}
                height={CELL_SIZE}
                fill={color}
                rx={0}
                ry={0}
                style={{ cursor: cell.count > 0 ? "pointer" : "default" }}
                onMouseEnter={(e) => handleMouseEnter(e, cell.date, cell.volume, cell.count)}
                onMouseLeave={handleMouseLeave}
                aria-label={`${cell.date.toDateString()}: ${cell.count} ${sessionWord}`}
              />
            );
          })
        )}
      </svg>

      {/* Legend */}
      <div
        className="flex items-center gap-1 justify-end mt-2"
        style={{ fontFamily: "var(--font-mono, monospace)", fontSize: "10px", textTransform: "uppercase", color: "rgba(163,163,163,0.9)" }}
      >
        <span>{t("progress.HEATMAP_LESS")}</span>
        {(["var(--surface-2)", "#14532d", "var(--tactical)", "#22c55e"] as const).map(
          (color, i) => (
            <span
              key={i}
              style={{
                display: "inline-block",
                width: CELL_SIZE,
                height: CELL_SIZE,
                background: color,
                border: "1px solid rgba(229,229,229,0.06)",
              }}
            />
          )
        )}
        <span>{t("progress.HEATMAP_MORE")}</span>
      </div>
    </div>
  );
}
