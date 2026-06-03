"use client";

import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Cell
} from "recharts";
import { useI18n } from "@/components/providers/I18nProvider";

interface RepsDistributionData {
  reps: string;
  count: number;
}

interface RepsDistributionChartProps {
  data: RepsDistributionData[];
}

const repColors = [
  "#166534", // 1-3: very heavy
  "#15803d", // 4-5: heavy
  "#16a34a", // 6-8: moderate
  "#22c55e", // 9-10: light
  "#4ade80", // 11-12: very light
  "#86efac", // 13+: endurance
];

export function RepsDistributionChart({ data }: RepsDistributionChartProps) {
  const { t } = useI18n();

  if (data.length === 0) {
    return (
      <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-6 text-center">
        <p className="font-data text-xs uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">
          {t("progress.NO_REP_DATA")}
        </p>
      </div>
    );
  }

  const maxCount = Math.max(...data.map((d) => d.count));
  const repsSuffix = t("progress.TOOLTIP_REPS_SUFFIX");
  const occurrencesLabel = t("progress.TOOLTIP_OCCURRENCES");

  return (
    <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-3 w-full overflow-hidden">
      <div className="h-48 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
            <XAxis
              dataKey="reps"
              tick={{ fontSize: 9, fill: "#525252", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickMargin={4}
            />
            <YAxis
              tick={{ fontSize: 9, fill: "#525252", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              width={30}
            />
            <Tooltip
              content={({ active, payload }) => {
                if (!active || !payload || payload.length === 0) return null;
                const d = payload[0].payload as RepsDistributionData;
                return (
                  <div style={{
                    background: "#111111",
                    border: "1px solid #2a2a2a",
                    padding: "8px",
                    fontSize: "10px",
                    color: "#e5e5e5",
                  }}>
                    <div style={{ color: "#e53e00", textTransform: "uppercase", fontWeight: 700, marginBottom: "4px" }}>
                      {d.reps} {repsSuffix}
                    </div>
                    <div>{occurrencesLabel}: {d.count}</div>
                  </div>
                );
              }}
            />
            <Bar dataKey="count" radius={0}>
              {data.map((entry, index) => (
                <Cell
                  key={index}
                  fill={repColors[index % repColors.length]}
                  fillOpacity={entry.count === maxCount ? 1 : 0.7}
                />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
      {/* Intensity labels */}
      <div className="grid grid-cols-6 gap-1 mt-3 pt-3 border-t border-[#2a2a2a]">
        <div className="text-center">
          <div className="w-2 h-2 bg-[#166534] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">1-3</span>
        </div>
        <div className="text-center">
          <div className="w-2 h-2 bg-[#15803d] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">4-5</span>
        </div>
        <div className="text-center">
          <div className="w-2 h-2 bg-[#16a34a] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">6-8</span>
        </div>
        <div className="text-center">
          <div className="w-2 h-2 bg-[#22c55e] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">9-10</span>
        </div>
        <div className="text-center">
          <div className="w-2 h-2 bg-[#4ade80] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">11-12</span>
        </div>
        <div className="text-center">
          <div className="w-2 h-2 bg-[#86efac] mx-auto mb-1" />
          <span className="font-data text-[8px] uppercase tracking-[0.04em] text-[#525252]">13+</span>
        </div>
      </div>
    </div>
  );
}
