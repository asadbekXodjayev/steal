"use client";

import type { ReactNode } from "react";
import { QueryProvider } from "./QueryProvider";
import { AuthProvider } from "./AuthProvider";
import { I18nProvider } from "./I18nProvider";
import { Toaster } from "@/components/ui/sonner";

export function Providers({ children }: { children: ReactNode }) {
  return (
    <QueryProvider>
      <AuthProvider>
        <I18nProvider>
          {children}
          <Toaster position="bottom-center" richColors />
        </I18nProvider>
      </AuthProvider>
    </QueryProvider>
  );
}
