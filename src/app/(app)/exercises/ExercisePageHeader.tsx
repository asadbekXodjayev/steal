"use client";

import { useI18n } from "@/components/providers/I18nProvider";

interface Props {
  count: number;
}

export function ExercisePageHeader({ count }: Props) {
  const { t } = useI18n();
  return (
    <div className="border-b border-[rgba(255,255,255,0.06)] pb-4 fade-up">
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-data text-[9px] tracking-[0.3em] text-[#525252] uppercase">
              {t("library.FIELD_MANUAL")}
            </span>
            <div className="h-px w-8 bg-[rgba(255,255,255,0.06)]" />
            <span className="font-data text-[8px] text-[#C2410C] tracking-widest uppercase">
              {count > 0 ? t("library.LOADED") : t("library.READY")}
            </span>
          </div>
          <h1 className="font-heading text-2xl sm:text-3xl font-black uppercase tracking-tight text-[#f0f0f0] leading-none">
            {t("library.TITLE")}
          </h1>
          <div
            className="mt-2"
            style={{ height: 2, width: 48, background: "linear-gradient(90deg,#C2410C,transparent)", boxShadow: "0 0 8px #C2410C" }}
          />
        </div>

        <div className="flex flex-col items-end gap-1 shrink-0">
          <span className="font-data text-[9px] tracking-[0.15em] text-[#525252] uppercase">
            {t("library.ENTRIES")}
          </span>
          <span className="font-data text-xl font-bold tabular-nums text-[#C2410C]">
            {count.toLocaleString()}
          </span>
        </div>
      </div>
    </div>
  );
}
