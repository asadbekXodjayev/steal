# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## Project Intent

- Pure frontend web app — **Next.js 15 (App Router + React Server Components)**, TypeScript strict mode. Deploy target: **Vercel**.
- Backend is **PocketBase**, reached via the **PocketBase SDK** (`pocketbase` npm package). There is no custom REST backend in this repo.
- Server state flows through custom hooks in `src/hooks/` built on **TanStack Query v5**. Client-only state lives in **Zustand v5** stores.
- Product is "**Steal Therapy**" — a brutal/industrial gym training app (workout plans, session logging, progress analytics, multilingual exercise library). Companion React Native app lives in `STEEL-Mobile/` (out of scope unless asked).

## Tech Stack (Locked — Do Not Substitute Without Asking)

| Concern | Choice | Version |
| --- | --- | --- |
| Framework | Next.js (App Router, RSC) | `^15.1.6` |
| UI runtime | React | `^19.0.0` |
| Language | TypeScript, `strict: true` | `^5.7.3` |
| Styling | Tailwind CSS **v4** (`@tailwindcss/postcss`, **no `tailwind.config.js`** — tokens live in `globals.css` via `@theme`) | `^4.0.0` |
| Components | shadcn/ui (New York, neutral base, CSS variables) over `radix-ui` | `radix-ui ^1.4.3` |
| Server state | `@tanstack/react-query` | `^5.62.11` |
| Client state | `zustand` | `^5.0.2` |
| Forms | `react-hook-form` + `zod` (`@hookform/resolvers`) | `7.72 / 3.25` |
| Icons | `lucide-react` | `^0.469.0` |
| Animation | `framer-motion` | `^12.38.0` |
| Charts | `recharts` | `^3.8.1` |
| Toasts | `sonner` | `^2.0.7` |
| Theming | `next-themes` (light/dark) | `^0.4.6` |
| Backend SDK | `pocketbase` | `^0.26.8` |
| AI (scripts only) | `ai` + `@ai-sdk/{google,groq,anthropic,openai}` | `ai ^6` |
| Path alias | `@/*` → `src/*` | — |

Rule of thumb: **Zustand** for client-only state (UI toggles, active-workout wizard); **TanStack Query + PocketBase** for anything sourced from the backend. The `@ai-sdk/*` packages are used only by Node seed scripts, **not** in the app runtime.

## Folder Structure

```
src/
├── app/
│   ├── layout.tsx          # root layout — RSC; wraps children in Providers
│   ├── page.tsx            # landing
│   ├── globals.css         # Tailwind v4 entry + @theme tokens + CSS vars
│   ├── theme-script.js     # inline no-flash theme script
│   ├── manifest.ts         # PWA manifest
│   ├── (auth)/             # login, register
│   ├── (app)/             # protected: dashboard, plans, programs, progress,
│   │                       #   exercises, workout, onboarding, settings
│   └── (public)/          # public: explore
├── components/
│   ├── ui/                 # shadcn/ui primitives (~20 files — do not hand-edit)
│   ├── layout/            # AppShell, Navbar, BottomNav, ambient/noise overlays
│   ├── auth/              # LoginForm, RegisterForm, ConnectionDebug
│   ├── onboarding/        # multi-step wizard (profile/goals/environment/limitations)
│   ├── plans/            # PlanCard, ManualPlanForm, TemplateGrid, ExercisePickerModal
│   ├── programs/         # ProgramDetail, ProgramPreview, PlanImageCarousel
│   ├── workout/          # ExerciseCard, SetRow, RestTimer, MoodCheck, WorkoutSummary
│   ├── progress/         # ~17 chart/analytics components (volume, PRs, streaks, radar…)
│   ├── fx/               # visual effects (ImpactFlash)
│   └── providers/        # Providers, AuthProvider, QueryProvider, I18nProvider, Theme*
├── hooks/                 # data + behavior hooks (see table below)
├── stores/                # ui-store.ts, workout-store.ts (Zustand)
├── lib/                   # pocketbase.ts, api.ts, utils.ts, constants.ts, domain logic
├── types/                 # plan, profile, session, progress, exercise, achievement
├── locales/               # en.json, ru.json, uz.json (UI strings)
├── data/                  # exercises.json, legend-programs.ts (static catalogs)
└── utils/                 # offline-queue.ts (pure helpers)
```

`components.json` (repo root) is the shadcn/ui config; its aliases match this tree.

## Hooks (`src/hooks/`)

