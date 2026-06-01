"use client";

import Link from "next/link";
import { useState } from "react";
import { usePlans } from "@/hooks/usePlans";
import { PlanCard } from "@/components/plans/PlanCard";
import { TemplateGrid } from "@/components/plans/TemplateGrid";
import { SessionHistory } from "@/components/plans/SessionHistory";
import { Skeleton } from "@/components/ui/skeleton";
import { Plus, Pencil, Zap } from "lucide-react";
import { useI18n } from "@/components/providers/I18nProvider";
import { cn } from "@/lib/utils";

const TABS = [
  { id: "my-plans", labelKey: "plans.MY_PROGRAMS" },
  { id: "sessions", labelKey: "plans.SESSIONS" },
  { id: "templates", labelKey: "plans.TEMPLATES" },
] as const;
type TabId = typeof TABS[number]["id"];

export default function PlansPage() {
  const { t } = useI18n();
  const { data: plans, isLoading } = usePlans();
  const [tab, setTab] = useState<TabId>("my-plans");

  return (
    <div className="space-y-4 py-4">
      {/* Header */}
      <div className="flex items-center justify-between fade-up">
        <div>
          <h1 className="font-heading text-2xl sm:text-3xl font-black uppercase text-[#f0f0f0] leading-none">
            {t("plans.PROGRAMS")}
          </h1>
          <div
            className="mt-2"
            style={{ height: 2, width: 32, background: "linear-gradient(90deg,#C2410C,transparent)", boxShadow: "0 0 8px #C2410C" }}
          />
        </div>
        <div className="flex items-center gap-2">
          <Link
            href="/workout/quick"
            className="btn-ghost h-8 px-3 text-[10px] font-heading flex items-center gap-1.5"
          >
            <Zap className="h-3 w-3" />
            {t("quickWorkout.TITLE")}
          </Link>
          <Link
            href="/plans/create"
            className="btn-forge h-8 px-3 text-[10px] font-heading flex items-center gap-1.5"
          >
            <Pencil className="h-3 w-3" />
            {t("plans.BUILD")}
          </Link>
        </div>
      </div>

      {/* Tab strip */}
      <div className="glass flex overflow-hidden fade-up fade-up-1">
        {TABS.map(({ id, labelKey }) => (
          <button
            key={id}
            onClick={() => setTab(id)}
            className={cn(
              "flex-1 py-2.5 text-center transition-all",
              tab === id
                ? "border-b-2 border-[#C2410C] bg-[rgba(194,65,12,0.06)]"
                : "border-b-2 border-transparent hover:bg-[rgba(255,255,255,0.03)]",
            )}
          >
            <span
              className="font-data text-[9px] tracking-[0.08em] uppercase"
              style={{ color: tab === id ? "#C2410C" : "#2a2a2a" }}
            >
              {t(labelKey)}
            </span>
          </button>
        ))}
      </div>

      {/* Tab content */}
      {tab === "my-plans" && (
        <div className="space-y-3 fade-up fade-up-2">
          {isLoading ? (
            Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="skeleton-steal h-32 w-full" />
            ))
          ) : plans && plans.length > 0 ? (
            plans.map((plan) => <PlanCard key={plan.id} plan={plan} />)
          ) : (
            <div
              className="glass p-8 text-center"
              style={{ border: "1px dashed rgba(255,255,255,0.08)" }}
            >
              <Plus className="mx-auto h-8 w-8 text-[#333]" />
              <p className="mt-2 font-data text-sm text-[#525252]">{t("plans.NO_PROGRAMS")}</p>
              <div className="mt-4 flex items-center justify-center gap-2">
                <Link
                  href="/plans/create"
                  className="btn-forge h-8 px-4 text-[10px] font-heading flex items-center gap-1.5"
                >
                  <Pencil className="h-3 w-3" />
                  {t("plans.BUILD_MANUALLY")}
                </Link>
              </div>
            </div>
          )}
        </div>
      )}

      {tab === "sessions" && (
        <div className="fade-up fade-up-2">
          <SessionHistory />
        </div>
      )}

      {tab === "templates" && (
        <div className="fade-up fade-up-2">
          <TemplateGrid />
        </div>
      )}
    </div>
  );
}
