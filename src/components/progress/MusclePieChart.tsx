"use client";

import { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface MuscleSlice {
  muscle: string;
  percentage: number;
  volume: number;
  color: string;
}

interface MusclePieChartProps {
  data: MuscleSlice[];
}

// Color palette for muscle groups
const MUSCLE_COLORS = [
  "#e53e00", // Orange - Chest
  "#10b981", // Green - Back
  "#3b82f6", // Blue - Shoulders
  "#f59e0b", // Amber - Biceps
  "#ef4444", // Red - Triceps
  "#8b5cf6", // Purple - Quads
  "#ec4899", // Pink - Hamstrings
  "#06b6d4", // Cyan - Glutes
  "#84cc16", // Lime - Calves
  "#f97316", // Orange-500 - Traps
  "#6366f1", // Indigo - Abs
  "#6b7280", // Gray - Other
];

export function MusclePieChart({ data }: MusclePieChartProps) {
  const { t } = useI18n();
  const [hoveredSlice, setHoveredSlice] = useState<string | null>(null);

  const totalVolume = useMemo(() => {
    return data.reduce((sum, d) => sum + d.volume, 0);
  }, [data]);

  // Calculate pie chart slices using SVG paths
  const slices = useMemo(() => {
    if (data.length === 0 || totalVolume === 0) return [];

    let currentAngle = -90; // Start from top
    const radius = 80;
    const center = 100;

    return data.map((slice, index) => {
      const sliceAngle = (slice.percentage / 100) * 360;
      const startAngle = currentAngle;
      const endAngle = currentAngle + sliceAngle;
      currentAngle = endAngle;

      // Convert angles to radians
      const startRad = (startAngle * Math.PI) / 180;
      const endRad = (endAngle * Math.PI) / 180;

      // Calculate path coordinates
      const x1 = center + radius * Math.cos(startRad);
      const y1 = center + radius * Math.sin(startRad);
      const x2 = center + radius * Math.cos(endRad);
      const y2 = center + radius * Math.sin(endRad);

      // Large arc flag for angles > 180
      const largeArcFlag = sliceAngle > 180 ? 1 : 0;

      // Create SVG path
      const pathData = `
        M ${center} ${center}
        L ${x1} ${y1}
        A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2}
        Z
      `;

      return {
        ...slice,
        path: pathData,
        isHovered: hoveredSlice === slice.muscle,
      };
    });
  }, [data, totalVolume, hoveredSlice]);

  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center py-16">
        <div className="text-center">
          <div className="stamp text-[12px] text-[#525252] tracking-widest">{t("progress.NO_DATA_DISTRIBUTION")}</div>
          <div className="stamp mt-2 text-[9px] text-[#71717A]">{t("progress.LOG_WORKOUTS_DISTRIBUTION")}</div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col lg:flex-row items-center justify-center gap-6">
      {/* Pie Chart */}
      <div className="relative w-full max-w-[200px] mx-auto lg:mx-0">
        <svg width="100%" viewBox="0 0 200 200" style={{ display: "block" }}>
          {slices.map((slice) => (
            <path
              key={slice.muscle}
              d={slice.path}
              fill={slice.color}
              stroke="#0a0a0a"
              strokeWidth="2"
              className={cn(
                "transition-opacity cursor-pointer",
                slice.isHovered ? "opacity-100" : "opacity-90"
              )}
              onMouseEnter={() => setHoveredSlice(slice.muscle)}
              onMouseLeave={() => setHoveredSlice(null)}
            />
          ))}
          {/* Center circle for donut effect */}
          <circle cx="100" cy="100" r="40" fill="#0a0a0a" />
          {/* Total volume in center */}
          <text
            x="100"
            y="95"
            textAnchor="middle"
            className="fill-[#e5e5e5] text-[10px] font-bold"
            style={{ fontFamily: "var(--font-mono, monospace)" }}
          >
            {t("progress.TOTAL_CENTER")}
          </text>
          <text
            x="100"
            y="110"
            textAnchor="middle"
            className="fill-[#e53e00] text-[12px] font-bold"
            style={{ fontFamily: "var(--font-mono, monospace)" }}
          >
            {Math.round(totalVolume / 1000)}K
          </text>
        </svg>
      </div>

      {/* Legend */}
      <div className="flex flex-col gap-2 max-w-[200px]">
        {data.map((slice) => (
          <div
            key={slice.muscle}
            className={cn(
              "flex items-center gap-2 cursor-pointer transition-opacity",
              hoveredSlice && hoveredSlice !== slice.muscle ? "opacity-40" : "opacity-100"
            )}
            onMouseEnter={() => setHoveredSlice(slice.muscle)}
            onMouseLeave={() => setHoveredSlice(null)}
          >
            <div
              className="w-3 h-3 shrink-0"
              style={{ backgroundColor: slice.color }}
            />
            <div className="flex-1 min-w-0">
              <div className="stamp text-[9px] text-[#e5e5e5] tracking-[0.08em] truncate">
                {slice.muscle}
              </div>
              <div className="stamp text-[8px] text-[#71717A]">
                {slice.percentage.toFixed(1)}% • {Math.round(slice.volume / 1000)}K kg
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
