import { type NextRequest } from "next/server";

// Same-origin proxy for ExerciseDB media (gifs/images). The browser fetches
// these from our own origin instead of static.exercisedb.dev directly, so they
// load even when that CDN is unreachable client-side (region block / ad- or
// privacy-blocker / CORS). The upstream fetch runs server-side, where the CDN is
// reachable. Mirrors the existing /pb PocketBase proxy in next.config.mjs.
const CDN = "https://static.exercisedb.dev";

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ path: string[] }> },
) {
  const { path } = await params;
  const target = `${CDN}/${path.map(encodeURIComponent).join("/")}`;

  const upstream = await fetch(target, { next: { revalidate: 86400 } });
  if (!upstream.ok || !upstream.body) {
    return new Response("Not found", { status: upstream.status || 404 });
  }

  return new Response(upstream.body, {
    status: 200,
    headers: {
      "Content-Type": upstream.headers.get("content-type") ?? "image/gif",
      "Cache-Control": "public, max-age=86400, immutable",
    },
  });
}
