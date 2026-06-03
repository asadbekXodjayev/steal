"use client";

import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip
} from "recharts";
import { useI18n } from "@/components/providers/I18nProvider";

interface ProgressTrendData {
  week: string;
  maxE1RM: number;
  avgRpe: number;
  totalSets: number;
}

interface ProgressTrendChartProps {
  data: ProgressTrendData[];
}

export function ProgressTrendChart({ data }: ProgressTrendChartProps) {
  const { t } = useI18n();

  if (data.length === 0) {
    return (
      <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-6 text-center">
        <p className="font-data text-xs uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">
          {t("progress.INSUFFICIENT_DATA")}
        </p>
      </div>
    );
  }

  const tooltipMaxE1RM = t("progress.TOOLTIP_MAX_E1RM");
  const tooltipAvgRpe = t("progress.LEGEND_AVG_RPE");
  const tooltipTotalSets = t("progress.TOOLTIP_TOTAL_SETS");

  return (
    <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-3 w-full overflow-hidden">
      <div className="h-56 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 8, right: 4, left: 0, bottom: 0 }}>
            <XAxis
              dataKey="week"
              tick={{ fontSize: 9, fill: "#525252", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickMargin={4}
              interval="preserveStartEnd"
            />
            <YAxis
              yAxisId="left"
              tick={{ fontSize: 9, fill: "#e53e00", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              width={32}
            />
            <YAxis
              yAxisId="right"
              orientation="right"
              tick={{ fontSize: 9, fill: "#10b981", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              domain={[0, 10]}
              width={28}
            />
            <Tooltip
              content={({ active, payload }) => {
                if (!active || !payload || payload.length === 0) return null;
                const d = payload[0].payload as ProgressTrendData;
                return (
                  <div style={{
                    background: "#111111",
                    border: "1px solid #2a2a2a",
                    padding: "8px",
                    fontSize: "10px",
                    color: "#e5e5e5",
                  }}>
                    <div style={{ color: "#e53e00", textTransform: "uppercase", fontWeight: 700, marginBottom: "4px" }}>
                      {d.week}
                    </div>
                    <div style={{ color: "#e53e00" }}>{tooltipMaxE1RM}: {d.maxE1RM.toFixed(1)} kg</div>
                    <div style={{ color: "#10b981" }}>{tooltipAvgRpe}: {d.avgRpe.toFixed(1)} / 10</div>
                    <div style={{ color: "#a3a3a3" }}>{tooltipTotalSets}: {d.totalSets}</div>
                  </div>
                );
              }}
            />
            <Line
              yAxisId="left"
              type="monotone"
              dataKey="maxE1RM"
              stroke="#e53e00"
              strokeWidth={2}
              dot={{ fill: "#e53e00", r: 3 }}
              activeDot={{ r: 5 }}
            />
            <Line
              yAxisId="right"
              type="monotone"
              dataKey="avgRpe"
              stroke="#10b981"
              strokeWidth={2}
              dot={{ fill: "#10b981", r: 3 }}
              activeDot={{ r: 5 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
      {/* Legend */}
      <div className="flex items-center justify-center gap-6 mt-3 pt-3 border-t border-[#2a2a2a]">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-[#e53e00]" />
          <span className="font-data text-[9px] uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">{t("progress.LEGEND_MAX_E1RM")}</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-[#10b981]" />
          <span className="font-data text-[9px] uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">{t("progress.LEGEND_AVG_RPE")}</span>
        </div>
      </div>
    </div>
  );
}
