"use client";

import { useState } from "react";
import { BrandNoiseOverlay } from "@/components/layout/BrandNoiseOverlay";
import { ChevronRight, Calendar, Clock, Flame, Loader2, AlertTriangle } from "lucide-react";
import { cn } from "@/lib/utils";
import { type LegendProgram } from "@/data/legend-programs";
import { ProgramDetail } from "@/components/programs/ProgramDetail";
import { useProgramTemplates } from "@/hooks/useProgramTemplates";
import { useI18n } from "@/components/providers/I18nProvider";

export default function ProgramsPage() {
  const { t } = useI18n();
  const { data: programs, isLoading, isError } = useProgramTemplates();
  const [selectedProgram, setSelectedProgram] = useState<LegendProgram | null>(null);

  if (selectedProgram) {
    return (
      <ProgramDetail
        program={selectedProgram}
        onBack={() => setSelectedProgram(null)}
      />
    );
  }

  return (
    <div className="page-enter space-y-8 py-6">
      {/* Header */}
      <div className="relative">
        <div className="flex items-center gap-4">
          <div className="h-0.5 w-12 bg-[#e53e00]" />
          <h1
            className="text-3xl sm:text-4xl font-black uppercase tracking-tight text-[#e5e5e5]"
            style={{ fontFamily: "var(--font-heading, system-ui)" }}
          >
            {t("programs.LEGEND_TITLE")}
          </h1>
        </div>
        <p className="mt-2 max-w-xl text-sm text-[#71717A]">
          {t("programs.LEGEND_SUBTITLE")}
        </p>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex flex-col items-center justify-center py-24 gap-4">
          <Loader2 className="h-6 w-6 animate-spin text-[#e53e00]" />
          <p className="font-data text-[10px] uppercase tracking-widest text-[#525252]">
            {t("programs.LOADING")}
          </p>
        </div>
      )}

      {/* Error */}
      {isError && (
        <div className="border border-[#e53e00]/30 bg-[#0a0a0a] p-6 flex items-start gap-4">
          <AlertTriangle className="h-5 w-5 shrink-0 text-[#e53e00] mt-0.5" />
          <div>
            <p className="font-data text-[10px] font-bold uppercase tracking-widest text-[#e53e00] mb-1">
              {t("programs.LOAD_ERROR")}
            </p>
            <p className="font-data text-[9px] text-[#71717A]">
              {t("programs.LOAD_ERROR_DESC")}
            </p>
          </div>
        </div>
      )}

      {/* Empty */}
      {!isLoading && !isError && programs?.length === 0 && (
        <div className="border border-[#2a2a2a] bg-[#0a0a0a] p-12 text-center">
          <p className="font-data text-[10px] uppercase tracking-widest text-[#525252]">
            {t("programs.NO_PROGRAMS_FOUND")}
          </p>
        </div>
      )}

      {/* Programs Grid */}
      {programs && programs.length > 0 && (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {programs.map((program) => (
              <button
                key={program.id}
                onClick={() => setSelectedProgram(program)}
                className="group relative flex flex-col bg-[#0a0a0a] transition-all duration-150 overflow-hidden border border-[#2a2a2a] hover:border-[#e53e00]/50 hover:-translate-y-0.5 text-left"
              >
                {/* Image — contain so athlete portraits aren't cropped to the face */}
                <div className="relative aspect-[4/3] w-full overflow-hidden bg-[#070707]">
                  <img
                    src={program.image}
                    alt={program.name}
                    className="absolute inset-0 w-full h-full object-contain object-center transition-transform duration-300 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-[#0a0a0a] via-[#0a0a0a]/40 to-transparent" />

                  <div className="absolute right-3 top-3 z-20 opacity-0 transition-opacity group-hover:opacity-100">
                    <div className="bg-[#e53e00] p-1.5">
                      <Flame className="h-3 w-3 text-white" />
                    </div>
                  </div>
                </div>

                <BrandNoiseOverlay />

                {/* Content */}
                <div className="relative z-10 flex-1 p-5">
                  <p className="font-data text-[10px] font-semibold uppercase tracking-widest text-[#e53e00] mb-1">
                    {program.athleteName}
                  </p>
                  <h3
                    className="text-lg font-black uppercase leading-tight tracking-tight text-[#E5E5E5]"
                    style={{ fontFamily: "var(--font-heading, system-ui)" }}
                  >
                    {program.name}
                  </h3>
                  <p className="mt-2 text-sm leading-relaxed text-[#71717A] line-clamp-2">
                    {program.philosophy}
                  </p>
                  <div className="mt-3 flex flex-wrap gap-1">
                    {program.tags.slice(0, 3).map((tag) => (
                      <span
                        key={tag}
                        className="bg-[#1a1a1a] px-2 py-0.5 font-data text-[9px] uppercase tracking-widest text-[#71717A]"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Footer stats */}
                <div className="border-t border-[#2a2a2a] p-4">
                  <div className="grid grid-cols-2 gap-3">
                    <div className="flex items-center gap-2">
                      <Calendar className="h-3 w-3 text-[#e53e00]" />
                      <div>
                        <p className="font-data text-[8px] uppercase tracking-widest text-[#525252]">{t("programs.FREQUENCY")}</p>
                        <p className="font-data text-[10px] text-[#a3a3a3]">{program.frequency}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Clock className="h-3 w-3 text-[#e53e00]" />
                      <div>
                        <p className="font-data text-[8px] uppercase tracking-widest text-[#525252]">{t("programs.SESSION")}</p>
                        <p className="font-data text-[10px] text-[#a3a3a3]">{program.sessionLength}</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* View button */}
                <div className="border-t border-[#2a2a2a] p-3">
                  <div className="flex items-center justify-between">
                    <span className="font-data text-[10px] uppercase tracking-widest text-[#e53e00]">
                      {t("programs.VIEW_PROGRAM")}
                    </span>
                    <ChevronRight className="h-3 w-3 text-[#e53e00] transition-transform group-hover:translate-x-1" />
                  </div>
                </div>
              </button>
            ))}
          </div>

          {/* Comparison table */}
          <div className="mt-12">
            <div className="flex items-center gap-4 mb-6">
              <div className="h-px flex-1 bg-[#2a2a2a]" />
              <span className="font-data text-[10px] uppercase tracking-widest text-[#71717A]">
                {t("programs.COMPARISON")}
              </span>
              <div className="h-px flex-1 bg-[#2a2a2a]" />
            </div>

            <div className="overflow-x-auto border border-[#2a2a2a] bg-[#0a0a0a]">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-[#2a2a2a]">
                    <th className="p-3 font-data text-[9px] uppercase tracking-widest text-[#71717A]">{t("programs.TABLE_PROGRAM")}</th>
                    <th className="p-3 font-data text-[9px] uppercase tracking-widest text-[#71717A]">{t("programs.TABLE_DAYS_WK")}</th>
                    <th className="p-3 font-data text-[9px] uppercase tracking-widest text-[#71717A]">{t("programs.TABLE_SPLIT")}</th>
                    <th className="p-3 font-data text-[9px] uppercase tracking-widest text-[#71717A]">{t("programs.TABLE_BEST_FOR")}</th>
                  </tr>
                </thead>
                <tbody>
                  {programs.map((program, idx) => (
                    <tr
                      key={program.id}
                      className={cn(
                        "border-b border-[#1a1a1a] hover:bg-[#111111] transition-colors cursor-pointer",
                        idx === programs.length - 1 && "border-b-0",
                      )}
                      onClick={() => setSelectedProgram(program)}
                    >
                      <td className="p-3">
                        <span className="font-data text-[10px] uppercase tracking-widest text-[#e5e5e5]">
                          {program.athleteName}
                        </span>
                      </td>
                      <td className="p-3">
                        <span className="font-data text-[10px] text-[#a3a3a3]">
                          {program.frequency.split(" ")[0]}
                        </span>
                      </td>
                      <td className="p-3 max-w-[200px]">
                        <span className="font-data text-[9px] text-[#71717A] line-clamp-1">
                          {program.split}
                        </span>
                      </td>
                      <td className="p-3 max-w-[200px]">
                        <span className="font-data text-[9px] text-[#71717A] line-clamp-1">
                          {program.recommendedFor}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
