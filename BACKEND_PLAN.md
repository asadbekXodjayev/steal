# Steal Therapy — Node.js Backend Plan

> Ready-to-execute spec for replacing PocketBase with a custom Node.js backend.
> Hand this file to an implementation agent (or work through it phase by phase).
> Target: **secure, fast, production-ready** API serving the existing Next.js 15 frontend.

---

## 1. Goals & Non-Goals

### Goals
- Replace PocketBase entirely: auth, data storage, file storage, and the REST surface the frontend consumes.
- Keep the **frontend data contracts identical** (the TypeScript types in `src/types/` are the source of truth — the new API must return those exact shapes).
- Security first: OWASP-grade auth, per-user data isolation, strict input validation.
- Speed: p95 < 50ms for hot reads, designed for a single cheap VPS or container.

### Non-Goals
- No GraphQL, no microservices, no Kubernetes. One process, one database.
- No admin UI in v1 (use Drizzle Studio / psql for ops).
- The Flutter app (`steel_flutter/`) is out of scope; it can adopt the same API later.

---

## 2. Tech Stack (locked)

| Concern | Choice | Why |
| --- | --- | --- |
| Runtime | **Node.js 22 LTS** | native `fetch`, stable perf |
| Framework | **Fastify v5** | fastest mainstream Node framework, schema-based serialization, first-class TypeScript |
| Language | **TypeScript strict** | matches frontend discipline |
| Database | **PostgreSQL 16** | relational fits the schema (plans→days→exercises→sessions→sets); JSONB for `structure`, `focus`, `limitations` |
| ORM | **Drizzle ORM** + `drizzle-kit` migrations | type-safe, zero runtime overhead vs Prisma engine |
| Validation | **Zod v3** (shared with frontend via a `shared/` package or copied schemas) | same library the frontend already uses |
| Auth | **JWT access (15 min) + rotating refresh tokens (30 days)** in httpOnly cookies | replaces `pb_auth` cookie flow |
| Password hashing | **argon2id** (`argon2` package) | current OWASP recommendation |
| Rate limiting | `@fastify/rate-limit` (backed by in-memory; Redis optional later) | brute-force protection |
| Security headers | `@fastify/helmet`, `@fastify/cors`, `@fastify/cookie` (signed) | baseline hardening |
| File storage | Local disk via `@fastify/static` behind `/files`, abstracted so S3/R2 is a config swap | plan/template images |
| Logging | **pino** (built into Fastify) with redaction of auth headers/cookies | structured, fast |
| Testing | **vitest** + `fastify.inject()` (no network) | fast unit/integration tests |
| Deployment | Docker (multi-stage, distroless) — runs anywhere; pairs with the Vercel frontend via `NEXT_PUBLIC_API_URL` | |

Repo location: **new sibling folder `backend/`** inside this repo (monorepo-lite), so frontend types can be shared. If a separate repo is preferred, copy `src/types/` into it.

---

## 3. Project Structure

```
backend/
├── src/
│   ├── app.ts                  # buildApp(): registers plugins + routes (no listen)
│   ├── server.ts               # entry: buildApp().listen()
│   ├── config.ts               # env parsing via Zod — crash on missing/invalid env
│   ├── db/
│   │   ├── client.ts           # Drizzle + pg Pool
│   │   ├── schema/             # one file per table (users, profiles, plans, …)
│   │   └── migrations/         # drizzle-kit output (committed)
│   ├── modules/                # feature modules: routes + service + schemas
│   │   ├── auth/               # register, login, refresh, logout, me
│   │   ├── profiles/
│   │   ├── goals/
│   │   ├── plans/              # plans + plan_days + plan_exercises
│   │   ├── exercises/          # catalog + translations
│   │   ├── sessions/           # workout_sessions + session_sets
│   │   ├── templates/          # plan_templates (public read)
│   │   └── progress/           # aggregated analytics endpoints
│   ├── plugins/
│   │   ├── auth.ts             # JWT verify decorator → request.user
│   │   ├── security.ts         # helmet, cors, rate-limit, cookie
│   │   └── error-handler.ts    # uniform error envelope, no stack leaks
│   └── lib/                    # pure helpers (pagination, id gen)
├── scripts/
│   └── migrate-from-pocketbase.mts   # one-shot data migration
├── test/
├── drizzle.config.ts
├── Dockerfile
├── .env.example
└── package.json
```

Module pattern (every module follows it):
- `*.schemas.ts` — Zod schemas for body/query/params **and** response. Responses are compiled to Fastify JSON schemas (via `fastify-type-provider-zod`) so serialization is fast and never leaks extra columns.
- `*.service.ts` — DB logic, no HTTP awareness.
- `*.routes.ts` — thin handlers: validate → call service → return.

