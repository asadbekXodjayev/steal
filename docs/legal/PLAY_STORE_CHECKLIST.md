# Google Play — Submission & Moderation Checklist (STEEL)

This is the actionable checklist to get STEEL through Play review. Items marked
**[CODE ✅]** are already done in this repo. Items marked **[YOU]** require your
input/action in the Play Console or hosting.

---

## 0. Before you build the release

**[YOU] Replace placeholders:**
- `lib/core/legal_links.dart` → set real `privacyPolicyUrl`, `termsOfUseUrl`,
  `accountDeletionUrl`, `supportEmail`, `developerName`.
- `docs/legal/PRIVACY_POLICY.md` and `TERMS_OF_USE.md` → fill `[EFFECTIVE_DATE]`,
  `[DEVELOPER_NAME]`, `[YOUR_EMAIL]`, `[PRIVACY_URL]`, `[ACCOUNT_DELETION_URL]`,
  `[JURISDICTION]`. Host both at public **HTTPS** URLs.
- `android/key.properties` → the keystore password is currently the placeholder
  `ChangeMe_Steel#2026`. **Change it** (and re-create the keystore) if you want a
  password only you know — see §2.

---

## 1. Signing  **[CODE ✅ / YOU back up keystore]**
- A release keystore was generated at `android/app/upload-keystore.jks` and wired
  via `android/key.properties` + `android/app/build.gradle.kts`
  (`signingConfigs.release`). Release builds are no longer debug‑signed.
- **[YOU] Critical:** back up `upload-keystore.jks` **and** the passwords in a safe
  place. If you lose them you cannot update the app (unless using Play App Signing
  key reset). Both files are gitignored — they are NOT in version control.
- **[YOU] Enroll in Play App Signing** (default for new apps). Upload key = this
  keystore; Google manages the app signing key.

## 2. Build the upload artifact  **[YOU run]**
Play requires an **Android App Bundle (.aab)** for new apps:
```
cd steel_flutter
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```
(An APK is fine for sideloading/testing: `flutter build apk --release`.)

## 3. Network security / cleartext  **[CODE ✅ / YOU recommended]**
- Cleartext HTTP is now blocked by default and permitted **only** for the
  backend host `34.56.67.158` via
  `android/app/src/main/res/xml/network_security_config.xml`. The blanket
  `usesCleartextTraffic="true"` was removed.
- **[YOU] Strongly recommended:** move the PocketBase backend behind **HTTPS**
  (e.g. a domain + TLS / reverse proxy). Then set the domain's cleartext flag to
  `false` (or remove it) and update `SteelPocketBase._defaultBaseUrl`. Cleartext
  to a raw IP is the single biggest remaining security flag in Google's scan.

## 4. Permissions  **[CODE ✅]**
- Only `INTERNET` is requested. No sensitive permissions → minimal review risk.

## 5. Account creation & deletion  **[CODE ✅ / YOU host URL]**
Google requires apps with account sign‑up to offer account deletion **in‑app**
and via a **public web URL**.
- In‑app: Settings (Gear) → **Delete account** → confirms → permanently deletes
  the PocketBase user + data, then signs out. **[CODE ✅]**
- **[YOU]** Publish a public deletion page at `accountDeletionUrl` describing the
  steps + the support email, and enter that URL in the Play Console
  ("App content → Data deletion").

## 6. Privacy Policy  **[CODE ✅ doc / YOU host + enter URL]**
- Full policy in `docs/legal/PRIVACY_POLICY.md`. **[YOU]** host it (HTTPS) and put
  the URL in Play Console → "Store listing → Privacy policy" AND in‑app it's
  linked from Settings + the registration consent.

## 7. Registration consent  **[CODE ✅]**
- The Create‑Account screen requires a checkbox accepting the Terms + Privacy
  Policy (links open the hosted docs) before the button enables.

## 8. Data Safety form  **[YOU fill — answers below]**
In Play Console → "App content → Data safety", declare:

| Data type | Collected? | Shared? | Purpose | Optional? |
|---|---|---|---|---|
| Email address | Yes | No | Account management | Required |
| Password / credentials | Yes | No | Account management, security | Required |
| Health & fitness info (workouts, body metrics: weight/height/age/gender, injuries) | Yes | No | App functionality (core feature) | Required for core use |
| App activity (in‑app content you create) | Yes | No | App functionality | Required |
| Approximate technical/diagnostic (IP via requests) | Processed, not collected for tracking | No | App functionality / security | n/a |

Also declare:
- **Data is encrypted in transit?** Partially — HTTPS for media/fonts; the
  backend is currently HTTP to one host. (Be truthful. Fixing §3 lets you answer
  "Yes".)
- **Users can request data deletion?** **Yes** — in‑app + web URL (§5).
- **No data shared with third parties** for advertising. ExerciseDB/Google Fonts
  receive only technical request data, not your profile.
- **No advertising / no third‑party analytics SDKs.**

## 9. Content rating  **[YOU]**
- Complete the IARC questionnaire. STEEL has no objectionable content → expect
  "Everyone / PEGI 3". The brand uses mild gym slang ("No Bullshit Tracking") —
  if you keep such copy, answer the language question honestly; consider toning
  store‑listing copy to avoid a higher rating.

## 10. Target audience & ads  **[YOU]**
- Target audience: adults (13+). Not designed for children.
- Declare **No ads**.

## 11. Store listing assets  **[YOU]**
- App icon (512×512), feature graphic (1024×500), ≥2 phone screenshots, short +
  full description (avoid profanity to keep the rating low), category: Health &
  Fitness.

## 12. Health app note  **[YOU]**
- STEEL is fitness, not a medical/health‑records app, so Google's Health Apps
  declaration generally does not apply — but it does **not** claim to diagnose or
  treat. The Terms include a health/safety disclaimer (`TERMS_OF_USE.md §3`).

## 13. Pre‑launch report  **[YOU]**
- Upload to a **Closed/Internal testing** track first; review the Pre‑launch
  report (security + stability). Address any flagged items (the cleartext warning
  will appear until §3's HTTPS migration).

---

## Summary of what's already handled in code
- ✅ Release signing keystore + Gradle signing config (no more debug keys)
- ✅ Network security config scoping cleartext to one host; blanket flag removed
- ✅ Only INTERNET permission
- ✅ In‑app account deletion (PocketBase user + data) with confirmation
- ✅ Privacy Policy + Terms documents (placeholders to fill)
- ✅ In‑app links to Privacy/Terms/Contact + app version (Settings)
- ✅ Registration consent checkbox gating account creation
- ✅ en/ru/uz localization of all compliance UI

## What only you can do
- Replace placeholders (URLs, email, developer name, dates) and **host** the two
  legal docs + the deletion page over HTTPS.
- Back up the keystore + passwords; enroll in Play App Signing.
- Build the `.aab`, fill Data Safety + content rating + target audience, upload
  store assets, and (recommended) migrate the backend to HTTPS.
