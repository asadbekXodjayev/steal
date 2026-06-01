"use client";

import type { ReactNode } from "react";
import { useI18n } from "@/components/providers/I18nProvider";

export default function AuthLayout({ children }: { children: ReactNode }) {
  const { t } = useI18n();

  return (
    <div className="relative flex min-h-dvh items-center justify-center bg-[#050505] px-4 py-12">
      {/* Ambient barbell plate rings */}
      <div
        aria-hidden="true"
        className="pointer-events-none fixed right-[-140px] top-[10%] h-[480px] w-[480px] rounded-full opacity-50"
        style={{
          border: "72px solid rgba(139,0,0,0.045)",
          boxShadow:
            "0 0 0 22px rgba(139,0,0,0.025), 0 0 0 44px rgba(139,0,0,0.012)",
        }}
      />
      <div
        aria-hidden="true"
        className="pointer-events-none fixed bottom-[6%] left-[-110px] h-[320px] w-[320px] rounded-full opacity-40"
        style={{
          border: "50px solid rgba(139,0,0,0.035)",
          boxShadow: "0 0 0 18px rgba(139,0,0,0.018)",
        }}
      />

      {/* Tactical panel */}
      <div className="panel has-corner relative w-full max-w-md overflow-hidden">
        {/* Diagonal rust stripe on left edge */}
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-y-0 left-0 w-[3px]"
          style={{
            background:
              "linear-gradient(180deg, var(--rust) 0%, rgba(185,28,28,0.3) 60%, transparent 100%)",
          }}
        />

        {/* Header block */}
        <div className="border-b border-[#1a1a1a] px-4 pb-6 pt-8 sm:px-8">
          <p
            className="stamp mb-2"
            style={{ color: "var(--ink-dim)", letterSpacing: "0.3em" }}
          >
            {t("authLayout.ACCESS_PORTAL")}
          </p>
          <h1
            className="font-heading text-4xl font-black uppercase leading-none tracking-tight text-[#E5E5E5] sm:text-6xl"
            style={{ fontFamily: "var(--font-heading, system-ui)" }}
          >
            {t("authLayout.STEAL")}
          </h1>
          <p className="stamp mt-2" style={{ color: "var(--rust)", letterSpacing: "0.25em" }}>
            {t("authLayout.FORGES_STEEL")}
          </p>
        </div>

        {/* Page content */}
        <div className="px-4 py-6 sm:px-8">{children}</div>

        {/* Footer stamp */}
        <div className="border-t border-[#1a1a1a] px-4 py-3 sm:px-8">
          <p className="stamp" style={{ color: "var(--ink-dim)", fontSize: "9px", letterSpacing: "0.22em" }}>
            {t("authLayout.FOOTER")}
          </p>
        </div>
      </div>
    </div>
  );
}
