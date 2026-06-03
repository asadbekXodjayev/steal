"use client";

import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

const AXES = ["BACK", "CHEST", "SHOULDERS", "ARMS", "LEGS"] as const;

export interface PentagonDataPoint {
  label: string;
  value: number;
  volumeKg: number;
}

interface MuscleRadarProps {
  data: PentagonDataPoint[];
  className?: string;
}

const CX = 170;
const CY = 155;
const R = 90;
const LR = R * 1.3; // label orbit radius

const GRID = [0.25, 0.5, 0.75, 1.0];

function ax(i: number): number {
  return -Math.PI / 2 + (2 * Math.PI * i) / 5;
}
function pt(i: number, scale = 1): [number, number] {
  return [CX + R * scale * Math.cos(ax(i)), CY + R * scale * Math.sin(ax(i))];
}
function polyStr(vals: number[]): string {
  return vals
    .map((v, i) => {
      const s = v / 100;
      return `${CX + R * s * Math.cos(ax(i))},${CY + R * s * Math.sin(ax(i))}`;
    })
    .join(" ");
}
function gridStr(scale: number): string {
  return Array.from({ length: 5 }, (_, i) => pt(i, scale).join(",")).join(" ");
}

// Text anchor and dy per axis (clockwise from top)
const ANCHORS = ["middle", "start", "start", "end", "end"] as const;
const DYS = [-10, 4, 18, 18, 4] as const;
const DXS = [0, 6, 6, -6, -6] as const;

