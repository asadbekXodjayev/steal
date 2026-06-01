"use client";

import { useMemo } from "react";
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Legend,
} from "recharts";
import type { SessionSet } from "@/types/session";

interface LiftProgressionChartProps {
  sets: SessionSet[];
  topExerciseIds: string[];
  exerciseNames?: Record<string, string>;
}

const LINE_COLORS = ["#e53e00", "#888888", "#444444"] as const;

interface ChartRow {
  date: string;
  ts: number;
  [exerciseKey: string]: string | number;
}

export function LiftProgressionChart({
  sets,
  topExerciseIds,
  exerciseNames,
}: LiftProgressionChartProps) {
  const { rows, keys } = useMemo(() => {
    if (sets.length === 0 || topExerciseIds.length === 0) {
      return { rows: [], keys: [] as string[] };
    }

    const ids = topExerciseIds.slice(0, 3);
    const dateMap = new Map<string, ChartRow>();

    for (const id of ids) {
      const exerciseSets = sets
        .filter((s) => s.exercise === id)
        .sort(
          (a, b) =>
            new Date(a.created).getTime() - new Date(b.created).getTime(),
        );

      // Pick best (max weight) per day
      const bestPerDay = new Map<string, number>();
      for (const s of exerciseSets) {
        const day = new Date(s.created).toISOString().slice(0, 10);
        const cur = bestPerDay.get(day) ?? 0;
        if (s.weight > cur) bestPerDay.set(day, s.weight);
      }

      for (const [day, weight] of bestPerDay) {
        const ts = new Date(day).getTime();
        const label = new Date(day).toLocaleDateString("en-US", {
          month: "short",
          day: "numeric",
        });
        const existing = dateMap.get(day);
        if (existing) {
          existing[id] = weight;
        } else {
          dateMap.set(day, { date: label, ts, [id]: weight });
        }
      }
    }

    const rowsArr = Array.from(dateMap.values()).sort((a, b) => a.ts - b.ts);
    return { rows: rowsArr, keys: ids };
  }, [sets, topExerciseIds]);

  if (rows.length === 0) {
    return (
      <div className="border border-border bg-card p-6 text-center">
        <p className="font-data text-sm uppercase tracking-wider text-muted-foreground">
          Log sessions to track lift progression.
        </p>
      </div>
    );
  }

  return (
    <div className="border border-border bg-card p-4 w-full overflow-hidden">
      <div className="h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={rows} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" vertical={false} />
            <XAxis
              dataKey="date"
              tick={{ fontSize: 9, fill: "#888888" }}
              axisLine={{ stroke: "#2a2a2a" }}
              tickLine={false}
              interval="preserveStartEnd"
            />
            <YAxis
              tick={{ fontSize: 9, fill: "#888888" }}
              axisLine={{ stroke: "#2a2a2a" }}
              tickLine={false}
              tickFormatter={(v: number) => `${v}kg`}
              width={32}
            />
            <Tooltip
              contentStyle={{
                background: "#111111",
                border: "1px solid #2a2a2a",
                borderRadius: "2px",
                fontSize: "11px",
                color: "#f0f0f0",
              }}
              labelStyle={{ color: "#888888", textTransform: "uppercase" }}
              formatter={(value, name) => [
                `${Number(value ?? 0)}kg`,
                exerciseNames?.[String(name)] ?? String(name),
              ]}
            />
            <Legend
              wrapperStyle={{
                fontSize: "10px",
                textTransform: "uppercase",
                letterSpacing: "0.1em",
                color: "#888888",
                paddingTop: "8px",
              }}
              formatter={(value: string) => exerciseNames?.[value] ?? value}
            />
            {keys.map((id, i) => (
              <Line
                key={id}
                type="monotone"
                dataKey={id}
                stroke={LINE_COLORS[i] ?? "#444444"}
                strokeWidth={2}
                dot={{ r: 3, fill: LINE_COLORS[i] ?? "#444444", strokeWidth: 0 }}
                activeDot={{ r: 5 }}
                connectNulls
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
