"use client";

import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface DonutBreakdownProps {
  push: number;
  pull: number;
  legs: number;
  className?: string;
}

// Half-donut: arcs drawn on the top half of a circle (180 degrees)
// Each arc occupies a proportional slice of the 180°

interface ArcProps {
  cx: number;
  cy: number;
  r: number;
  startAngle: number; // degrees, 0 = right
  endAngle: number;
  color: string;
  strokeWidth: number;
}

function describeArc({ cx, cy, r, startAngle, endAngle, color, strokeWidth }: ArcProps) {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const x1 = cx + r * Math.cos(toRad(startAngle));
  const y1 = cy + r * Math.sin(toRad(startAngle));
  const x2 = cx + r * Math.cos(toRad(endAngle));
  const y2 = cy + r * Math.sin(toRad(endAngle));
  const largeArc = endAngle - startAngle > 180 ? 1 : 0;

  return {
    d: `M ${x1} ${y1} A ${r} ${r} 0 ${largeArc} 1 ${x2} ${y2}`,
    color,
    strokeWidth,
  };
}

export function DonutBreakdown({ push, pull, legs, className }: DonutBreakdownProps) {
  const { t } = useI18n();

  const SEGMENTS = [
    { key: "push" as const, label: t("progress.PUSH_LABEL"), color: "#B91C1C" },
    { key: "pull" as const, label: t("progress.PULL_LABEL"), color: "#EA580C" },
    { key: "legs" as const, label: t("progress.LEGS_LABEL"), color: "#C2410C" },
  ];

  type SegmentKey = (typeof SEGMENTS)[number]["key"];

  const total = push + pull + legs;
  const values: Record<SegmentKey, number> = { push, pull, legs };

  const size = 180;
  const cx = size / 2;
  const cy = size / 2; // bottom of the half
  const r = 65;
  const strokeWidth = 18;

  // Half-donut spans from 180° to 360° (the top half when SVG y is flipped)
  // We'll use 180° to 0° going counterclockwise = the bottom of screen
  // Actually: standard half-donut: start=180deg, end=0deg, sweeping clockwise
  // In SVG: angles go clockwise from 3-o'clock (0deg)
  // We want the donut arch on the BOTTOM of a viewBox, so center at top
  // Simpler: center at (cx, cy_full) and render from 180->360 (bottom half arc)
  const startDeg = 180;
  const totalSpan = 180; // half circle

  let cursor = startDeg;
  const arcs = SEGMENTS.map((seg) => {
    const frac = total > 0 ? values[seg.key] / total : 1 / 3;
    const span = frac * totalSpan;
    const arc = describeArc({
      cx,
      cy,
      r,
      startAngle: cursor,
      endAngle: cursor + span,
      color: seg.color,
      strokeWidth,
    });
    cursor += span;
    return { ...arc, key: seg.key, label: seg.label, value: values[seg.key] };
  });

  const svgHeight = cy + r + strokeWidth / 2 + 4;

  return (
    <div className={cn("flex flex-col items-center gap-3", className)}>
      <div className="relative" style={{ width: size, height: svgHeight }}>
        <svg
          width={size}
          height={svgHeight}
          style={{ display: "block", overflow: "visible" }}
          aria-label={`Movement split: Push ${push}, Pull ${pull}, Legs ${legs}`}
          role="img"
        >
          {/* Track */}
          <path
            d={`M ${cx - r} ${cy} A ${r} ${r} 0 0 1 ${cx + r} ${cy}`}
            fill="none"
            stroke="#1a1a1a"
            strokeWidth={strokeWidth}
            strokeLinecap="square"
          />

          {/* Colored arcs */}
          {arcs.map((arc) => (
            <path
              key={arc.key}
              d={arc.d}
              fill="none"
              stroke={arc.color}
              strokeWidth={arc.strokeWidth}
              strokeLinecap="square"
            />
          ))}
        </svg>

        {/* Center label */}
        <div
          className="absolute"
          style={{
            left: "50%",
            bottom: 4,
            transform: "translateX(-50%)",
            textAlign: "center",
          }}
        >
          <div
            className="stamp"
            style={{
              fontSize: 9,
              letterSpacing: "0.2em",
              color: "var(--ink-dim)",
            }}
          >
            {t("progress.SPLIT_LABEL")}
          </div>
          <div
            style={{
              fontFamily: "var(--font-mono, monospace)",
              fontSize: 18,
              fontWeight: 800,
              color: "var(--ink-high)",
              lineHeight: 1,
              letterSpacing: "-0.03em",
              fontVariantNumeric: "tabular-nums",
            }}
          >
            {total > 0 ? `${Math.round((push / total) * 100)}%` : "—"}
          </div>
        </div>
      </div>

      {/* Legend */}
      <div className="flex items-center gap-4">
        {arcs.map((arc) => (
          <div key={arc.key} className="flex items-center gap-1.5">
            <span
              style={{
                display: "inline-block",
                width: 8,
                height: 8,
                background: arc.color,
                flexShrink: 0,
              }}
            />
            <span
              style={{
                fontFamily: "var(--font-mono, monospace)",
                fontSize: 9,
                textTransform: "uppercase",
                color: "var(--ink-low)",
                letterSpacing: "0.1em",
              }}
            >
              {arc.label}
            </span>
            {total > 0 && (
              <span
                style={{
                  fontFamily: "var(--font-mono, monospace)",
                  fontSize: 9,
                  color: "var(--ink-mid)",
                  fontVariantNumeric: "tabular-nums",
                }}
              >
                {Math.round((arc.value / total) * 100)}%
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