export function MuscleRadar({ data, className }: MuscleRadarProps) {
  const { t } = useI18n();
  const [mounted, setMounted] = useState(false);
  const [hovered, setHovered] = useState<number | null>(null);

  useEffect(() => {
    const timer = setTimeout(() => setMounted(true), 80);
    return () => clearTimeout(timer);
  }, []);

  const ordered = AXES.map((axisLabel) => {
    const d = data.find((p) => p.label === axisLabel);
    return { label: axisLabel, value: d?.value ?? 0, volumeKg: d?.volumeKg ?? 0 };
  });
  const vals = ordered.map((d) => d.value);
  const maxIdx = vals.indexOf(Math.max(...vals));

  const hoveredItem = hovered !== null ? ordered[hovered] : null;

  return (
    <div className={cn("relative w-full", className)}>
      <style>{`
        @keyframes radarIn {
          from { opacity: 0; transform-origin: ${CX}px ${CY}px; transform: scale(0.82); }
          to   { opacity: 1; transform-origin: ${CX}px ${CY}px; transform: scale(1); }
        }
        .radar-fill {
          animation: radarIn 0.44s cubic-bezier(0.23, 1, 0.32, 1) 0.1s both;
        }
        @media (prefers-reduced-motion: reduce) {
          .radar-fill { animation: none; opacity: 1; }
        }
      `}</style>

      {/* ── Mobile: horizontal bars ─────────────────────── */}
      <div className="sm:hidden space-y-2 pt-6">
        <div className="stamp text-[8px] tracking-[0.2em] text-[#525252] mb-3">{t("progress.MUSCLE_DISTRIBUTION_LABEL")}</div>
        {ordered.map((d, i) => (
          <div key={d.label} className="flex items-center gap-3">
            <span className="stamp text-[8px] w-20 text-[#A3A3A3] tracking-[0.1em]">{d.label}</span>
            <div className="flex-1 h-2.5 bg-[rgba(255,255,255,0.04)] overflow-hidden">
              <div
                className="h-full"
                style={{
                  width: mounted ? `${d.value}%` : "0%",
                  background: i === maxIdx ? "linear-gradient(90deg,#22C55E,#16a34a)" : "rgba(200,200,200,0.22)",
                  boxShadow: i === maxIdx ? "0 0 8px rgba(34,197,94,0.4)" : "none",
                  transition: `width 0.55s cubic-bezier(0.23,1,0.32,1) ${i * 70}ms`,
                }}
              />
            </div>
            <span className="stamp text-[10px] w-8 text-right font-bold" style={{ color: i === maxIdx ? "#22C55E" : "#A3A3A3" }}>
              {d.value}%
            </span>
          </div>
        ))}
      </div>

      {/* ── Desktop: SVG pentagon ───────────────────────── */}
      <div className="hidden sm:block relative">
        <div
          className="absolute top-0 left-0 stamp z-10"
          style={{ background: "#FF4D00", color: "#fff", padding: "2px 7px", fontSize: 8, letterSpacing: "0.2em" }}
        >
          {t("progress.MUSCLE_RADAR_BADGE")}
        </div>

        <svg
          viewBox="0 0 340 290"
          width="100%"
          style={{ maxWidth: 360, margin: "0 auto", display: "block" }}
          aria-label="Pentagon muscle radar chart"
          role="img"
        >
          {/* Grid pentagons */}
          {GRID.map((s) => (
            <polygon key={s} points={gridStr(s)} fill="none" stroke="rgba(200,200,200,0.07)" strokeWidth={1} />
          ))}

          {/* Axis lines */}
          {Array.from({ length: 5 }, (_, i) => {
            const [x, y] = pt(i);
            return <line key={i} x1={CX} y1={CY} x2={x} y2={y} stroke="rgba(200,200,200,0.1)" strokeWidth={1} />;
          })}

          {/* Outer dashed reference */}
          <polygon points={gridStr(1)} fill="none" stroke="rgba(200,200,200,0.18)" strokeWidth={1.5} strokeDasharray="3 2" />

          {/* Data polygon */}
          {mounted && (
            <polygon
              className="radar-fill"
              points={polyStr(vals)}
              fill="rgba(34,197,94,0.40)"
              stroke={hovered !== null ? "#22C55E" : "#C8C8C8"}
              strokeWidth={hovered !== null ? 2.5 : 2}
              style={{ transition: "stroke 0.2s, stroke-width 0.2s" }}
            />
          )}

          {/* Axis endpoint dots */}
          {Array.from({ length: 5 }, (_, i) => {
            const [x, y] = pt(i);
            const isMax = i === maxIdx;
            const isHov = hovered === i;
            return (
              <circle
                key={i}
                cx={x}
                cy={y}
                r={isHov ? 5 : isMax ? 4 : 3}
                fill={isMax ? "#22C55E" : "#C8C8C8"}
                opacity={isHov ? 1 : 0.7}
                style={{ transition: "r 0.15s, opacity 0.15s" }}
              />
            );
          })}

          {/* Data value dots */}
          {mounted &&
            vals.map((v, i) => {
              if (v === 0) return null;
              const s = v / 100;
              return (
                <circle
                  key={`v-${i}`}
                  cx={CX + R * s * Math.cos(ax(i))}
                  cy={CY + R * s * Math.sin(ax(i))}
                  r={2.5}
                  fill="#22C55E"
                  opacity={0.9}
                />
              );
            })}

          {/* Axis labels */}
          {AXES.map((label, i) => {
            const [lx, ly] = [CX + LR * Math.cos(ax(i)) + DXS[i], CY + LR * Math.sin(ax(i)) + DYS[i]];
            const isMax = i === maxIdx;
            return (
              <text
                key={label}
                x={lx}
                y={ly}
                textAnchor={ANCHORS[i]}
                fontSize={9}
                fontFamily="var(--font-mono,monospace)"
                fontWeight={700}
                fill={isMax ? "#22C55E" : "rgba(163,163,163,0.85)"}
                style={{ letterSpacing: "0.12em", cursor: "pointer" }}
                onMouseEnter={() => setHovered(i)}
                onMouseLeave={() => setHovered(null)}
              >
                {label}
              </text>
            );
          })}

          {/* Transparent hit areas over axis labels */}
          {AXES.map((_, i) => {
            const [lx, ly] = [CX + LR * Math.cos(ax(i)), CY + LR * Math.sin(ax(i))];
            return (
              <circle
                key={`hit-${i}`}
                cx={lx}
                cy={ly}
                r={18}
                fill="transparent"
                style={{ cursor: "pointer" }}
                onMouseEnter={() => setHovered(i)}
                onMouseLeave={() => setHovered(null)}
              />
            );
          })}

          {/* Tooltip strip at bottom */}
          {hoveredItem && (
              <text
                x={CX}
                y={278}
                textAnchor="middle"
                fontSize={9}
                fontFamily="var(--font-mono,monospace)"
                fill={hovered === maxIdx ? "#22C55E" : "#e5e5e5"}
              >
                {hoveredItem.label} — {hoveredItem.value}{t("progress.OF_VOLUME")}
                {hoveredItem.volumeKg > 0 ? `  ·  ${hoveredItem.volumeKg.toLocaleString()} KG` : ""}
                {hovered === maxIdx ? `  ${t("progress.HIGHEST")}` : ""}
              </text>
          )}

          <circle cx={CX} cy={CY} r={2} fill="rgba(200,200,200,0.25)" />
        </svg>
      </div>
    </div>
  );
}
