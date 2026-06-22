# Technical Specification — Automated Test Harness (v0)

**Project:** Steal Therapy (Next.js 15 / React 19 / TS-strict)
**Version:** 0.1 · **Date:** 2026-06-22 · **Status:** Awaiting approval (build gate)

---

## 1. Overview

The app currently has **zero automated tests**; the only static gate is `tsc --noEmit`. This spec defines a minimal, fast, extensible **Vitest + React Testing Library** harness whose v0 covers the highest-signal *pure logic* (volume/1RM math, progression, plan renewal, translation key resolution) plus one smoke component test — establishing a reusable testing pattern so future changes can be verified without manually re-running the app.

## 2. Problem & Users

- **Problem (today):** Logic that `tsc` cannot protect ships unverified — translation key resolution + the `i18n-additions` deep-merge, week-progression, plan-renewal, and the volume/1RM formulas. Regressions are only caught by manually running the app.
- **Primary user:** the developer (and the Claude agents working in this repo). They want a safety net that lets them refactor and ship without manual re-verification.
- **Why now:** two features just shipped (translations to 100%, stats→profile merge) with subtle logic and no tests guarding them. The cost of a regression net is lowest before the surface grows further.

## 3. Goals & Non-Goals

**Goals**
- `npm run test` runs green in **< ~5 s** on a clean checkout with **no `.env.local` and no network**.
- First suite covers the pure-logic regression class that hurts most (math, progression, renewal, i18n resolution).
- Adding a new test is **trivial** — a documented `renderWithProviders` helper + PocketBase mock exist so no test re-invents setup.
- React 19 + RTL render path is proven by one smoke component test.

**Non-Goals (v-next)**
- Mocked-hook tests (`useProgress` no-filter quirk, `useExerciseTranslation`).
- Playwright E2E against the running app + seeded PocketBase.
- CI gate (GitHub Actions) and coverage thresholds.
- Tests for RSC/server components or the `/pb` proxy rewrite.

## 4. Scope

**v0 / MVP**
- Dev-dependencies: `vitest`, `@vitejs/plugin-react`, `jsdom`, `vite-tsconfig-paths`, `@testing-library/react` (v16+, React 19-compatible), `@testing-library/jest-dom`, `@testing-library/user-event`.
- `vitest.config.ts` — `jsdom` env, `vite-tsconfig-paths` (resolves `@/*`), `setupFiles`, `globals: true`.
- `src/test/setup.ts` — imports `@testing-library/jest-dom`, auto-cleanup.
- `src/test/utils.tsx` — `renderWithProviders()` wrapping a fresh `QueryClient` (+ I18n provider) and a minimal PocketBase mock factory.
- `package.json` scripts: `test` (run once), `test:watch`, `test:ui` (optional).
- Pure-logic test suites (co-located `*.test.ts`):
  - `src/lib/utils.test.ts` — `estimate1RM`, `calculateVolume`, `formatWeight`, `formatDuration`, `formatDate`/`formatRelativeDate`.
  - `src/lib/progression.test.ts` — progression rules.
  - `src/lib/plan-renewal.test.ts` — renewal logic.
  - `src/lib/translations.test.ts` — `t()` key resolution + `i18n-additions` deep-merge (en/ru/uz), including a missing-key fallback case.
- One smoke component test (e.g. `PanelHeader` from `ProgressDashboard`, or a small UI primitive) via `renderWithProviders`.
- Short "Testing" note appended to `CLAUDE.md` documenting the command + the add-a-test pattern.

**Later (v-next):** see Non-Goals — mocked-hook tests, E2E, CI gate, coverage.

## 5. Core Mechanic & Approach

- **Runner:** Vitest (not Jest). Rationale: native ESM + TS, no Babel/CJS transform fight with Next 15 / `@ai-sdk` ESM-only deps, fast watch mode, Vite resolver gives `@/*` via `vite-tsconfig-paths`.
- **Environment:** `jsdom` for component rendering; pure-logic suites need no DOM.
- **Determinism:** date-formatting tests pass a fixed ISO string (and pin TZ where needed) so `formatRelativeDate` etc. don't flake across machines/timezones.
- **Isolation:** the PocketBase singleton (`src/lib/pocketbase.ts`) and TanStack Query are mocked/provided via `src/test/utils.tsx`; **no test touches the network or env**.
- **Convention:** tests co-located as `<source>.test.ts(x)` next to the unit under test.

