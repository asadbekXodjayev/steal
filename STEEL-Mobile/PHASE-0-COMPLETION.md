# Phase 0: Project Setup & Design Tokens - COMPLETE ✅

## Summary

Phase 0 has been completed with all required files for Windows development with Codemagic integration.

---

## Complete Project Structure

```
STEEL-Mobile/
├── STEEL-iOS/                              # iOS SwiftUI Project
│   ├── STEEL-iOS.xcodeproj/                # Xcode project
│   │   └── project.pbxproj
│   └── STEEL-iOS/
│       ├── AppDelegate.swift
│       ├── STEELApp.swift
│       ├── ContentView.swift
│       ├── Info.plist
│       ├── Assets.xcassets/
│       │   ├── Contents.json
│       │   ├── AppIcon.appiconset/
│       │   ├── AccentColor.colorset/
│       │   └── Colors.colorset/
│       ├── Models/                         # 9 Swift Models
│       │   ├── Profiles.swift
│       │   ├── Goals.swift
│       │   ├── Exercise.swift
│       │   ├── WorkoutPlan.swift
│       │   ├── PlanDay.swift
│       │   ├── PlanExercise.swift
│       │   ├── PlanTemplate.swift
│       │   ├── WorkoutSession.swift
│       │   ├── SessionSet.swift
│       │   └── ExerciseTranslation.swift
│       └── DesignSystem/
│           └── Colors.swift                # Design tokens
│
├── STEEL-Android/                          # Android Jetpack Compose Project
│   ├── settings.gradle.kts
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   └── app/
│       ├── build.gradle.kts
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── java/com/steel/steel/
│           │   ├── MainActivity.kt
│           │   ├── models/                 # 9 Kotlin Models
│           │   │   ├── Profile.kt
│           │   │   ├── Goal.kt
│           │   │   ├── Exercise.kt
│           │   │   ├── WorkoutPlan.kt
│           │   │   ├── PlanDay.kt
│           │   │   ├── PlanExercise.kt
│           │   │   ├── PlanTemplate.kt
│           │   │   ├── WorkoutSession.kt
│           │   │   ├── SessionSet.kt
│           │   │   └── ExerciseTranslation.kt
│           │   └── ui/theme/
│           │       ├── Color.kt            # Design tokens
│           │       └── Theme.kt
│           └── res/
│               ├── values/
│               │   ├── strings.xml
│               │   └── themes.xml
│               └── xml/
│                   ├── data_extraction_rules.xml
│                   └── backup_rules.xml
│
├── codemagic.yaml                          # Codemagic CI/CD config
├── setup-phase0.ps1                        # PowerShell setup script
├── PHASE-0-README.md
└── PHASE-0-COMPLETION.md
```

---

## All 9 PocketBase Collections - Models Created

### iOS (Swift) Models - 9 Files

| # | Collection | File | Key Fields |
|---|------------|------|------------|
| 1 | profiles | Profiles.swift | id, user, age, height, weight, gender, fitnessLevel |
| 2 | goals | Goals.swift | id, user, type, environment, equipment, daysPerWeek |
| 3 | exercises | Exercise.swift | id, name, slug, muscleGroups, equipment, category |
| 4 | workout_plans | WorkoutPlan.swift | id, user, title, source, goalType, durationWeeks |
| 5 | plan_days | PlanDay.swift | id, plan, week, dayOfWeek, label, focus |
| 6 | plan_exercises | PlanExercise.swift | id, planDay, exercise, sets, repsMin, repsMax, rpeTarget |
| 7 | workout_sessions | WorkoutSession.swift | id, user, planDay, status, mood, energyLevel |
| 8 | plan_templates | PlanTemplate.swift | id, title, goalType, environment, difficulty, popularity |
| 9 | exercise_translations | ExerciseTranslation.swift | id, exercise, locale, name |

### Android (Kotlin) Models - 9 Files

All 9 models created in `STEEL-Android/app/src/main/java/com/steel/steel/models/` with identical structure using `@Serializable` annotation.

---

## Design Tokens (Military Dark Theme)

### Color Palette - Both Platforms

| Token | Hex | iOS Property | Android Property | Usage |
|-------|-----|--------------|------------------|-------|
| Background | #050505 | `Color.background` | `Background` | Main app background |
| Foreground | #E5E5E5 | `Color.foreground` | `Foreground` | Primary text |
| Primary (Blood Red) | #8B0000 | `Color.primary` | `Primary` | Primary actions, accents |
| Primary Hover | #9F1239 | `Color.primaryHover` | `PrimaryHover` | Hover state |
| Secondary (Orange) | #C2410C | `Color.secondary` | `Secondary` | Secondary actions |
| Secondary Hover | #EA580C | `Color.secondaryHover` | `SecondaryHover` | Hover state |
| Tactical (Green) | #166534 | `Color.tactical` | `Tactical` | Success states |
| Card | #0A0A0A | `Color.card` | `Card` | Card backgrounds |
| Card Border | #1A1A1A | `Color.cardBorder` | `CardBorder` | Card borders |
| Muted Foreground | #A1A1AA | `Color.mutedForeground` | `MutedForeground` | Secondary text |
| Surface 0 | #050505 | `Color.surface0` | `Surface0` | Surface level 0 |
| Surface 1 | #0A0A0A | `Color.surface1` | `Surface1` | Surface level 1 |
| Surface 2 | #111111 | `Color.surface2` | `Surface2` | Surface level 2 |