---

## 4. Database Schema (PostgreSQL)

IDs: `text` primary keys using **nanoid(15)** — keeps PocketBase-style 15-char ids so migrated data and frontend code (string ids) work unchanged. All tables get `created` / `updated` `timestamptz` columns (`updated` via trigger or Drizzle `$onUpdate`) serialized as ISO strings to match the frontend types.

| Table | Mirrors PB collection | Notes |
| --- | --- | --- |
| `users` | `users` | email (citext, unique), password_hash, name, verified. Never expose `password_hash`. |
| `refresh_tokens` | — (new) | token_hash (sha256), user_id, expires_at, revoked_at, replaced_by — enables rotation + reuse detection |
| `profiles` | `profiles` | 1:1 user (unique FK). `limitations` JSONB (`Limitation[]`), age/height/weight numeric, gender/fitness_level enums |
| `goals` | `goals` | user FK, type/environment enums, `equipment` JSONB (`EquipmentItem[]`), days_per_week, session_minutes, priority |
| `workout_plans` | `workout_plans` | user FK, title, description, source enum, template_id nullable, goal_type/environment enums, duration_weeks, current_week, status enum, `image_urls` JSONB |
| `plan_days` | `plan_days` | plan FK (cascade), week, day_of_week (1–7), label, `focus` JSONB, `warmup`/`cooldown` JSONB nullable |
| `plan_exercises` | `plan_exercises` | plan_day FK (cascade), exercise FK, "order", sets, reps_min, reps_max, rpe_target, rest_seconds, notes, `substitutions` JSONB, `week_variations` JSONB |
| `exercises` | `exercises` | name, slug (unique), `muscle_groups` JSONB, `equipment` JSONB, category/difficulty enums, instructions, `alternatives` JSONB, video_url |
| `exercise_translations` | `exercise_translations` | exercise_ext_id, locale, name, overview, body_part, equipment, target; unique (exercise_ext_id, locale) |
| `workout_sessions` | `workout_sessions` | user FK, plan_day/plan nullable FKs, started_at, completed_at, status enum, mood enum nullable, energy_level, session_notes, therapy_reflection |
| `session_sets` | `session_sets` | session FK (cascade), exercise FK, set_number, reps, weight numeric(6,2), rpe, completed bool, notes |
| `plan_templates` | `plan_templates` | title, goal_type, environment, difficulty enum, duration_weeks, `structure` JSONB (multilingual `{slug, locales:{en,ru,uz}}` — keep as-is), popularity, `image_urls` JSONB, tagline |

### Indexes (the "fast" part)
- `profiles(user_id)` unique; `goals(user_id)`
- `workout_plans(user_id, status)`
- `plan_days(plan_id, week)`; `plan_exercises(plan_day_id, "order")`
- `workout_sessions(user_id, started_at DESC)` — powers all of `useProgress`
- `workout_sessions(plan_id, status)` — powers week-progression check
- `session_sets(session_id)`, `session_sets(exercise_id)` — PR lookups
- `exercise_translations(exercise_ext_id, locale)` unique
- `exercises(slug)` unique

---

## 5. API Design

Base path: `/api/v1`. JSON only. Uniform envelopes:

```jsonc
// success: the resource directly, or for lists:
{ "items": [...], "page": 1, "perPage": 50, "totalItems": 123, "totalPages": 3 }
// error:
{ "error": { "code": "VALIDATION_ERROR", "message": "…", "details": [...] } }
```