| Hook | Purpose |
| --- | --- |
| `useAuth` | PocketBase auth store, login/logout, current user |
| `useProfile` | user profile CRUD (`profiles` collection) |
| `usePlans` | workout plan CRUD |
| `useProgramTemplates` | legend program templates (locale-aware `select`, see below) |
| `useProgress` | streaks, PRs, volume, muscle distribution |
| `useAchievements` | achievement/badge computation |
| `useQuickSessions` | ad-hoc / quick workout sessions |
| `useGuestWorkouts` | guest (unauthenticated) workout handling |
| `useOfflineSync` | flush the offline queue when back online |
| `useExerciseTranslation` | localized exercise names/instructions |
| `useRestTimer` | between-set rest timer |
| `useMouseParallax` | pointer parallax effect (UI only) |

## i18n / Localization

- **Custom React Context — NOT i18next.** Provider: `src/components/providers/I18nProvider.tsx`, consumed via `useI18n()` → `{ language, setLanguage, t }`.
- `t("dot.path")` resolves against `src/lib/translations.ts` (typed `translations` object). UI string source lives in `src/locales/{en,ru,uz}.json`.
- Languages: **en, ru, uz**. Persisted to `localStorage["language"]`, default `en`.
- When adding user-facing text, add the key to all three locales and resolve it through `t()` — never hardcode strings.

## PocketBase Integration

### URL resolution (`src/lib/pocketbase.ts`)

- **Browser** → `/pb` (Next.js rewrite proxies to PocketBase, avoiding HTTPS→HTTP mixed-content blocks). Never hardcode the PB URL on the client.
- **Server (SSR/RSC)** → direct connection via `POCKETBASE_INTERNAL_URL` (falls back to `NEXT_PUBLIC_API_URL`, then `http://127.0.0.1:8090`).
- Client is a singleton; auth token is persisted to a `pb_auth` cookie and restored on init. `clearPocketBase()` resets it on logout.
- The proxy rewrite (`/pb/:path*`) and allowed image remotes are configured in `next.config.mjs`.

### Collections

| Collection | Purpose | Key Fields |
| --- | --- | --- |
| `profiles` | user profile | goalType, environment, currentWeight, height, age |
| `workout_plans` | user programs | title, source, goalType, durationWeeks, currentWeek, status, **imageUrls** (JSON array) |
| `plan_days` | training days | plan, week, dayOfWeek, label, focus (JSON), warmup, cooldown |
| `plan_exercises` | exercises in a day | planDay, exercise, sets, repsMin, repsMax, rpeTarget, restSeconds |
| `exercises` | exercise catalog | name, muscleGroup, equipment, instructions |
| `workout_sessions` | completed sessions | user, planDay, plan, startedAt, completedAt, status, mood, energyLevel |
| `session_sets` | logged sets | session, exercise, setNumber, weight, reps, rpe, notes |
| `plan_templates` | pre-built program templates | title, goalType, difficulty, durationWeeks, popularity, **structure** (JSON, multilingual) |
| `exercise_translations` | EN→RU/UZ exercise strings | exerciseExtId, locale, name, overview, bodyPart, equipment, target |
| `goals` | fitness goals | user, goalType, targetWeight, deadline, notes |

### `plan_templates` — embedded multilingual structure

The `structure` JSON holds all locales inline (`{ slug, locales: { en, ru, uz } }`) — no separate translation table. `useProgramTemplates()` fetches the raw records **once** (`queryKey: ["program-templates"]`) and uses TanStack Query `select` to remap to the active locale on language switch — **one PB fetch, zero extra requests**. Presentation-only metadata (athlete name, hero image, tags) is merged client-side from `SLUG_META` in the hook. The `listRule`/`viewRule` for `plan_templates` **must be empty** (`""`) — `/programs` and `/explore` are public; an auth rule silently returns an empty list to visitors.

### `exercise_translations`

Seeded via `scripts/seed-exercise-translations.mjs`. The hook batches IDs per PB filter call. Requires auth (`listRule: @request.auth.id != ""`).

### Week progression

`workout_plans.currentWeek` advances in `src/app/(app)/workout/[sessionId]/page.tsx` after a session completes: load all `plan_days` for the current week, load their `completed` `workout_sessions`; if every day is done → `currentWeek += 1`. Dashboard shows only `planDay.week === plan.currentWeek` as active; future weeks render "locked" in the UI (not enforced in DB).

### Known quirk: `useProgress` fetches all sessions

