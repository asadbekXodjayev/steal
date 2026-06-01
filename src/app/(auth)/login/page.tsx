"use client";

import Link from "next/link";
import { LoginForm } from "@/components/auth/LoginForm";
import { useI18n } from "@/components/providers/I18nProvider";

export default function LoginPage() {
  const { t } = useI18n();

  return (
    <div className="page-enter flex min-h-dvh flex-col items-center justify-center p-4">
      {/* Background atmosphere */}
      <div className="steal-atmosphere -z-10" />

      {/* Main card container */}
      <div className="w-full max-w-md">
        {/* Brand header */}
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-none bg-[#8B0000]">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="square"
              strokeLinejoin="miter"
              className="h-7 w-7 text-white"
            >
              <path d="M6.5 6.5h11M6.5 17.5h11M6 20v-5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v5M6 4v5a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V4" />
            </svg>
          </div>
          <h1
            className="text-3xl font-black uppercase tracking-tight text-[#E5E5E5] sm:text-4xl"
            style={{ fontFamily: "var(--font-heading, system-ui)" }}
          >
            {t("login.BACK_IN_THE")}
            <br />
            <span className="text-[#8B0000]">{t("login.RACK")}</span>
          </h1>
          <p className="mt-4 font-data text-xs uppercase tracking-widest text-[#71717A]">
            {t("login.SUBTITLE")}
          </p>
        </div>

        {/* Login form */}
        <div className="relative">
          <div className="absolute left-0 top-0 h-full w-1 bg-gradient-to-b from-[#8B0000] to-transparent" />
          <LoginForm />
        </div>

        {/* Register link */}
        <div className="mt-6 text-center">
          <p className="font-data text-xs text-[#71717A]">
            {t("login.NO_ACCOUNT")}{" "}
            <Link
              href="/register"
              className="font-semibold uppercase tracking-widest text-[#8B0000] transition-colors hover:text-[#9F1239]"
            >
              {t("login.REGISTER")}
            </Link>
          </p>
        </div>

        {/* Debug — remove after confirming connection works */}
        {/* <ConnectionDebug /> */}

        {/* Footer accent */}
        <div className="mt-10 flex items-center justify-center gap-4">
          <div className="h-px w-12 bg-[#2a2a2a]" />
          <span className="font-data text-[9px] uppercase tracking-[0.2em] text-[#71717A]">
            {t("login.FOOTER")}
          </span>
          <div className="h-px w-12 bg-[#2a2a2a]" />
        </div>
      </div>
    </div>
  );
}
