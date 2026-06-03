"use client";

import { useEffect, useState, useCallback } from "react";
import {
  getQueuedMutations,
  removeMutation,
} from "@/utils/offline-queue";
import { getPocketBase } from "@/lib/pocketbase";
import { useQueryClient } from "@tanstack/react-query";

export function useOfflineSync() {
  const [isOnline, setIsOnline] = useState(
    typeof navigator !== "undefined" ? navigator.onLine : true,
  );
  const [pendingCount, setPendingCount] = useState(0);
  const [syncing, setSyncing] = useState(false);
  const queryClient = useQueryClient();

  useEffect(() => {
    function onOnline() {
      setIsOnline(true);
      void sync();
    }
    function onOffline() {
      setIsOnline(false);
    }
    window.addEventListener("online", onOnline);
    window.addEventListener("offline", onOffline);
    return () => {
      window.removeEventListener("online", onOnline);
      window.removeEventListener("offline", onOffline);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const sync = useCallback(async () => {
    if (syncing) return;
    setSyncing(true);
    try {
      const mutations = await getQueuedMutations();
      setPendingCount(mutations.length);
      if (mutations.length === 0) return;

      const pb = getPocketBase();
      for (const mutation of mutations) {
        try {
          if (mutation.action === "create") {
            await pb.collection(mutation.collection).create(mutation.data);
          } else if (mutation.action === "update" && mutation.recordId) {
            await pb.collection(mutation.collection).update(mutation.recordId, mutation.data);
          } else if (mutation.action === "delete" && mutation.recordId) {
            await pb.collection(mutation.collection).delete(mutation.recordId);
          }
          await removeMutation(mutation.id);
        } catch {
          // If one fails, continue with the rest
        }
      }
      // Refetch relevant queries — use broader invalidation so all session-derived
      // queries (quickSessions, planCompletedDays, progressData) pick up synced data
      await queryClient.invalidateQueries({ queryKey: ["quickSessions"] });
      await queryClient.invalidateQueries({ queryKey: ["planCompletedDays"] });
      await queryClient.invalidateQueries({ queryKey: ["progressData"] });
      setPendingCount(0);
    } finally {
      setSyncing(false);
    }
  }, [syncing, queryClient]);

  // Check pending count on mount
  useEffect(() => {
    void getQueuedMutations().then((m) => setPendingCount(m.length));
  }, []);

  return { isOnline, pendingCount, syncing, sync };
}