---

## Exact Commands for Windows

### Prerequisites Check

```powershell
# Check Node.js (for Git Bash)
node --version

# Check Git
git --version

# Check Java (for Android)
java -version

# Check Android Studio installed
# Open Android Studio and verify SDK installed
```

### Initialize Projects

```powershell
# Navigate to project directory
cd C:\Users\hp\Desktop\my-frontend-app\STEEL-Mobile

# Run setup script (PowerShell)
.\setup-phase0.ps1

# OR run in Git Bash
bash setup-phase0.sh
```

### Open Android Studio

```powershell
# Open Android Studio from command line
& "C:\Program Files\Android\Android Studio\bin\studio64.exe" STEEL-Android

# OR open via Start menu:
# 1. Open Android Studio
# 2. File > Open
# 3. Navigate to STEEL-Mobile/STEEL-Android
# 4. Click OK
```

### Build Android (Gradle)

```powershell
# Navigate to Android project
cd STEEL-Android

# Clean build (first time may take 5-10 minutes)
.\gradlew clean assembleDebug

# Build and install on emulator
.\gradlew installDebug

# Run tests
.\gradlew test

# Build release APK
.\gradlew assembleRelease
```

### Git Commands for Codemagic

```powershell
# Navigate to project root
cd C:\Users\hp\Desktop\my-frontend-app\STEEL-Mobile

# Initialize git (if not already)
git init

# Add all files
git add .

# Initial commit
git commit -m "Phase 0: Initial project setup with all models and design tokens"

# Add remote (replace with your GitHub repo)
git remote add origin https://github.com/YOUR_USERNAME/STEEL-Mobile.git

# Push to GitHub
git push -u origin main

# Verify codemagic.yaml is pushed
git status
```

### Codemagic Setup

1. Go to https://codemagic.io/apps
2. Click "Add new app"
3. Select "Import from Git"
4. Choose GitHub repository
5. Select branch (main)
6. Codemagic auto-detects iOS project
7. Verify `codemagic.yaml` is in root
8. Add environment variable: `POCKETBASE_URL`
9. Configure Apple Developer credentials
10. Click "Start building"

---

## Testing Checklist for Phase 0

### Android Testing Checklist

- [ ] Open Android Studio
- [ ] File > Open > Navigate to `STEEL-Mobile/STEEL-Android`
- [ ] Wait for Gradle sync to complete (check bottom status bar)
- [ ] Verify no errors in `build.gradle.kts` files
- [ ] Create/start Android Emulator:
  - [ ] Tools > Device Manager
  - [ ] Create Device: Pixel 6
  - [ ] System Image: API 34 (UpsideDownCake)
  - [ ] Download and start emulator
