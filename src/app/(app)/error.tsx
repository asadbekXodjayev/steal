"use client";

import { useEffect } from "react";
import Link from "next/link";
import { AlertTriangle } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";

/**
 * Segment error boundary for all protected (app) routes. Renders within the
 * providers, so i18n is available. Catches render/runtime errors in any page
 * under (app) and offers recovery instead of a white screen.
 */
export default function AppError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const { t } = useI18n();

  useEffect(() => {
    // eslint-disable-next-line no-console
    console.error("[app] route error:", error);
  }, [error]);

  return (
    <div className="mx-auto flex min-h-[60vh] max-w-md flex-col items-center justify-center gap-5 py-16 text-center">
      <div
        className="flex w-full flex-col items-center gap-4 border border-[#ef4444]/40 bg-[#0a0a0a] px-6 py-10"
        style={{ borderLeft: "3px solid #ef4444" }}
      >
        <div className="bg-[#ef4444]/10 p-2">
          <AlertTriangle className="h-5 w-5 text-[#ef4444]" />
        </div>
        <div className="stamp" style={{ fontSize: 14, letterSpacing: "0.3em", color: "#ef4444" }}>
          {t("progress.SIGNAL_LOST")}
        </div>
        <div className="stamp" style={{ fontSize: 10, letterSpacing: "0.15em", color: "#71717A", lineHeight: 1.6 }}>
          {t("progress.SIGNAL_LOST_DESC")}
        </div>
        <div className="mt-2 flex gap-2">
          <button onClick={reset} className="btn-forge h-9 px-5 text-[11px]">
            {t("progress.RETRY")}
          </button>
          <Link
            href="/dashboard"
            className="flex h-9 items-center border border-[#2a2a2a] px-5 font-data text-[11px] uppercase tracking-widest text-ink-mid transition-colors hover:border-[#525252] hover:text-ink-high"
          >
            {t("navbar.DASHBOARD")}
          </Link>
        </div>
      </div>
    </div>
  );
}
