"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import type { ValueType, NameType } from "recharts/types/component/DefaultTooltipContent";
import type { TooltipContentProps } from "recharts/types/component/Tooltip";
import { useI18n } from "@/components/providers/I18nProvider";

interface VolumeWeek {
  week: string;
  chest: number;
  back: number;
  legs: number;
  shoulders: number;
  arms: number;
  core: number;
}

interface VolumeStackedChartProps {
  data: VolumeWeek[];
}

const MUSCLE_CONFIG = [
  { key: "chest", label: "CHEST", color: "#B91C1C" },
  { key: "back", label: "BACK", color: "#EA580C" },
  { key: "legs", label: "LEGS", color: "#C2410C" },
  { key: "shoulders", label: "SHOULDERS", color: "#9F1239" },
  { key: "arms", label: "ARMS", color: "#991B1B" },
  { key: "core", label: "CORE", color: "#7F1D1D" },
] as const;

type MuscleKey = (typeof MUSCLE_CONFIG)[number]["key"];

function formatWeekLabel(week: string): string {
  const date = new Date(week);
  return date.toLocaleString("en-US", { month: "short", day: "numeric" }).toUpperCase();
}

export function VolumeStackedChart({ data }: VolumeStackedChartProps) {
  const { t } = useI18n();
  const totalLabel = t("progress.TOTAL_LABEL");

  const monoStyle = {
    fontFamily: "var(--font-mono, monospace)",
    fontSize: 10,
    textTransform: "uppercase" as const,
    fill: "rgba(163,163,163,0.9)",
  };

  function CustomTooltip({ active, payload, label }: TooltipContentProps<ValueType, NameType>) {
    if (!active || !payload || payload.length === 0) return null;

    const total = payload.reduce((sum: number, p) => sum + (Number(p.value) ?? 0), 0);

    return (
      <div
        style={{
          background: "var(--surface-3)",
          border: "1px solid var(--border-strong)",
          borderTop: "2px solid var(--rust)",
          padding: "8px 10px",
          minWidth: 140,
        }}
      >
        <div
          className="stamp mb-2"
          style={{ color: "var(--ink-mid)", letterSpacing: "0.15em" }}
        >
          {typeof label === "string" ? formatWeekLabel(label) : label}
        </div>
        {[...payload].reverse().map((p, idx) => {
          const config = MUSCLE_CONFIG.find((m) => m.key === p.dataKey);
          if (!config || !p.value) return null;
          return (
            <div key={`${String(p.dataKey)}-${idx}`} className="flex items-center justify-between gap-4 mb-0.5">
              <div className="flex items-center gap-1.5">
                <span
                  style={{
                    display: "inline-block",
                    width: 8,
                    height: 8,
                    background: config.color,
                    flexShrink: 0,
                  }}
                />
                <span
                  style={{
                    fontFamily: "var(--font-mono, monospace)",
                    fontSize: 10,
                    textTransform: "uppercase",
                    color: "var(--ink-mid)",
                    letterSpacing: "0.1em",
                  }}
                >
                  {config.label}
                </span>
              </div>
              <span
                style={{
                  fontFamily: "var(--font-mono, monospace)",
                  fontSize: 10,
                  color: "var(--ink-high)",
                  fontVariantNumeric: "tabular-nums",
                }}
              >
                {Number(p.value).toLocaleString()}
              </span>
            </div>
          );
        })}
        <div
          style={{
            borderTop: "1px solid var(--border-strong)",
            marginTop: 6,
            paddingTop: 4,
            display: "flex",
            justifyContent: "space-between",
          }}
        >
          <span
            style={{
              fontFamily: "var(--font-mono, monospace)",
              fontSize: 10,
              textTransform: "uppercase",
              color: "var(--rust)",
              letterSpacing: "0.1em",
            }}
          >
            {totalLabel}
          </span>
          <span
            style={{
              fontFamily: "var(--font-mono, monospace)",
              fontSize: 10,
              color: "var(--ink-high)",
              fontVariantNumeric: "tabular-nums",
            }}
          >
            {total.toLocaleString()} KG
          </span>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full overflow-hidden">
      <ResponsiveContainer width="100%" height={220}>
        <BarChart
          data={data}
          margin={{ top: 4, right: 4, bottom: 0, left: 0 }}
          barCategoryGap="20%"
        >
          <XAxis
            dataKey="week"
            tickFormatter={formatWeekLabel}
            tick={monoStyle}
            axisLine={{ stroke: "rgba(229,229,229,0.06)" }}
            tickLine={false}
          />
          <YAxis
            tick={monoStyle}
            axisLine={false}
            tickLine={false}
            tickFormatter={(v: number) =>
              v >= 1000 ? `${(v / 1000).toFixed(0)}K` : String(v)
            }
            width={36}
          />
          <Tooltip
            content={CustomTooltip}
            cursor={{ fill: "rgba(229,229,229,0.04)" }}
          />
          {MUSCLE_CONFIG.map((m) => (
            <Bar
              key={m.key}
              dataKey={m.key as MuscleKey}
              stackId="a"
              fill={m.color}
              radius={[0, 0, 0, 0]}
              isAnimationActive={false}
            />
          ))}
        </BarChart>
      </ResponsiveContainer>

      {/* Legend row — inline below chart, wraps on small screens */}
      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-2">
        {MUSCLE_CONFIG.map((m) => (
          <div key={m.key} className="flex items-center gap-1.5">
            <span
              style={{
                display: "inline-block",
                width: 8,
                height: 8,
                background: m.color,
                flexShrink: 0,
              }}
            />
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: 9,
                textTransform: "uppercase",
                color: "var(--ink-low)",
                letterSpacing: "0.08em",
              }}
            >
              {m.label.slice(0, 4)}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