- [ ] Build project: `Build > Make Project` (Ctrl+F9)
- [ ] Verify build succeeds (no errors in Build tab)
- [ ] Run app: `Run > Run 'app'` (Shift+F10)
- [ ] Verify app launches on emulator
- [ ] Verify splash screen shows:
  - [ ] 💪 Emoji visible
  - [ ] "STEEL" text in blood red (#8B0000)
  - [ ] "FORGES STEEL" text in orange (#C2410C)
- [ ] Verify dark theme applied (black background)
- [ ] Check Logcat for errors:
  - [ ] View > Tool Windows > Logcat
  - [ ] Filter by "STEEL"
  - [ ] No red error messages

### iOS Preparation Checklist (for Codemagic)

- [ ] Verify `codemagic.yaml` exists in root
- [ ] Verify all 9 Swift models exist in `STEEL-iOS/Models/`
- [ ] Verify `Colors.swift` exists in `STEEL-iOS/DesignSystem/`
- [ ] Verify `ContentView.swift` shows correct branding
- [ ] Commit all files to GitHub
- [ ] Push to main branch
- [ ] Verify Codemagic can access repository
- [ ] Configure Apple Developer account in Codemagic
- [ ] Add provisioning profiles
- [ ] Trigger first build in Codemagic

### Model Verification Checklist

- [ ] All 9 iOS Swift models compile without errors
- [ ] All 9 Android Kotlin models compile without errors
- [ ] Models implement `Codable` (iOS) / `@Serializable` (Android)
- [ ] All enum types match PocketBase schema exactly
- [ ] Date fields: `Date` in Swift, `String` in Kotlin (ISO8601)
- [ ] Optional fields marked with `?` (Swift) / `? = null` (Kotlin)

### Design Token Verification Checklist

- [ ] Background color is #050505 (near black)
- [ ] Primary color is #8B0000 (blood red)
- [ ] Secondary color is #C2410C (forged steel orange)
- [ ] Text is readable on dark background
- [ ] No light theme elements visible
- [ ] Colors match between iOS and Android

---

## Files Created - Complete List (44 Total)

### Documentation (3)
1. PHASE-0-README.md
2. PHASE-0-COMPLETION.md
3. codemagic.yaml

### Setup Scripts (1)
4. setup-phase0.ps1

### iOS Files (14)
5. STEEL-iOS.xcodeproj/project.pbxproj
6. STEEL-iOS/AppDelegate.swift
7. STEEL-iOS/STEELApp.swift
8. STEEL-iOS/ContentView.swift
9. STEEL-iOS/Info.plist
10. STEEL-iOS/Assets.xcassets/Contents.json
11. STEEL-iOS/Assets.xcassets/AppIcon.appiconset/Contents.json
12. STEEL-iOS/Assets.xcassets/AccentColor.colorset/Contents.json
13. STEEL-iOS/Assets.xcassets/Colors.colorset/Contents.json
14. STEEL-iOS/Models/Profiles.swift
15. STEEL-iOS/Models/Goals.swift
16. STEEL-iOS/Models/Exercise.swift
17. STEEL-iOS/Models/WorkoutPlan.swift
18. STEEL-iOS/Models/PlanDay.swift
19. STEEL-iOS/Models/PlanExercise.swift
20. STEEL-iOS/Models/PlanTemplate.swift
21. STEEL-iOS/Models/WorkoutSession.swift
22. STEEL-iOS/Models/SessionSet.swift
23. STEEL-iOS/Models/ExerciseTranslation.swift
24. STEEL-iOS/DesignSystem/Colors.swift

### Android Files (22)
25. STEEL-Android/settings.gradle.kts
26. STEEL-Android/build.gradle.kts
27. STEEL-Android/gradle.properties
28. STEEL-Android/app/build.gradle.kts
29. STEEL-Android/app/src/main/AndroidManifest.xml
30. STEEL-Android/app/src/main/res/values/strings.xml
31. STEEL-Android/app/src/main/res/values/themes.xml
32. STEEL-Android/app/src/main/res/xml/data_extraction_rules.xml
33. STEEL-Android/app/src/main/res/xml/backup_rules.xml
34. STEEL-Android/app/src/main/java/com/steel/steel/MainActivity.kt
35. STEEL-Android/app/src/main/java/com/steel/steel/ui/theme/Color.kt
36. STEEL-Android/app/src/main/java/com/steel/steel/ui/theme/Theme.kt
37. STEEL-Android/app/src/main/java/com/steel/steel/models/Profile.kt
38. STEEL-Android/app/src/main/java/com/steel/steel/models/Goal.kt
39. STEEL-Android/app/src/main/java/com/steel/steel/models/Exercise.kt
40. STEEL-Android/app/src/main/java/com/steel/steel/models/WorkoutPlan.kt
41. STEEL-Android/app/src/main/java/com/steel/steel/models/PlanDay.kt
42. STEEL-Android/app/src/main/java/com/steel/steel/models/PlanExercise.kt
43. STEEL-Android/app/src/main/java/com/steel/steel/models/PlanTemplate.kt
44. STEEL-Android/app/src/main/java/com/steel/steel/models/WorkoutSession.kt
45. STEEL-Android/app/src/main/java/com/steel/steel/models/SessionSet.kt
46. STEEL-Android/app/src/main/java/com/steel/steel/models/ExerciseTranslation.kt

---

## Next Steps: Phase 1 - Core & Authentication

When Phase 0 is verified and approved, proceed to:
1. PocketBase SDK integration for both platforms
2. Authentication flow (login/register screens)
3. JWT token management
4. Navigation structure for authenticated app
5. Profile screen with user data

---

## Troubleshooting

### Android Build Issues

```powershell
# Clean Gradle cache
.\gradlew clean

# Delete build folders manually
Remove-Item -Recurse -Force app/build, .gradle, build

# Re-sync Gradle
.\gradlew --refresh-dependencies

# Check Java version
java -version  # Should be Java 17
```

### Codemagic Build Issues

1. Check `codemagic.yaml` indentation (must be valid YAML)
2. Verify Xcode version specified
3. Check Apple Developer credentials in Codemagic settings
4. Verify provisioning profiles are uploaded
5. Check build logs for specific errors

---

## Phase 0 Status: READY FOR TESTING

All files created. Ready for Android Studio build testing and Codemagic iOS build preparation.