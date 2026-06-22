// One-off: list collections (name/id/type/system) on OLD and NEW PB so we can
// plan a safe schema clone. Creds come from --env-file (never the CLI).
import PocketBase from "pocketbase";

const EMAIL = process.env.POCKETBASE_ADMIN_EMAIL;
const PASS  = process.env.POCKETBASE_ADMIN_PASSWORD;
const OLD   = process.env.OLD_PB_URL;
const NEW   = process.env.NEW_PB_URL;

async function dump(label, url) {
  if (!url) { console.log(`\n${label}: (no url)`); return; }
  const pb = new PocketBase(url);
  try {
    await pb.collection("_superusers").authWithPassword(EMAIL, PASS);
  } catch (e) {
    console.log(`\n${label} (${url}): AUTH FAILED — ${e.message}`);
    console.log(`   email set: ${!!EMAIL}, pass set: ${!!PASS}`);
    console.log(`   status: ${e.status}  url: ${e.url}`);
    console.log(`   response: ${JSON.stringify(e.response)}`);
    console.log(`   cause: ${e.originalError?.cause?.message ?? e.originalError?.message ?? "n/a"}`);
    return;
  }
  const cols = await pb.collections.getFullList({ sort: "name" });
  console.log(`\n${label} (${url}): ${cols.length} collections`);
  for (const c of cols) {
    console.log(`  ${c.system ? "[sys] " : "      "}${c.name}  id=${c.id}  type=${c.type}`);
  }
}

await dump("OLD", OLD);
await dump("NEW", NEW);
