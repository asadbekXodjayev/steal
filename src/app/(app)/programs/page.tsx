"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import Image from "next/image";
import { useProgramTemplates } from "@/hooks/useProgramTemplates";
import { Skeleton } from "@/components/ui/skeleton";
import { useI18n } from "@/components/providers/I18nProvider";
import { cn } from "@/lib/utils";
import type { LegendProgram } from "@/data/legend-programs";

const FILTERS = ["ALL", "STRENGTH", "HYPERTROPHY", "FAT LOSS", "HIT"] as const;
type Filter = (typeof FILTERS)[number];

function matchFilter(p: LegendProgram, f: Filter): boolean {
  if (f === "ALL") return true;
  const haystack = [p.name, p.tags.join(" "), p.split].join(" ").toUpperCase();
  if (f === "HIT") return haystack.includes("HIT");
  if (f === "FAT LOSS") return haystack.includes("FAT");
  return haystack.includes(f);
}

function ProgramCard({ program, featured, t }: { program: LegendProgram; featured?: boolean; t: (key: string) => string }) {
  return (
    <Link
      href={`/programs/${program.id}`}
      className={cn(
        "glass glass-hover overflow-hidden flex flex-col",
        featured && "forge-pulse"
      )}
      style={{
        border: featured
          ? "1px solid rgba(194,65,12,0.5)"
          : "1px solid rgba(255,255,255,0.06)",
      }}
    >
      {/* Image — contain so athlete portraits aren't cropped to the face */}
      <div className="relative overflow-hidden bg-[#070707]" style={{ height: 220 }}>
        {program.image ? (
          <Image
            src={program.image}
            alt={program.name}
            fill
            sizes="(max-width: 640px) 100vw, 50vw"
            className="object-contain object-center"
            loading="lazy"
          />
        ) : (
          <div
            className="absolute inset-0"
            style={{
              background: "rgba(0,0,0,0.5)",
              backgroundImage:
                "repeating-linear-gradient(-45deg,rgba(194,65,12,0.04) 0,rgba(194,65,12,0.04) 1px,transparent 1px,transparent 10px)",
            }}
          />
        )}
        {/* Gradient overlay */}
        <div
          className="absolute inset-0"
          style={{
            background: "linear-gradient(to top, rgba(0,0,0,0.7) 0%, transparent 60%)",
          }}
        />
        {featured && (
          <div className="absolute top-2 left-2">
            <span className="tag-pill tag-pill-acc">{t("programs.FEATURED")}</span>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-3 flex flex-col gap-2 flex-1">
        <div>
          <p className="font-data text-[7px] text-[#444] uppercase tracking-widest">
            {program.athleteName}
          </p>
          <h3 className="font-heading text-[14px] font-bold uppercase text-[#e0e0e0] leading-tight mt-0.5">
            {program.name}
          </h3>
        </div>

        <p className="font-data text-[9px] text-[#444] leading-relaxed line-clamp-2">
          {program.recommendedFor}
        </p>

        <div className="flex items-center gap-2 font-data text-[8px] text-[#2a2a2a] uppercase">
          <span>{program.frequency}</span>
          <span>·</span>
          <span>{program.sessionLength}</span>
        </div>

        <div className="flex flex-wrap gap-1">
          {program.tags.slice(0, 2).map((tag) => (
            <span key={tag} className="tag-pill">{tag}</span>
          ))}
        </div>

        <div className="mt-auto pt-2">
          {featured ? (
            <button className="btn-forge w-full h-7 text-[10px]" onClick={(e) => e.preventDefault()}>
              {t("programs.VIEW_PROGRAM")}
            </button>
          ) : (
            <button className="btn-ghost w-full h-7 text-[10px]" onClick={(e) => e.preventDefault()}>
              {t("programs.VIEW_BTN")}
            </button>
          )}
        </div>
      </div>
    </Link>
  );
}

export default function ProgramsPage() {
  const { t } = useI18n();
  const { data: programs, isLoading } = useProgramTemplates();
  const [activeFilter, setActiveFilter] = useState<Filter>("ALL");

  const filtered = useMemo(() => {
    if (!programs) return [];
    return programs.filter((p) => matchFilter(p, activeFilter));
  }, [programs, activeFilter]);

  return (
    <div className="space-y-4 py-4">
      {/* Header */}
      <div className="border-b border-[rgba(255,255,255,0.06)] pb-4 fade-up">
        <h1 className="font-heading text-2xl sm:text-3xl font-black uppercase text-[#f0f0f0] leading-none">
          {t("navbar.PROGRAMS")}
        </h1>
        <div
          className="mt-2"
          style={{ height: 2, width: 32, background: "linear-gradient(90deg,#C2410C,transparent)", boxShadow: "0 0 8px #C2410C" }}
        />
        <p className="font-data text-[9px] text-[#444] uppercase tracking-widest mt-2">
          {programs?.length ?? 0} {t("programs.LEGEND_PROGRAMS_COUNT")}
        </p>
      </div>

      {/* Filter strip */}
      <div className="flex gap-2 overflow-x-auto pb-1 scroll-forge fade-up fade-up-1">
        {FILTERS.map((f) => (
          <button
            key={f}
            onClick={() => setActiveFilter(f)}
            className={cn(
              "shrink-0 px-3 py-1.5 font-data text-[10px] uppercase tracking-widest transition-all border",
              activeFilter === f
                ? "bg-[#C2410C] text-white border-[#C2410C]"
                : "border-[rgba(255,255,255,0.06)] text-[#555] hover:border-[rgba(255,255,255,0.12)] hover:text-[#aaa]"
            )}
          >
            {f}
          </button>
        ))}
      </div>

      {/* Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="skeleton-steal h-64 w-full" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="glass flex flex-col items-center justify-center py-20 gap-3">
          <span className="font-data text-[12px] text-[#333] uppercase tracking-[0.2em]">
            {t("programs.NO_PROGRAMS_MATCH")}
          </span>
          <button
            className="btn-ghost text-[10px] px-4 h-8"
            onClick={() => setActiveFilter("ALL")}
          >
            {t("programs.SHOW_ALL")}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 fade-up fade-up-2">
          {filtered.map((p, i) => (
            <ProgramCard key={p.id} program={p} featured={i === 0} t={t} />
          ))}
        </div>
      )}
    </div>
  );
}
