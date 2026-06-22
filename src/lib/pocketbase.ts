import PocketBase from "pocketbase";

/**
 * Resolve the PocketBase URL based on environment:
 *
 * - **Browser**: use `/pb` — Next.js rewrites proxy this to the real
 *   PocketBase server, avoiding mixed-content (HTTPS → HTTP) blocks.
 * - **Server (SSR/RSC)**: hit PocketBase directly since there is no
 *   mixed-content restriction server-side.
 */
function getPocketBaseUrl(): string {
  if (typeof window !== "undefined") {
    // Browser: same-origin proxy path
    return "/pb";
  }
  // Server: direct connection
  return (
    process.env.POCKETBASE_INTERNAL_URL ||
    process.env.NEXT_PUBLIC_API_URL ||
    "http://127.0.0.1:8090"
  );
}

function createPocketBase(): PocketBase {
  const pb = new PocketBase(getPocketBaseUrl());
  // Disable PocketBase's auto-cancellation. It keys in-flight requests by
  // endpoint, so rendering N components that each query the SAME collection
  // concurrently (e.g. one plan_exercises fetch per day card on /plans/[id])
  // cancels all but the last — the others error and render empty. TanStack
  // Query already dedupes and discards stale results, so PB-level cancellation
  // only causes this class of "only the last card has data" bug.
  pb.autoCancellation(false);
  return pb;
}

let clientInstance: PocketBase | null = null;

export function getPocketBase(): PocketBase {
  if (typeof window === "undefined") {
    // Server: always fresh
    return createPocketBase();
  }
  // Client: singleton
  if (!clientInstance) {
    clientInstance = createPocketBase();

    // Load auth from cookie on first creation
    const stored = document.cookie
      .split("; ")
      .find((c) => c.startsWith("pb_auth="));
    if (stored) {
      const value = decodeURIComponent(stored.split("=")[1]);
      try {
        const parsed = JSON.parse(value) as { token: string; record: { id: string; collectionId: string; collectionName: string; [key: string]: unknown } };
        clientInstance.authStore.save(parsed.token, parsed.record);
      } catch {
        // Corrupted cookie — ignore
      }
    }

    // Persist auth changes to cookie
    clientInstance.authStore.onChange(() => {
      if (clientInstance?.authStore.isValid) {
        const data = JSON.stringify({
          token: clientInstance.authStore.token,
          record: clientInstance.authStore.record,
        });
        document.cookie = `pb_auth=${encodeURIComponent(data)}; path=/; max-age=${7 * 24 * 60 * 60}; SameSite=Lax`;
      } else {
        document.cookie =
          "pb_auth=; path=/; max-age=0; SameSite=Lax";
      }
    });
  }
  return clientInstance;
}

/**
 * Clear the client singleton (e.g. on logout).
 */
export function clearPocketBase(): void {
  if (clientInstance) {
    clientInstance.authStore.clear();
    clientInstance = null;
  }
  // Also clear cookie
  if (typeof document !== "undefined") {
    document.cookie = "pb_auth=; path=/; max-age=0; SameSite=Lax";
  }
}