(The list envelope deliberately mirrors PocketBase's `getList` shape — minimizes frontend churn.)

### Auth (`/auth`)
| Method | Path | Notes |
| --- | --- | --- |
| POST | `/auth/register` | email + password (min 10 chars) + name → creates user, returns user + sets cookies |
| POST | `/auth/login` | constant-time compare via argon2; rate-limited 5/min/IP + per-email backoff |
| POST | `/auth/refresh` | rotates refresh token; **reuse of a rotated token revokes the whole family** |
| POST | `/auth/logout` | revokes refresh token, clears cookies |
| GET | `/auth/me` | current user (id, email, name, created) |

Cookies: `st_access` (15 min) + `st_refresh` (30 d, path=`/api/v1/auth`) — both `httpOnly; Secure; SameSite=Lax`, signed. **This replaces the JS-readable `pb_auth` cookie — an XSS can no longer exfiltrate the token.** Also accept `Authorization: Bearer` for the Flutter app later.

### Resources (all require auth unless noted; every query is scoped `WHERE user_id = request.user.id` — **ownership enforced in the service layer, never trusted from the client**)

| Area | Endpoints |
| --- | --- |
| Profile | `GET/POST/PATCH /profile` (singleton per user) |
| Goals | `GET/POST /goals`, `PATCH/DELETE /goals/:id` |
| Plans | `GET /plans?status=`, `POST /plans`, `GET /plans/:id` (with `?expand=days.exercises` returning nested days+exercises in **one query** — replaces PB expand), `PATCH /plans/:id`, `DELETE /plans/:id` |
| Plan days/exercises | nested under plan: `POST /plans/:id/days`, `POST /days/:id/exercises`, `PATCH/DELETE /plan-exercises/:id` |
| Templates | `GET /templates`, `GET /templates/:id` — **public, no auth** (replicates the empty `listRule`; `/explore` and `/programs` must work logged-out) |
| Exercises | `GET /exercises?search=&muscleGroup=&page=` — public read; `GET /exercises/translations?ids=a,b,c&locale=ru` batched (replaces `useExerciseTranslation` batching) |
| Sessions | `POST /sessions` (start), `GET /sessions?from=&to=`, `GET /sessions/:id?expand=sets`, `PATCH /sessions/:id` (complete: sets `completedAt`, `mood`, `energyLevel`; **server-side week progression** — see below), `POST /sessions/:id/sets`, `PATCH/DELETE /sets/:id` |
| Progress | `GET /progress/summary` — server-computed streaks, total volume, PRs, muscle distribution, weekly volume series. **Fixes the `useProgress` quirk**: today the client fetches 200 unfiltered sessions and filters in JS to dodge PB auto-cancellation; the new backend does proper SQL aggregation (`SUM(weight*reps)`, window functions for PRs) and returns a small payload. |

### Week progression (moves server-side)
Currently `src/app/(app)/workout/[sessionId]/page.tsx` advances `currentWeek` client-side. New rule: when `PATCH /sessions/:id` sets `status=completed`, inside **one transaction**: load the plan's current-week `plan_days`, count distinct completed sessions for them, and if all days are done → `current_week += 1`. Response includes `{ weekAdvanced: boolean, currentWeek }` so the UI can celebrate. Client code in the workout page gets deleted.

---

## 6. Security Checklist (acceptance criteria)

- [ ] **argon2id** hashing (memory 19 MiB, time 2, parallelism 1 minimum); never log or return hashes.
- [ ] JWT: short-lived access (15 min), `HS256` with ≥256-bit secret from env (or ES256 if multi-service later); `iss`/`aud` claims validated.
- [ ] Refresh rotation with **reuse detection** → revoke token family + audit log line.
- [ ] All cookies `httpOnly; Secure; SameSite=Lax`, signed with a separate secret.
- [ ] **Zod validation on every input** (body, query, params) with `.strict()` objects — unknown keys rejected, mass-assignment impossible.
- [ ] Response schemas on every route — fields are allowlisted, accidental column leaks impossible.
- [ ] Per-user row scoping in services; integration tests assert **user A gets 404 (not 403) for user B's resources** (no existence oracle).
- [ ] Rate limits: global 100 req/min/IP; `/auth/login` + `/auth/register` 5/min/IP; 429 with `Retry-After`.
- [ ] `@fastify/helmet` defaults + `X-Content-Type-Options`; CORS allowlist = exact frontend origins (`https://<app>.vercel.app`, `http://localhost:3000`), `credentials: true`.
- [ ] Parameterized queries only (Drizzle guarantees this — **no raw SQL string interpolation anywhere**, enforce in review).
- [ ] Request body limit 1 MB (`bodyLimit`); pagination capped at `perPage ≤ 100`.
- [ ] Error handler: 500s return generic message; details only in pino logs. Pino redacts `authorization`, `cookie`, `password`.
- [ ] Secrets via env only; `.env` gitignored; `config.ts` crashes at boot on missing secrets.
- [ ] Dependency hygiene: `npm audit` in CI; lockfile committed; no `eval`-class deps.
- [ ] Account enumeration resistance: register/login return identical timing-padded generic errors.

## 7. Performance Checklist

- [ ] Fastify schema serialization on all routes (≈2× faster JSON than `res.json`).
- [ ] pg Pool (max 10), statement_timeout 5s.
- [ ] N+1 banned: plan detail = 3 batched queries max (plan, days, exercises `IN (dayIds)`); progress = pure SQL aggregates.
- [ ] `ETag`/`Cache-Control: public, max-age=300, stale-while-revalidate` on public reads (`/templates`, `/exercises`) — they change rarely.
- [ ] Gzip/Brotli via `@fastify/compress` (or terminate at the reverse proxy).
- [ ] Keep-alive on; graceful shutdown (`onClose` drains pool, finishes in-flight).
- [ ] Load test gate: `autocannon` — `/templates` ≥ 5k req/s local; `/progress/summary` p95 < 50ms with 10k sessions seeded.

---

## 8. PocketBase → Postgres Migration

`scripts/migrate-from-pocketbase.mts` (resumable, like existing seed scripts):
1. Auth as PB admin (`POCKETBASE_ADMIN_EMAIL/PASSWORD` from `.env.local`).
2. Export each collection via `getFullList` in dependency order: users → exercises → exercise_translations → plan_templates → profiles → goals → workout_plans → plan_days → plan_exercises → workout_sessions → session_sets.
3. **Keep original record ids** (15-char PB ids fit the `text` PK) — all FKs survive verbatim.
4. Passwords cannot be exported from PB → users get a `password_hash = NULL` + `must_reset = true`; login for such users returns 409 `PASSWORD_RESET_REQUIRED` and the frontend shows a reset flow. (For a dev DB with few users, simpler: just re-register.)
5. Download PB file attachments into the new file store, rewrite URLs.
6. Verify step: row counts per table must match PB, then spot-check 5 random deep plans.

---

## 9. Frontend Migration (this repo)

Per `CLAUDE.md` conventions — all of this lands in `src/lib/api.ts` + hooks; UI untouched.

1. **New `src/lib/api.ts`**: thin typed `fetch` wrapper — base URL from `NEXT_PUBLIC_API_URL`, `credentials: "include"`, 401 → single-flight refresh queue → retry once → logout (follow the `api-communication` skill).
2. **Next.js rewrite**: repoint `/pb/:path*` → delete; add `/api/v1/:path*` → backend URL in `next.config.mjs` (same mixed-content rationale).
3. Rewrite hooks one module at a time, keeping TanStack Query keys and return shapes identical: `useAuth`/`AuthProvider` → cookie-session model (no client-readable token), then `useProfile`, `usePlans`, `useProgramTemplates`, `useQuickSessions`, `useProgress` (now one `GET /progress/summary` call), `useExerciseTranslation`.
4. Delete `src/lib/pocketbase.ts`, drop the `pocketbase` dependency, remove the `pb_auth` cookie code.
5. `npm run typecheck` must pass after every module swap — the `src/types/` contracts don't change, so breakage = backend shape bug.

---

## 10. Phases

| Phase | Deliverable | Definition of done |
| --- | --- | --- |
| **1. Skeleton** | Fastify app, config, Drizzle + migrations, Docker, CI (typecheck + vitest + audit) | `GET /healthz` returns `{ok:true}` in container |
| **2. Auth** | register/login/refresh/logout/me + security plugins | all auth checklist items ticked; vitest covers rotation-reuse attack |
| **3. Core data** | profiles, goals, plans (+days/exercises), exercises, translations, templates | CRUD integration tests incl. cross-user 404 tests |
| **4. Sessions + progression** | sessions, sets, transactional week-advance | progression test: completing final day of week bumps `currentWeek` exactly once under concurrent requests |
| **5. Progress analytics** | `/progress/summary` SQL aggregates | output matches current client-computed numbers on migrated data |
| **6. Migration + frontend swap** | PB export script; `src/lib/api.ts`; hooks rewired module-by-module | app runs end-to-end with PB fully removed; `npm run typecheck` clean |
| **7. Hardening** | load tests, helmet/CORS audit, log redaction review, `.env.example`, README | perf gates in §7 pass |

---

## 11. Ready Prompt (paste this to start implementation)

> Implement Phase {N} of `BACKEND_PLAN.md` in the `backend/` folder of this repo.
> Source of truth for data shapes: `src/types/*.ts` (frontend contracts — API responses must match them exactly, camelCase, ISO date strings).
> Follow the module pattern in §3, the security checklist in §6, and the performance checklist in §7 — these are acceptance criteria, not suggestions.
> Stack is locked per §2: Fastify v5 + TypeScript strict + Drizzle + PostgreSQL 16 + Zod + argon2 + JWT-in-httpOnly-cookies. Do not substitute.
> Write vitest integration tests using `fastify.inject()` for every route, including a cross-user isolation test (expect 404).
> Finish with `npm run typecheck` and `npm test` passing, then a ≤8-line summary.
