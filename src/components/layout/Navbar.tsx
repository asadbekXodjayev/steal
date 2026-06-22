"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useI18n } from "@/components/providers/I18nProvider";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { LogOut, Settings, LayoutDashboard, Globe } from "lucide-react";
import { cn } from "@/lib/utils";

const navLinks = [
  { href: "/dashboard", label: "navbar.DASHBOARD" },
  { href: "/programs", label: "navbar.PROGRAMS" },
  { href: "/plans", label: "navbar.PLANS" },
  { href: "/exercises", label: "navbar.LIBRARY" },
] as const;

function LiveClock({ t }: { t: (path: string) => string }) {
  const [time, setTime] = useState<string>("");

  useEffect(() => {
    function tick() {
      const now = new Date();
      const hh = now.getUTCHours().toString().padStart(2, "0");
      const mm = now.getUTCMinutes().toString().padStart(2, "0");
      setTime(`${hh}:${mm}`);
    }

    tick();
    const id = setInterval(tick, 60_000);
    return () => clearInterval(id);
  }, []);

  if (!time) return null;

  return (
    <span
      className="font-data text-[12px] tabular-nums text-ink-mid select-none"
      aria-label={t("common.CURRENT_TIME_UTC")}
    >
      {time}
      <span className="ml-1 text-ink-low">UTC</span>
    </span>
  );
}

function StatusIndicator({ t }: { t: (path: string) => string }) {
  return (
    <span className="flex items-center gap-1.5" aria-label="System online">
      <span className="relative flex h-2 w-2">
        <span className="status-dot-pulse absolute inline-flex h-full w-full rounded-full bg-tactical opacity-75" />
        <span className="relative inline-flex h-2 w-2 rounded-full bg-tactical" />
      </span>
      <span className="stamp text-tactical hidden lg:inline">{t("navbar.ONLINE")}</span>
    </span>
  );
}

export function Navbar() {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const { language, setLanguage, t } = useI18n();

  const displayName =
    (typeof user?.name === "string" && user.name.length > 0
      ? user.name
      : typeof user?.email === "string" && user.email.length > 0
        ? user.email
        : "OPERATOR") as string;

  return (
    <header
      className="sticky top-0 z-40 h-14 glass-dark"
      style={{ borderBottom: "1px solid rgba(255,255,255,0.06)" }}
    >
      <div className="container-app flex h-full items-center justify-between">
        <div className="flex items-center gap-8">
          <Link
            href="/dashboard"
            className="flex items-center gap-2 select-none"
            aria-label={t("navbar.GO_TO_DASHBOARD")}
          >
            <span
              className="font-heading font-black leading-none text-[#C2410C]"
              style={{ fontSize: "15px", letterSpacing: "0.2em" }}
            >
              STEEL
            </span>
            <span
              aria-hidden="true"
              style={{ width: 1, height: 16, background: "rgba(255,255,255,0.08)" }}
            />
            <span
              className="font-data text-ink-mid"
              style={{ fontSize: "10px", letterSpacing: "0.12em" }}
            >
              THERAPY
            </span>
          </Link>

          <nav
            className="hidden items-center md:flex"
            role="navigation"
            aria-label={t("common.PRIMARY_NAVIGATION")}
          >
            {navLinks.map((link) => {
              const active =
                pathname === link.href || pathname.startsWith(link.href + "/");

              return (
                <Link
                  key={link.href}
                  href={link.href}
                  aria-current={active ? "page" : undefined}
                  className={cn(
                    "relative flex items-center px-3 py-4 font-data text-[11px] font-semibold uppercase tracking-wider transition-colors duration-100",
                    active ? "text-rust" : "text-ink-mid hover:text-ink-high",
                  )}
                >
                  {t(link.label)}
                  {active && (
                    <span className="absolute bottom-0 left-0 right-0 h-[2px] bg-rust" />
                  )}
                </Link>
              );
            })}
          </nav>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden items-center gap-2 lg:flex">
            <LiveClock t={t} />
          </div>

          <div className="hidden items-center sm:flex">
            <StatusIndicator t={t} />
          </div>

          <span
            className="hidden h-5 w-px bg-surface-4 sm:block"
            aria-hidden="true"
          />

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                aria-label={t("navbar.USER_MENU")}
                className="flex h-10 w-10 items-center justify-center rounded-full transition-all sm:h-[30px] sm:w-[30px]"
                style={{
                  background: "rgba(255,255,255,0.06)",
                  border: "1px solid rgba(255,255,255,0.1)",
                }}
              >
                <span className="font-data text-[12px] text-ink-high">
                  {displayName.charAt(0).toUpperCase()}
                </span>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent
              align="end"
              className="w-52 rounded-none border-surface-3 bg-surface-1 p-0"
              style={{ borderColor: "rgba(185,28,28,0.3)" }}
            >
              <div className="border-b border-surface-3 px-3 py-2.5">
                <div className="mb-2 flex items-center gap-2">
                  <Globe className="h-3.5 w-3.5 text-ink-mid" />
                  <p className="stamp text-ink-low">{t("navbar.OPERATOR")}</p>
                </div>
                <p className="mt-0.5 truncate font-data text-[11px] font-semibold uppercase tracking-wider text-ink-high">
                  {displayName}
                </p>
              </div>

              <div className="border-b border-surface-3 px-3 py-2">
                <p className="stamp mb-2 text-[10px] text-ink-mid">{t("navbar.LANGUAGE")}</p>
                <div className="flex gap-1">
                  {(["en", "ru", "uz"] as const).map((lang) => (
                    <button
                      key={lang}
                      onClick={() => setLanguage(lang)}
                      className={cn(
                        "px-2 py-1 font-data text-[11px] uppercase tracking-widest border transition-colors",
                        language === lang
                          ? "border-rust text-rust bg-surface-3"
                          : "border-surface-4 text-ink-mid hover:border-rust hover:text-ink-high",
                      )}
                    >
                      {lang.toUpperCase()}
                    </button>
                  ))}
                </div>
              </div>

              <div className="py-1">
                <DropdownMenuItem asChild className="rounded-none px-3 py-2 focus:bg-surface-3">
                  <Link href="/dashboard" className="flex items-center gap-2 font-data text-[11px] uppercase tracking-wide text-ink-mid hover:text-ink-high">
                    <LayoutDashboard className="h-3.5 w-3.5 shrink-0" />
                    <span className="truncate">{t("navbar.DASHBOARD")}</span>
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="rounded-none px-3 py-2 focus:bg-surface-3">
                  <Link href="/profile" className="flex items-center gap-2 font-data text-[11px] uppercase tracking-wide text-ink-mid hover:text-ink-high">
                    <Settings className="h-3.5 w-3.5 shrink-0" />
                    <span className="truncate">{t("navbar.PROFILE")}</span>
                  </Link>
                </DropdownMenuItem>
              </div>

              <DropdownMenuSeparator className="bg-surface-3" />

              <div className="py-1">
                <DropdownMenuItem
                  onClick={logout}
                  className="cursor-pointer rounded-none px-3 py-2 font-data text-[11px] uppercase tracking-wide text-rust focus:bg-surface-3 focus:text-rust"
                >
                  <LogOut className="mr-2 h-3.5 w-3.5 shrink-0" />
                  <span className="truncate">{t("navbar.SIGN_OUT")}</span>
                </DropdownMenuItem>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
