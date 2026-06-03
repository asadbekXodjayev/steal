"use client";

import { useState, useEffect, useRef } from "react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

interface MuscleBalanceProps {
  push: number;
  pull: number;
  legs: number;
  pushVol?: number;
  pullVol?: number;
  legsVol?: number;
  className?: string;
}

const BAR_H = 110;

export function MuscleBalance({ push, pull, legs, pushVol, pullVol, legsVol, className }: MuscleBalanceProps) {
  const { t } = useI18n();
  const [mounted, setMounted] = useState(false);
  const [hovered, setHovered] = useState<"push" | "pull" | "legs" | null>(null);
  const [isVisible, setIsVisible] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const timer = setTimeout(() => setMounted(true), 120);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      ([entry]) => setIsVisible(entry.isIntersecting),
      { threshold: 0.1 }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  const BARS = [
    { key: "push" as const, label: t("progress.PUSH_LABEL"), color: "#22C55E" },
    { key: "pull" as const, label: t("progress.PULL_LABEL"), color: "#C8C8C8" },
    { key: "legs" as const, label: t("progress.LEGS_LABEL"), color: "#16a34a" },
  ];

  const total = push + pull + legs;

  if (total === 0) {
    return (
      <div className={cn("flex items-center justify-center py-12", className)}>
        <span className="stamp text-[10px] tracking-[0.2em] text-[#525252]">{t("progress.NO_SPLIT_DATA")}</span>
      </div>
    );
  }

  const pushPct = Math.round((push / total) * 100);
  const pullPct = Math.round((pull / total) * 100);
  const legsPct = 100 - pushPct - pullPct; // avoids rounding drift

  const pcts: Record<"push" | "pull" | "legs", number> = {
    push: pushPct,
    pull: pullPct,
    legs: legsPct,
  };
  const vols: Record<"push" | "pull" | "legs", number | undefined> = {
    push: pushVol,
    pull: pullVol,
    legs: legsVol,
  };

  const dominant = (["push", "pull", "legs"] as const).reduce(
    (a, b) => (pcts[a] >= pcts[b] ? a : b),
    "push" as "push" | "pull" | "legs"
  );
  const dominantColor = BARS.find((b) => b.key === dominant)!.color;
  const dominantBarLabel = BARS.find((b) => b.key === dominant)!.label;
  const dominantLabel = `${dominantBarLabel} DOMINANT`;

  return (
    <div ref={containerRef} className={cn("relative w-full", className)}>
      <style>{`
        @keyframes neonPulse {
          0%,100% { box-shadow: 0 0 4px var(--nb-c); }
          50%      { box-shadow: 0 0 18px var(--nb-c), 0 0 36px var(--nb-c); }
        }
        @media (prefers-reduced-motion: reduce) {
          .balance-bar { transition: none !important; }
          .balance-bar-dominant { animation: none !important; }
        }
      `}</style>

      {/* Dominant badge */}
      <div
        className="stamp inline-block mb-4"
        style={{
          background: dominantColor,
          color: dominantColor === "#C8C8C8" ? "#050505" : "#fff",
          padding: "2px 7px",
          fontSize: 8,
          letterSpacing: "0.2em",
        }}
      >
        {dominantLabel}
      </div>

      {/* Bars */}
      <div className="flex items-end justify-center gap-8" style={{ height: BAR_H + 56 }}>
        {BARS.map((bar, idx) => {
          const pct = pcts[bar.key];
          const barPx = (pct / 100) * BAR_H;
          const vol = vols[bar.key];
          const isDom = bar.key === dominant;
          const isHov = hovered === bar.key;

          return (
            <div
              key={bar.key}
              className="flex flex-col items-center gap-1.5 relative"
              style={{ alignSelf: "flex-end" }}
              onMouseEnter={() => setHovered(bar.key)}
              onMouseLeave={() => setHovered(null)}
            >
              {/* Volume tooltip */}
              {isHov && vol !== undefined && vol > 0 && (
                <div
                  className="absolute stamp"
                  style={{
                    bottom: "100%",
                    left: "50%",
                    transform: "translateX(-50%)",
                    marginBottom: 6,
                    background: "rgba(5,5,5,0.92)",
                    border: `1px solid ${bar.color}`,
                    padding: "3px 8px",
                    fontSize: 9,
                    color: bar.color,
                    letterSpacing: "0.1em",
                    whiteSpace: "nowrap",
                    zIndex: 20,
                    pointerEvents: "none",
                  }}
                >
                  {vol.toLocaleString()} KG
                </div>
              )}

              {/* Percentage label */}
              <span
                className="stamp"
                style={{
                  fontSize: 13,
                  fontWeight: 800,
                  fontFamily: "var(--font-mono,monospace)",
                  color: isHov || isDom ? bar.color : "rgba(163,163,163,0.55)",
                  transition: "color 0.2s",
                  letterSpacing: "0.04em",
                }}
              >
                {pct}%
              </span>

              {/* Bar container */}
              <div
                style={{
                  width: 50,
                  height: BAR_H,
                  background: "rgba(255,255,255,0.03)",
                  border: "1px solid rgba(255,255,255,0.06)",
                  display: "flex",
                  alignItems: "flex-end",
                  overflow: "hidden",
                  position: "relative",
                  cursor: "pointer",
                }}
              >
              <div
                className={`balance-bar w-full ${isDom ? "balance-bar-dominant" : ""}`}
                style={{
                  height: mounted ? `${barPx}px` : "0px",
                  background: isHov || isDom
                    ? `linear-gradient(0deg, ${bar.color}, ${bar.color}bb)`
                    : `${bar.color}33`,
                  transition: `height 0.65s cubic-bezier(0.34,1.56,0.64,1) ${idx * 90}ms`,
                  ...(isDom
                    ? ({
                        "--nb-c": bar.color,
                        animation: isVisible ? "neonPulse 2.2s ease-in-out infinite" : "none",
                      } as React.CSSProperties)
                    : {}),
                }}
              />
              </div>

              {/* Axis label */}
              <span
                className="stamp"
                style={{
                  fontSize: 9,
                  letterSpacing: "0.15em",
                  color: isHov || isDom ? bar.color : "#525252",
                  transition: "color 0.2s",
                }}
              >
                {bar.label}
              </span>
            </div>
          );
        })}
      </div>

      {/* Segmented balance strip */}
      <div className="mt-3">
        <div className="flex overflow-hidden" style={{ height: 5 }}>
          {BARS.map((bar, idx) => (
            <div
              key={bar.key}
              style={{
                flex: pcts[bar.key],
                height: "100%",
                background: bar.color,
                opacity: bar.key === dominant ? 1 : 0.45,
                transition: `flex 0.55s cubic-bezier(0.34,1.56,0.64,1) ${idx * 80}ms`,
              }}
            />
          ))}
        </div>
        <div className="flex justify-between mt-1">
          {BARS.map((bar) => (
            <span key={bar.key} className="stamp" style={{ fontSize: 7, color: `${bar.color}66`, letterSpacing: "0.1em" }}>
              {bar.label}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
