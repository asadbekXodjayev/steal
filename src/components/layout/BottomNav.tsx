"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  ClipboardList,
  FileText,
  TrendingUp,
  BookOpen,
  Settings,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/components/providers/I18nProvider";

const tabs = [
  { href: "/dashboard", labelKey: "bottomNav.HOME", icon: LayoutDashboard },
  { href: "/programs", labelKey: "bottomNav.PROGRAMS", icon: ClipboardList },
  { href: "/plans", labelKey: "bottomNav.PLANS", icon: FileText },
  { href: "/progress", labelKey: "bottomNav.STATS", icon: TrendingUp },
  { href: "/exercises", labelKey: "bottomNav.LIBRARY", icon: BookOpen },
  { href: "/settings", labelKey: "bottomNav.GEAR", icon: Settings },
] as const;

export function BottomNav() {
  const pathname = usePathname();
  const { t } = useI18n();

  return (
    <nav
      className="fixed inset-x-0 bottom-0 z-50 glass-dark md:hidden"
      role="navigation"
      aria-label={t("common.MAIN_NAVIGATION")}
    >
      <div className="flex h-16 items-center justify-around">
        {tabs.map((tab) => {
          const active =
            pathname === tab.href || pathname.startsWith(tab.href + "/");
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={cn(
                "flex h-16 flex-col items-center justify-center gap-0.5 px-3 font-data text-[11px] font-semibold uppercase tracking-widest transition-all",
                active ? "text-[#C2410C]" : "text-ink-mid hover:text-ink-high",
              )}
              aria-current={active ? "page" : undefined}
            >
              <tab.icon
                className={cn(
                  "h-5 w-5 transition-transform",
                  active && "scale-110",
                )}
              />
              <span>{t(tab.labelKey)}</span>
              {active && (
                <span className="absolute bottom-0 left-1/2 h-0.5 w-8 -translate-x-1/2 bg-[#C2410C]" />
              )}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
