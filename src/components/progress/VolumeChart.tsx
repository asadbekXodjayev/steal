"use client";

import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Cell,
} from "recharts";

interface VolumeDataPoint {
  week: string;
  volume: number;
}

interface VolumeChartProps {
  data: VolumeDataPoint[];
}

export function VolumeChart({ data }: VolumeChartProps) {
  if (data.length === 0) {
    return (
      <div className="border border-border bg-card p-6 text-center">
        <p className="font-data text-sm uppercase tracking-wider text-muted-foreground">
          No data yet. Log sessions to see volume.
        </p>
      </div>
    );
  }

  const maxIndex = data.reduce(
    (acc, d, i) => (d.volume > data[acc].volume ? i : acc),
    0,
  );

  return (
    <div className="border border-border bg-card p-4 w-full overflow-hidden">
      <div className="h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" vertical={false} />
            <XAxis
              dataKey="week"
              tick={{ fontSize: 11, fill: "#888888" }}
              axisLine={{ stroke: "#2a2a2a" }}
              tickLine={false}
            />
            <YAxis
              tick={{ fontSize: 11, fill: "#888888" }}
              axisLine={{ stroke: "#2a2a2a" }}
              tickLine={false}
              tickFormatter={(v: number) =>
                v >= 1000 ? `${(v / 1000).toFixed(0)}k` : `${v}`
              }
            />
            <Tooltip
              cursor={{ fill: "#1a1a1a" }}
              contentStyle={{
                background: "#111111",
                border: "1px solid #2a2a2a",
                borderRadius: "2px",
                fontSize: "11px",
                color: "#f0f0f0",
              }}
              labelStyle={{ color: "#888888", textTransform: "uppercase" }}
              formatter={(value) => [
                `${Number(value ?? 0).toLocaleString()} kg`,
                "Volume",
              ]}
            />
            <Bar dataKey="volume" radius={0}>
              {data.map((_, idx) => (
                <Cell
                  key={idx}
                  fill={idx === maxIndex ? "#ff4500" : "#e53e00"}
                  fillOpacity={idx === maxIndex ? 1 : 0.8}
                />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
