"use client";

/**
 * Catches errors thrown in the root layout itself. It replaces the entire
 * document, so it must render its own <html>/<body> and cannot rely on app
 * providers (no i18n here) — copy stays in English by necessity.
 */
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          minHeight: "100dvh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#050505",
          color: "#e5e5e5",
          fontFamily: "ui-monospace, monospace",
          padding: 24,
        }}
      >
        <div
          style={{
            maxWidth: 420,
            width: "100%",
            border: "1px solid rgba(239,68,68,0.4)",
            borderLeft: "3px solid #ef4444",
            background: "#0a0a0a",
            padding: "40px 28px",
            textAlign: "center",
          }}
        >
          <div style={{ fontSize: 14, letterSpacing: "0.3em", color: "#ef4444", marginBottom: 12 }}>
            SYSTEM FAILURE
          </div>
          <div style={{ fontSize: 11, letterSpacing: "0.15em", color: "#71717a", marginBottom: 24, lineHeight: 1.6 }}>
            Something broke at the core. Reload to recover.
          </div>
          <button
            onClick={reset}
            style={{
              border: "1px solid #e53e00",
              color: "#e53e00",
              background: "transparent",
              padding: "10px 24px",
              fontSize: 11,
              letterSpacing: "0.2em",
              textTransform: "uppercase",
              cursor: "pointer",
            }}
          >
            Retry
          </button>
        </div>
      </body>
    </html>
  );
}
