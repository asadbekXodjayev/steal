"use client";

import {
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Tooltip,
} from "recharts";

interface MuscleDatum {
  name: string;
  value: number;
  percentage: number;
}

interface MuscleDistributionProps {
  data: MuscleDatum[];
}

const COLORS = [
  "#e53e00",
  "#b91c1c",
  "#7a2200",
  "#444444",
  "#555555",
  "#333333",
  "#666666",
] as const;

function renderLabel(props: unknown): React.ReactNode {
  const p = props as {
    cx?: number;
    cy?: number;
    midAngle?: number;
    innerRadius?: number;
    outerRadius?: number;
    percent?: number;
  };
  const cx = p.cx ?? 0;
  const cy = p.cy ?? 0;
  const midAngle = p.midAngle ?? 0;
  const innerRadius = p.innerRadius ?? 0;
  const outerRadius = p.outerRadius ?? 0;
  const percent = p.percent ?? 0;
  if (percent < 0.05) return null;
  const RADIAN = Math.PI / 180;
  const radius = innerRadius + (outerRadius - innerRadius) * 0.6;
  const x = cx + radius * Math.cos(-midAngle * RADIAN);
  const y = cy + radius * Math.sin(-midAngle * RADIAN);

  return (
    <text
      x={x}
      y={y}
      fill="#f0f0f0"
      textAnchor="middle"
      dominantBaseline="central"
      fontSize={11}
      fontFamily="var(--font-mono, monospace)"
      style={{ fontVariantNumeric: "tabular-nums" }}
    >
      {`${Math.round(percent * 100)}%`}
    </text>
  );
}

export function MuscleDistribution({ data }: MuscleDistributionProps) {
  if (data.length === 0) {
    return (
      <div className="border border-border bg-card p-6 text-center">
        <p className="font-data text-sm uppercase tracking-wider text-muted-foreground">
          Log sessions to see muscle distribution.
        </p>
      </div>
    );
  }

  const total = data.reduce((acc, d) => acc + d.value, 0);

  return (
    <div className="grid gap-4 border border-border bg-card p-4 sm:grid-cols-2 overflow-hidden">
      <div className="h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              outerRadius="90%"
              innerRadius="35%"
              stroke="#0a0a0a"
              strokeWidth={2}
              label={renderLabel}
              labelLine={false}
              isAnimationActive={false}
            >
              {data.map((_, idx) => (
                <Cell key={idx} fill={COLORS[idx % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{
                background: "#111111",
                border: "1px solid #2a2a2a",
                borderRadius: "2px",
                fontSize: "11px",
                color: "#f0f0f0",
              }}
              formatter={(value, name) => [
                `${value ?? 0} sessions`,
                String(name ?? "").toUpperCase(),
              ]}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      <ul className="flex flex-col justify-center gap-2">
        {data.map((d, idx) => (
          <li
            key={d.name}
            className="flex items-center justify-between gap-2 border-b border-border pb-1.5"
          >
            <div className="flex items-center gap-2 min-w-0">
              <span
                className="h-3 w-3 shrink-0"
                style={{ background: COLORS[idx % COLORS.length] }}
                aria-hidden="true"
              />
              <span
                className="truncate text-sm font-bold uppercase tracking-tight text-foreground"
                style={{ fontFamily: "var(--font-heading, system-ui)" }}
              >
                {d.name}
              </span>
            </div>
            <div className="flex items-baseline gap-2 shrink-0">
              <span className="font-data text-xs tabular-nums text-muted-foreground">
                {d.value}/{total}
              </span>
              <span className="font-data text-sm font-bold tabular-nums text-[#e53e00]">
                {d.percentage}%
              </span>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
