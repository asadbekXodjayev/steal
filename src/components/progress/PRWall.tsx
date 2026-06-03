"use client";

import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { Card } from "@/components/ui/card";
import { Dumbbell, Trophy, BarChart3 } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

interface PRRecord {
  exerciseName: string;
  weight: number;
  reps: number;
  date: string;
  estimated1RM: number;
}

interface PRWallProps {
  prs: PRRecord[];
  className?: string;
}

export function PRWall({ prs, className }: PRWallProps) {
  const [mounted, setMounted] = useState(false);
  const { t } = useI18n();

  useEffect(() => {
    const timer = setTimeout(() => setMounted(true), 180);
    return () => clearTimeout(timer);
  }, []);

  const sortedPRs = [...prs]
    .sort((a, b) => b.estimated1RM - a.estimated1RM)
    .slice(0, 5);

  if (sortedPRs.length === 0) {
    return (
      <Card className={cn("glass-card p-8 text-center", className)}>
        <div className="stamp text-xs tracking-widest text-[#525252]">{t("progress.PERSONAL_RECORDS_LABEL")}</div>
        <p className="text-[#A3A3A3] mt-3 text-sm">{t("progress.NO_PRS_FORGE")}</p>
      </Card>
    );
  }

  return (
    <>
      <style>{`
        @keyframes sparkPulse {
          0%, 100% { opacity: 0.7; transform: scale(0.9); }
          50% { opacity: 1; transform: scale(1.2) rotate(-8deg); }
        }
        .spark-anim { animation: sparkPulse 1.4s ease-in-out infinite; }
        @media (prefers-reduced-motion: reduce) { .spark-anim { animation: none; } }
      `}</style>

      <div className={cn("grid grid-cols-1 md:grid-cols-2 gap-4", className)}>
        {sortedPRs.map((pr, i) => {
          const Icon = i === 0 ? Trophy : i === 1 ? BarChart3 : Dumbbell;
          const formatDate = (dateStr: string) => {
            const d = new Date(dateStr);
            return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }).toUpperCase();
          };

          return (
            <Card
              key={pr.exerciseName}
              className="glass-card group relative overflow-hidden p-5 transition-colors"
            >
              {mounted && i < 2 && (
                <div className="absolute top-3 right-3 spark-anim">
                  <div
                    className="w-3 h-3 rounded-full"
                    style={{ background: "#22C55E", boxShadow: "0 0 14px #22C55E, 0 0 24px #22C55E" }}
                  />
                </div>
              )}

              <div className="flex justify-between items-start">
                <div>
                  <Icon className="h-6 w-6 text-[#22C55E] mb-2" />
                  <div className="stamp text-[10px] tracking-[0.2em] text-[#C8C8C8]">{t("progress.PERSONAL_RECORD_CARD")}</div>
                  <p className="font-bold text-lg text-[#E5E5E5] mt-1 uppercase tracking-tight">
                    {pr.exerciseName}
                  </p>
                </div>

                <div className="text-right">
                  <div className="flex items-end gap-1 justify-end">
                    <span className="text-4xl font-mono font-bold text-[#22C55E] tabular-nums leading-none">
                      {pr.weight}
                    </span>
                    <span className="text-sm font-mono text-[#22C55E]/70 mb-1">KG</span>
                  </div>
                  <span className="text-xs text-[#A3A3A3] block">× {pr.reps} {t("progress.REPS_LABEL")}</span>
                  <span className="text-[10px] font-mono text-[#525252] block mt-0.5">
                    e1RM {pr.estimated1RM} kg
                  </span>
                </div>
              </div>

              <div className="text-[10px] text-[#666666] mt-6 pt-3 border-t border-white/10 flex justify-between items-center">
                <span>{formatDate(pr.date)}</span>
                <span className="text-[#22C55E] font-medium">{t("progress.PERSONAL_BEST")}</span>
              </div>

              <div
                className="absolute inset-0 pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity"
                style={{ background: "radial-gradient(circle at 40% 20%, rgba(34,197,94,0.12), transparent 70%)" }}
              />
            </Card>
          );
        })}
      </div>
    </>
  );
}
