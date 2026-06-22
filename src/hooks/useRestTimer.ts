"use client";

import { useState, useEffect, useRef, useCallback } from "react";

interface UseRestTimerReturn {
  secondsLeft: number;
  isRunning: boolean;
  /** The full duration the current countdown started from (progress-bar denominator). */
  totalSeconds: number;
  start: (seconds: number) => void;
  stop: () => void;
  reset: () => void;
}

/**
 * Countdown rest timer with Web Audio API notification.
 */
export function useRestTimer(): UseRestTimerReturn {
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [totalSeconds, setTotalSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const audioCtxRef = useRef<AudioContext | null>(null);

  const playAlert = useCallback(() => {
    try {
      if (!audioCtxRef.current) {
        audioCtxRef.current = new AudioContext();
      }
      const ctx = audioCtxRef.current;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);

      // Two-tone beep
      osc.frequency.setValueAtTime(880, ctx.currentTime);
      osc.frequency.setValueAtTime(1100, ctx.currentTime + 0.15);
      gain.gain.setValueAtTime(0.3, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);

      osc.start(ctx.currentTime);
      osc.stop(ctx.currentTime + 0.4);
    } catch {
      // Audio not available — silent fallback
    }
  }, []);

  const stop = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
    setIsRunning(false);
  }, []);

  const start = useCallback(
    (seconds: number) => {
      stop();
      setSecondsLeft(seconds);
      setTotalSeconds(seconds);
      setIsRunning(true);
    },
    [stop],
  );

  const reset = useCallback(() => {
    stop();
    setSecondsLeft(0);
    setTotalSeconds(0);
  }, [stop]);

  useEffect(() => {
    if (!isRunning) return;

    intervalRef.current = setInterval(() => {
      setSecondsLeft((prev) => {
        if (prev <= 1) {
          stop();
          playAlert();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isRunning, stop, playAlert]);

  return { secondsLeft, totalSeconds, isRunning, start, stop, reset };
}
