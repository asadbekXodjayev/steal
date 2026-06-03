"use client";

import Link from "next/link";
import { useState, useMemo } from "react";
import { Button } from "@/components/ui/button";
import { PlanImageCarousel } from "@/components/programs/PlanImageCarousel";
import type { WorkoutPlan } from "@/types/plan";
import { formatRelativeDate } from "@/lib/utils";
import { Calendar, Target, Trash2, X, Play, Pause } from "lucide-react";
import { toast } from "sonner";
import { useDeletePlan, useUpdatePlanStatus } from "@/hooks/usePlans";
import { useI18n } from "@/components/providers/I18nProvider";

interface PlanCardProps {
  plan: WorkoutPlan;
}

export function PlanCard({ plan }: PlanCardProps) {
  const { t } = useI18n();
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [isTogglingStatus, setIsTogglingStatus] = useState(false);
  const deletePlan = useDeletePlan();
  const updateStatus = useUpdatePlanStatus();

  // Parse imageUrls from the plan's JSON field
  const imageUrls = useMemo(() => {
    if (!plan.imageUrls) return [];
    try {
      const parsed = typeof plan.imageUrls === 'string' 
        ? JSON.parse(plan.imageUrls) 
        : plan.imageUrls;
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }, [plan.imageUrls]);

  const statusColors: Record<string, string> = {
    active: "bg-[#10B981]/10 text-[#10B981]",
    completed: "bg-[#71717A]/10 text-[#71717A]",
    paused: "bg-[#F59E0B]/10 text-[#F59E0B]",
    archived: "bg-[#71717A]/10 text-[#71717A]",
  };

  const statusColor = plan.status ? statusColors[plan.status] : "bg-[#71717A]/10 text-[#71717A]";

  const handleDelete = async () => {
    try {
      await deletePlan.mutateAsync(plan.id);
      toast.success(t("plans.DELETED"));
      setShowDeleteConfirm(false);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      toast.error(`${t("plans.DELETE_FAILED")} ${msg}`);
    }
  };

  const handleToggleStatus = async () => {
    setIsTogglingStatus(true);
    try {
      const newStatus = plan.status === "active" ? "paused" : "active";
      await updateStatus.mutateAsync({
        planId: plan.id,
        status: newStatus,
      });
      toast.success(
        newStatus === "active"
          ? t("plans.RESUMED")
          : t("plans.PAUSED")
      );
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      toast.error(`${t("plans.UPDATE_FAILED")} ${msg}`);
    } finally {
      setIsTogglingStatus(false);
    }
  };

  const isActive = plan.status === "active";

  return (
    <div className="relative">
      <Link href={`/plans/${plan.id}`}>
        <div className={`${isActive ? "glass-acc forge-pulse" : "glass glass-hover"} overflow-hidden`}>
          {/* Image Carousel */}
          {imageUrls.length > 0 && (
            <PlanImageCarousel
              imageUrls={imageUrls}
              className="aspect-video"
              autoSlideInterval={5000}
              showNavigation={false}
              showIndicators={true}
            />
          )}
          <div className="p-4 space-y-3">
            <div className="flex items-start justify-between gap-2">
              <div>
                {isActive && (
                  <span className="tag-pill tag-pill-acc text-[8px] mb-1.5 block w-fit">{t("plans.ACTIVE_TAG")}</span>
                )}
                <h3 className="font-heading text-lg font-black uppercase text-[#f0f0f0] leading-tight">
                  {plan.title}
                </h3>
                <span className="font-data text-[8px] text-[#444] uppercase mt-0.5 block">
                  {plan.goalType?.replace(/_/g, " ")} · {t("plans.WEEK")} {plan.currentWeek}/{plan.durationWeeks}
                </span>
              </div>
              <div className="flex items-center gap-1.5">
                <button
                  className="btn-ghost h-7 w-7 flex items-center justify-center"
                  onClick={(e) => { e.preventDefault(); handleToggleStatus(); }}
                  disabled={isTogglingStatus}
                >
                  {isActive ? <Pause className="h-3.5 w-3.5" /> : <Play className="h-3.5 w-3.5" />}
                </button>
              </div>
            </div>
            {plan.description && (
              <p className="font-data text-[10px] text-[#444] line-clamp-2">{plan.description}</p>
            )}
            {/* Progress bar */}
            <div className="prog-bar">
              <div
                className="prog-fill"
                style={{ width: `${Math.round((plan.currentWeek / plan.durationWeeks) * 100)}%` }}
              />
            </div>
            <div className="flex gap-2 pt-1">
              <button className="btn-forge flex-1 h-7 text-[10px]" onClick={(e) => e.preventDefault()}>
                {t("plans.CONTINUE")}
              </button>
              <button className="btn-ghost h-7 px-3 text-[10px]" onClick={(e) => e.preventDefault()}>
                {t("plans.DETAILS")}
              </button>
            </div>
          </div>
        </div>
      </Link>

      {/* Delete Button */}
      <Button
        variant="ghost"
        size="icon"
        className="absolute -right-2 -top-2 h-7 w-7 rounded-full bg-[#8B0000] text-white hover:bg-[#9F1239]"
        onClick={(e) => {
          e.preventDefault();
          setShowDeleteConfirm(true);
        }}
      >
        <Trash2 className="h-3.5 w-3.5" />
      </Button>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4">
          <div className="relative w-full max-w-sm border border-[#8B0000]/50 bg-[#0a0a0a] p-6">
            <button
              className="absolute right-3 top-3 text-[#71717A] hover:text-[#E5E5E5]"
              onClick={() => setShowDeleteConfirm(false)}
            >
              <X className="h-4 w-4" />
            </button>
            <h3 className="text-lg font-bold uppercase tracking-tight text-[#E5E5E5]">
              {t("plans.DELETE_TITLE")}
            </h3>
            <p className="mt-2 text-sm text-[#71717A]">
              {t("plans.DELETE_CONFIRM")} <span className="text-[#E5E5E5]">{plan.title}</span>? {t("plans.DELETE_WARNING")}
            </p>
            <div className="mt-6 flex gap-3">
              <Button
                variant="outline"
                className="flex-1 rounded-none border border-[#2a2a2a] font-data text-xs uppercase tracking-widest text-[#E5E5E5] hover:bg-[#1a1a1a]"
                onClick={() => setShowDeleteConfirm(false)}
                disabled={deletePlan.isPending}
              >
                {t("plans.CANCEL")}
              </Button>
              <Button
                className="flex-1 rounded-none bg-[#8B0000] font-data text-xs font-bold uppercase tracking-widest text-white hover:bg-[#9F1239]"
                onClick={handleDelete}
                disabled={deletePlan.isPending}
              >
                {deletePlan.isPending ? t("plans.DELETING") : t("plans.DELETE")}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
