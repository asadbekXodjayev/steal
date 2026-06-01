"use client";

import Link from "next/link";
import { RegisterForm } from "@/components/auth/RegisterForm";
import { useI18n } from "@/components/providers/I18nProvider";

export default function RegisterPage() {
  const { t } = useI18n();

  return (
    <>
      <div className="mb-6 space-y-1">
        <h1
          className="text-2xl font-extrabold uppercase tracking-tight sm:text-4xl"
          style={{ fontFamily: "var(--font-heading, system-ui)" }}
        >
          {t("register.TITLE")}
        </h1>
        <p className="font-data text-xs text-muted-foreground">
          {t("register.SUBTITLE")}
        </p>
      </div>
      <RegisterForm />
      <p className="mt-4 text-center font-data text-xs text-muted-foreground">
        {t("register.ALREADY_IN")}{" "}
        <Link
          href="/login"
          className="font-semibold uppercase tracking-widest text-[#e53e00] underline-offset-4 hover:underline"
        >
          {t("register.SIGN_IN")}
        </Link>
      </p>
    </>
  );
}
