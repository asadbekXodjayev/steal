"use client";

import { ManualPlanForm } from "@/components/plans/ManualPlanForm";
import { useI18n } from "@/components/providers/I18nProvider";

export default function CreatePlanPage() {
  const { t } = useI18n();

  return (
    <div className="mx-auto max-w-2xl space-y-6 py-4">
      <div>
        <h1
          className="text-2xl sm:text-3xl font-extrabold uppercase tracking-tight"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("programs.BUILD_YOUR_OWN")}
        </h1>
        <div className="mt-1 h-0.5 w-12 bg-[#e53e00]" />
        <p className="mt-3 text-sm text-muted-foreground">
          {t("programs.BUILD_DESC")}
        </p>
      </div>
      <ManualPlanForm />
    </div>
  );
}
