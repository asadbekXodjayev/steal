"use client";

import type { ReactNode } from "react";
import { Navbar } from "./Navbar";
import { BottomNav } from "./BottomNav";
import { AmbientGymLayer } from "./AmbientGymLayer";
import { PageTransition } from "@/components/providers/PageTransition";

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <div className="relative flex min-h-dvh flex-col bg-background overflow-x-hidden">
      {/* Military-industrial ambient layer — grid, barbells, glows, scanline */}
      <AmbientGymLayer />

      {/* Desktop/tablet top bar */}
      <Navbar />

      {/* Main content with padding for bottom nav on mobile */}
      <main className="relative z-[1] flex-1 pb-20 pt-4 md:pb-6 overflow-x-hidden">
        <div className="container-app w-full max-w-full sm:max-w-[90vw] md:max-w-[80vw] lg:max-w-[1000px] mx-auto">
          <PageTransition>{children}</PageTransition>
        </div>
      </main>

      {/* Mobile bottom navigation */}
      <BottomNav />
    </div>
  );
}