`useProgress.ts` calls `getList(1, 200)` **without a user filter** then filters in JS — a deliberate workaround for PocketBase SDK auto-cancellation issues with filters. Do **not** "fix" it to a server-side filter without testing; it breaks the auto-cancel protection.

### Zustand stores

- `src/stores/workout-store.ts` — active session (sets logged, timer, current exercise). Persisted to `localStorage` so in-progress workouts survive refresh.
- `src/stores/ui-store.ts` — ephemeral UI toggles (modals, sidebar).

## Product Rules

- **Distinctive UI — no generic "AI slop."** Prefer Server Components; reach for `"use client"` only for interactivity, browser APIs, or client-only libs.
- Every data call handles **loading, error, and empty** states explicitly. An unhandled empty state is a bug.
- Accessibility and Core Web Vitals are first-class, not polish.
- Follow the **brutal gym aesthetic** and **"Steel Forges Steel"** brand tone (squared corners — `--radius: 0`, blood red + forged-steel orange on void black; see skills below).
- Image carousels auto-slide, pause on hover, support keyboard navigation.

## Commands

| Command | What It Does |
| --- | --- |
| `npm run dev` | Dev server at http://localhost:3000 |
| `npm run build` | Production build |
| `npm run start` | Serve production build |
| `npm run typecheck` | `tsc --noEmit` strict typecheck |
| `npm run fetch:exercises` | Fetch ExerciseDB dataset → `src/data/exercises.json` |
| `npm run seed:translations` | Seed EN→RU/UZ exercise translations into PocketBase (uses `.env.local`) |
| `npm run apply:translation-schema` | Apply/validate the translation schema in PocketBase |
| `node --env-file=.env.local scripts/seed-legends-programs.mjs` | Seed legend programs (EN/RU/UZ) into `plan_templates` |
| `npx shadcn@latest add <component>` | Add a shadcn/ui component into `src/components/ui/` |
| `./pocketbase/pocketbase serve` / `migrate` | Run / migrate the PocketBase server |

Seed scripts are **resumable** — they cache progress to disk and skip completed records on re-run.

**Lint is not wired up** — there is no ESLint config. TypeScript strict mode (`npm run typecheck`) is the only static gate; run it before declaring work done. Add a flat ESLint config in a follow-up if needed.

## Environment

- `.env.local` (gitignored via `.env*.local`) holds the runtime config. Do **not** commit real backend URLs/keys.
- Client-visible vars: `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_EXERCISEDB_URL`. Any new browser var must be `NEXT_PUBLIC_`-prefixed.
- Server-only: `POCKETBASE_INTERNAL_URL`, `POCKETBASE_ADMIN_EMAIL/PASSWORD`, and AI keys for seed scripts (`GEMINI_API_KEY`, `GROQ_API_KEY`, `CEREBRAS_API_KEY`, etc.).

## Environment & Tooling Gotchas

- **Platform is Windows.** The session shell is PowerShell; Bash (Git Bash) is also available. Use the right syntax for the tool you're calling.
- `.claude/skills/` — read the relevant skill before implementing a feature:
  `brutal-gym-ui/` (UI conventions), `brand-guidelines/` (tone/identity), `program-templates/` (plan data shapes), `session-logging/`, `progress-tracking/`, `api-communication/`, `frontend-design/`.
- `.claude/agents/` — the 6-agent team: `architect`, `frontend-lead`, `frontend-designer`, `frontend-dev`, `program-manager`, `reviewer`.
- Design references: `docs/progress-page-design-spec.md`, `design.md`, `design_handoff_steel_therapy/`.

## Team — 6-Agent Workflow

| Agent | When to Use |
| --- | --- |
| **Architect** | New features, complex changes, specs |
| **Frontend-Lead** | Component architecture, breaking down features |
| **Frontend-Designer** | Distinctive UI, design systems, styling |
| **Frontend-Dev** | Building components, wiring data/hooks |
| **Program-Manager** | Workout programming, progression logic |
| **Reviewer** | Code quality, accessibility, brand — before completion |

Keep active agents to **≤ 5** unless explicitly asked for more. Agents should reference this file and the skills rather than re-explaining rules.

## Working Style

- Be concise but complete; don't repeat what's already in this file or the skills.
- Show diffs / the specific section being changed rather than whole files.
- Prioritize correctness, type safety, accessibility, and distinctive UI over token savings — never trade reasoning or design quality for brevity.
- After a major phase, give a short (≤8 line) summary before moving on.