## 6. Architecture

```
src/
├── test/
│   ├── setup.ts          # jest-dom matchers + RTL cleanup (loaded via setupFiles)
│   └── utils.tsx         # renderWithProviders(), createMockPB()
├── lib/
│   ├── utils.test.ts
│   ├── progression.test.ts
│   ├── plan-renewal.test.ts
│   └── translations.test.ts
└── components/progress/
    └── PanelHeader.test.tsx   # smoke render (or chosen primitive)
vitest.config.ts          # jsdom, tsconfigPaths, setupFiles, globals
```

- **Tech choices:** Vitest + RTL v16 (React 19 support) + jsdom + vite-tsconfig-paths. No change to app runtime deps.
- **No new data model.** Mocks return shapes already defined in `src/types/*`.
- **External integrations:** none — the harness is fully local.

## 7. User Flows (developer-facing)

1. **Run once:** `npm run test` → all suites green in seconds; non-zero exit on failure.
2. **TDD loop:** `npm run test:watch` → edit a `lib/*` function → see the co-located test re-run instantly.
3. **Add a test:** copy a `*.test.ts` next to the new code; for components, import `renderWithProviders` from `@/test/utils`.
4. **Edge:** a date/formatting test must remain deterministic regardless of the machine's timezone (fixed input + pinned TZ).

## 8. Acceptance Criteria

- [ ] `npm run test` exits 0 with **no `.env.local` present** and **no network access**.
- [ ] Full v0 suite completes in **< ~5 s** locally.
- [ ] `estimate1RM` and `calculateVolume` have tests asserting exact known values (incl. edge: 0 reps / 0 weight).
- [ ] `translations` test proves a key resolves correctly in en/ru/uz **and** that an `i18n-additions` key overrides/extends the base via deep-merge.
- [ ] `progression` and `plan-renewal` each have ≥1 test on their core branch logic.
- [ ] The smoke component test renders via `renderWithProviders` and asserts on visible text (proves RTL + React 19 path).
- [ ] `typecheck` still passes; no app runtime code changed.
- [ ] `CLAUDE.md` documents the test command + add-a-test pattern.

## 9. Testing & Safety

- **Correctness:** authored under `test-driven-development`; verified green under `verification-before-completion` (the harness must actually run, not be stubbed/skipped).
- **Safety/quality:** tests are hermetic — no network, no real PocketBase, no secrets. PB is mocked; Query gets a throwaway client. No prod data touched. Deterministic by construction (fixed dates/inputs).
- **Failure modes designed out:** (a) env/network dependence → forbidden in v0; (b) timezone flakiness → fixed inputs + pinned TZ; (c) React-19/RTL incompat → pin `@testing-library/react` ≥16.

## 10. Risks, Assumptions & Open Questions

- **Assumption:** `lib/progression.ts` and `lib/plan-renewal.ts` are pure (no PB/IO). *If wrong* → extract the pure core or move that file's tests to v-next (mocked); does not block the rest.
- **Assumption:** `@testing-library/react` ≥16 cleanly supports React 19 in jsdom. *Mitigation:* the smoke test validates this on day one; if it fails, fix versions before expanding.
- **Risk:** `vite-tsconfig-paths` must mirror the `@/*` alias for imports to resolve. *Mitigation:* the first run surfaces this immediately.
- **Open:** exact smoke-test target (`PanelHeader` vs a `components/ui` primitive) — decided during build based on which renders with the least provider surface.

## 11. Milestones (build order)

1. Install dev-deps; add `vitest.config.ts` + `src/test/setup.ts`; add `test`/`test:watch` scripts.
2. Write `src/lib/utils.test.ts`; get the first suite green (proves runner + paths).
3. Add `src/test/utils.tsx` (`renderWithProviders` + PB mock); write the smoke component test (proves RTL/React 19).
4. Add `translations.test.ts` (resolution + deep-merge), then `progression.test.ts` + `plan-renewal.test.ts`.
5. Run full suite under `verification-before-completion`; document the pattern in `CLAUDE.md`.
