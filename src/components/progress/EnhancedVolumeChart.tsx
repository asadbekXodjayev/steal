"use client";

import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ReferenceLine,
} from "recharts";
import { useI18n } from "@/components/providers/I18nProvider";

interface EnhancedVolumeData {
  week: string;
  volume: number;
  avgRpe: number;
  sessions: number;
}

interface EnhancedVolumeChartProps {
  data: EnhancedVolumeData[];
}

export function EnhancedVolumeChart({ data }: EnhancedVolumeChartProps) {
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

  const maxVolume = Math.max(...data.map((d) => d.volume));
  const avgVolume = data.reduce((sum, d) => sum + d.volume, 0) / data.length;

  const tooltipVolumeLabel = t("progress.TOOLTIP_VOLUME");
  const tooltipAvgRpeLabel = t("progress.TOOLTIP_AVG_RPE");
  const tooltipSessionsLabel = t("progress.TOOLTIP_SESSIONS");

  return (
    <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-3 w-full overflow-hidden">
      <div className="h-48 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
            <XAxis
              dataKey="week"
              tick={{ fontSize: 9, fill: "#525252", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickMargin={4}
            />
            <YAxis
              tick={{ fontSize: 9, fill: "#525252", fontFamily: "var(--font-mono, monospace)" }}
              axisLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickLine={{ stroke: "#2a2a2a", strokeWidth: 1 }}
              tickFormatter={(v: number) => (v >= 1000 ? `${(v / 1000).toFixed(0)}k` : `${v}`)}
              width={35}
              domain={[0, (dataMax: number) => dataMax * 1.15]}
            />
            <Tooltip
              cursor={{ fill: "#1a1a1a" }}
              contentStyle={{
                background: "#111111",
                border: "1px solid #e53e00",
                borderRadius: "0",
                fontSize: "10px",
                color: "#e5e5e5",
                padding: "8px",
              }}
              labelStyle={{
                color: "#e53e00",
                textTransform: "uppercase",
                fontFamily: "var(--font-mono, monospace)",
                fontWeight: 700,
                marginBottom: "4px"
              }}
              content={({ active, payload }) => {
                if (!active || !payload || payload.length === 0) return null;
                const d = payload[0].payload as EnhancedVolumeData;
                return (
                  <div style={{
                    background: "#111111",
                    border: "1px solid #e53e00",
                    padding: "8px",
                    fontSize: "10px",
                    color: "#e5e5e5",
                  }}>
                    <div style={{ color: "#e53e00", textTransform: "uppercase", fontWeight: 700, marginBottom: "4px" }}>
                      {d.week}
                    </div>
                    <div>{tooltipVolumeLabel}: {Math.round(d.volume).toLocaleString()} kg</div>
                    <div>{tooltipAvgRpeLabel}: {d.avgRpe.toFixed(1)}</div>
                    <div>{tooltipSessionsLabel}: {d.sessions}</div>
                  </div>
                );
              }}
            />
            {data.length >= 2 && (
              <ReferenceLine
                y={avgVolume}
                stroke="#e53e00"
                strokeDasharray="4 4"
                label={{
                  value: "AVG",
                  position: "insideTopRight",
                  fill: "#e53e00",
                  fontSize: 9,
                  fontFamily: "var(--font-mono, monospace)"
                }}
              />
            )}
            <Bar
              dataKey="volume"
              radius={0}
              fill="#e53e00"
              animationDuration={500}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
      {/* Mini stats row */}
      <div className="grid grid-cols-3 gap-2 mt-3 pt-3 border-t border-[#2a2a2a]">
        <div>
          <div className="font-data text-[9px] uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">{t("progress.PEAK")}</div>
          <div className="font-data text-xs font-bold tabular-nums text-[#e53e00]">
            {Math.round(maxVolume).toLocaleString()} kg
          </div>
        </div>
        <div>
          <div className="font-data text-[9px] uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">{t("progress.AVG")}</div>
          <div className="font-data text-xs font-bold tabular-nums text-[#a3a3a3]">
            {Math.round(avgVolume).toLocaleString()} kg
          </div>
        </div>
        <div>
          <div className="font-data text-[9px] uppercase tracking-[0.08em] sm:tracking-widest text-[#71717A]">{t("progress.SESSIONS_LABEL")}</div>
          <div className="font-data text-xs font-bold tabular-nums text-[#525252]">
            {data.reduce((sum, d) => sum + d.sessions, 0)}
          </div>
        </div>
      </div>
    </div>
  );
}
