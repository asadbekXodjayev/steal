"use client";

import { useEffect, useState, useRef } from "react";
import { m, LazyMotion, domAnimation, AnimatePresence, useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";

// ---------------------------------------------------------------------------
// ImpactFlash
// ---------------------------------------------------------------------------
interface ImpactFlashProps {
  trigger: boolean;
}

export function ImpactFlash({ trigger }: ImpactFlashProps) {
  const [visible, setVisible] = useState(false);
  const prefersReduced = useReducedMotion();

  useEffect(() => {
    if (trigger) {
      setVisible(true);
      const t = window.setTimeout(() => setVisible(false), 220);
      return () => clearTimeout(t);
    }
  }, [trigger]);

  if (prefersReduced || !visible) return null;

  return (
    <LazyMotion features={domAnimation}>
      <AnimatePresence>
        {visible && (
          <m.div
            key="impact-flash"
            className="fixed inset-0 pointer-events-none z-50"
            style={{
              background:
                "radial-gradient(ellipse at center, rgba(185,28,28,0.55) 0%, transparent 70%)",
            }}
            animate={{ opacity: [0, 0.85, 0] }}
            transition={{ duration: 0.22, ease: "easeOut" }}
            onAnimationComplete={() => setVisible(false)}
            aria-hidden="true"
          />
        )}
      </AnimatePresence>
    </LazyMotion>
  );
}

// ---------------------------------------------------------------------------
// CounterFX
// ---------------------------------------------------------------------------
interface CounterFXProps {
  value: number;
  className?: string;
}

export function CounterFX({ value, className }: CounterFXProps) {
  const prefersReduced = useReducedMotion();

  return (
    <span
      className={cn("font-data inline-block overflow-hidden relative", className)}
      style={{ fontVariantNumeric: "tabular-nums" }}
      aria-live="polite"
      aria-atomic="true"
    >
      <LazyMotion features={domAnimation}>
        <AnimatePresence mode="popLayout" initial={false}>
          <m.span
            key={value}
            className="inline-block"
            initial={prefersReduced ? false : { y: "100%", opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={prefersReduced ? undefined : { y: "-100%", opacity: 0 }}
            transition={{ duration: 0.08, ease: "easeOut" }}
            style={{ display: "inline-block" }}
          >
            {value}
          </m.span>
        </AnimatePresence>
      </LazyMotion>
    </span>
  );
}

// ---------------------------------------------------------------------------
// MetallicShine
// ---------------------------------------------------------------------------
interface MetallicShineProps {
  children: React.ReactNode;
  className?: string;
}

export function MetallicShine({ children, className }: MetallicShineProps) {
  const prefersReduced = useReducedMotion();

  return (
    <>
      {!prefersReduced && (
        <style>{`
          @keyframes shine-sweep-kf {
            0%   { transform: translateX(-100%) skewX(-15deg); opacity: 0; }
            20%  { opacity: 0.6; }
            100% { transform: translateX(220%) skewX(-15deg); opacity: 0; }
          }
          .shine-sweep::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(
              100deg,
              transparent 20%,
              rgba(255,255,255,0.18) 50%,
              transparent 80%
            );
            pointer-events: none;
            z-index: 10;
            animation: shine-sweep-kf 0.6s ease-out forwards;
          }
        `}</style>
      )}
      <div
        className={cn("relative overflow-hidden shine-sweep", className)}
        aria-hidden="false"
      >
        {children}
      </div>
    </>
  );
}

// ---------------------------------------------------------------------------
// CompletionBurst
// ---------------------------------------------------------------------------
interface CompletionBurstProps {
  trigger: boolean;
  className?: string;
}

interface Particle {
  id: number;
  angle: number;
  distance: number;
}

const PARTICLE_COUNT = 8;

export function CompletionBurst({ trigger, className }: CompletionBurstProps) {
  const [particles, setParticles] = useState<Particle[]>([]);
  const prevTrigger = useRef(false);
  const prefersReduced = useReducedMotion();

  useEffect(() => {
    if (trigger && !prevTrigger.current && !prefersReduced) {
      const ps: Particle[] = Array.from({ length: PARTICLE_COUNT }, (_, i) => ({
        id: Date.now() + i,
        angle: (360 / PARTICLE_COUNT) * i,
        distance: 80,
      }));
      setParticles(ps);
      const t = window.setTimeout(() => setParticles([]), 450);
      prevTrigger.current = true;
      return () => clearTimeout(t);
    }
    if (!trigger) {
      prevTrigger.current = false;
    }
  }, [trigger, prefersReduced]);

  if (prefersReduced) return null;

  return (
    <div
      className={cn("relative pointer-events-none", className)}
      aria-hidden="true"
    >
      <LazyMotion features={domAnimation}>
        <AnimatePresence>
          {particles.map((p) => {
            const rad = (p.angle * Math.PI) / 180;
            const tx = Math.cos(rad) * p.distance;
            const ty = Math.sin(rad) * p.distance;
            return (
              <m.span
                key={p.id}
                style={{
                  position: "absolute",
                  top: "50%",
                  left: "50%",
                  width: 6,
                  height: 6,
                  background: "var(--rust)",
                  marginTop: -3,
                  marginLeft: -3,
                  display: "block",
                }}
                initial={{ x: 0, y: 0, opacity: 1, scale: 1 }}
                animate={{
                  x: tx,
                  y: ty,
                  opacity: 0,
                  scale: 0.3,
                }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.45, ease: "easeOut" }}
              />
            );
          })}
        </AnimatePresence>
      </LazyMotion>
    </div>
  );
}
