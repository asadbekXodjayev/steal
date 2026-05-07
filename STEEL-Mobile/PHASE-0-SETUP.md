# STEEL-Mobile — Phase 0: Project Setup & Design Tokens

## Overview

This document provides the complete setup instructions for building native iOS (SwiftUI + SwiftData) and Android (Jetpack Compose + Room) mobile apps for STEAL (Steal Forges Steel) — a brutal industrial powerlifting fitness app.

**Tech Stack:**
- **iOS:** Swift 6 + SwiftUI + SwiftData
- **Android:** Kotlin 2.0 + Jetpack Compose + Room
- **Shared:** Kotlin Multiplatform (KMP) for data models and sync logic
- **Backend:** PocketBase (9 collections)

---

## PocketBase Collections Summary

| Collection | ID | Type | Purpose |
|------------|-----|------|---------|
| users | _pb_users_auth_ | auth | User authentication |
| profiles | profiles001 | base | User profile data (age, height, weight, fitness level) |
| goals | goals0001 | base | User fitness goals |
| exercises | exercises01 | base | Exercise library |
| workout_plans | wrkplans01 | base | User workout plans |
| plan_days | plandays01 | base | Plan day structure |
| plan_exercises | planexs001 | base | Exercises within plan days |
| plan_templates | pltmpls01 | base | Pre-made plan templates |
| workout_sessions | wrksess01 | base | Session logging |
| session_sets | sesssets01 | base | Individual set data |
| exercise_translations | extlts01 | base | Exercise name translations |

---

## Design Tokens (Matching Web App)

### Color Palette — Dark Mode (Primary)

```
/* Core Backgrounds — Void darkness */
--background: #050505
--background-secondary: #0a0a0a
--foreground: #E5E5E5

/* Card surfaces — cold steel plates */
--card: #0a0a0a
--card-foreground: #E5E5E5
--card-border: #1a1a1a
--card-border-hover: #2a2a2a

/* Primary accent — DEEP BLOOD RED / RUST */
--primary: #8B0000
--primary-hover: #9F1239
--primary-active: #B91C1C
--primary-foreground: #ffffff
--primary-glow: rgba(139, 0, 0, 0.3)

/* Secondary accent — FORGED STEEL ORANGE */
--secondary: #C2410C
--secondary-hover: #EA580C
--secondary-active: #F97316
--secondary-foreground: #ffffff

/* Muted elements — dark steel gray */
--muted: #1a1a1a
--muted-foreground: #a1a1aa
--muted-foreground-hover: #d4d4d8

/* Status colors */
--success: #C2410C
--warning: #854d0e
--destructive: #7f1d1d

/* Tactical (military olive) */
--tactical: #166534
--tactical-hover: #15803d
--tactical-dim: #14532d

/* Text hierarchy */
--ink-high: #E5E5E5
--ink-mid: #c9c9c9
--ink-low: #a1a1aa
--ink-dim: #737373

/* Surfaces */
--surface-0: #050505
--surface-1: #0A0A0A
--surface-2: #111111
--surface-3: #171717
--surface-4: #1F1F1F
```

### Typography

```
/* Font stack */
--font-heading: 'Barlow Condensed', sans-serif
--font-body: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif
--font-mono: 'JetBrains Mono', 'Fira Code', monospace

/* Letter spacing */
--tracking-tight: -0.02em
--tracking-normal: 0
--tracking-wide: 0.05em
--tracking-widest: 0.15em (for labels)
```

### Spacing Scale

```
--space-1: 0.25rem (4px)
--space-2: 0.5rem (8px)
--space-3: 0.75rem (12px)
--space-4: 1rem (16px)
--space-5: 1.25rem (20px)
--space-6: 1.5rem (24px)
--space-8: 2rem (32px)
--space-10: 2.5rem (40px)
--space-12: 3rem (48px)
```

### Border Radius

```
/* Brutal industrial aesthetic — sharp edges */
--radius-none: 0px
--radius-sm: 0px
--radius-md: 0px
--radius-lg: 0px
--radius-xl: 0px
```

### Animation Timing

```
--transition-page: transform 0.12s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.12s cubic-bezier(0.16, 1, 0.3, 1)
--transition-fast: all 0.08s ease
--transition-bounce: all 0.15s cubic-bezier(0.34, 1.56, 0.64, 1)
```

---

## Project Structure

```
STEEL-Mobile/
├── README.md
├── package.json
├── pnpm-workspace.yaml
├── .gitignore
├── docs/
│   ├── ARCHITECTURE.md
│   ├── API.md
│   └── SETUP.md
├── shared/
│   ├── build.gradle.kts
│   ├── src/
│   │   ├── commonMain/
│   │   │   ├── kotlin/
│   │   │   │   └── com/
│   │   │   │       └── steel/
│   │   │   │           ├── models/
│   │   │   │           │   ├── User.kt
│   │   │   │           │   ├── Profile.kt
│   │   │   │           │   ├── Goal.kt
│   │   │   │           │   ├── Exercise.kt
│   │   │   │           │   ├── WorkoutPlan.kt
│   │   │   │           │   ├── PlanDay.kt
│   │   │   │           │   ├── PlanExercise.kt
│   │   │   │           │   ├── PlanTemplate.kt
│   │   │   │           │   ├── WorkoutSession.kt
│   │   │   │           │   ├── SessionSet.kt
│   │   │   │           │   └── ExerciseTranslation.kt
│   │   │   │           ├── api/
│   │   │   │           │   ├── PocketBaseClient.kt
│   │   │   │           │   └── endpoints/
│   │   │   │           ├── sync/
│   │   │   │           │   ├── SyncManager.kt
│   │   │   │           │   └── OfflineQueue.kt
│   │   │   │           └── utils/
│   │   │   │               └── Result.kt
│   │   ├── androidMain/
│   │   │   └── kotlin/
│   │   │       └── com/
│   │   │           └── steel/
│   │   │               └── Platform.android.kt
│   │   └── iosMain/
│   │       └── kotlin/
│   │           └── com/
│   │               └── steel/
│   │                   └── Platform.ios.kt
│   └── shared.podspec
├── ios-app/
│   ├── STEAL/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   ├── Colors.xcassets/
│   │   │   └── Images.xcassets/
│   │   ├── Preview Content/
│   │   ├── Models/
│   │   │   ├── CoreDataModels/
│   │   │   │   └── STEALDataModel.swiftmodel
│   │   │   └── DomainModels/
│   │   ├── Services/
│   │   │   ├── PocketBaseService.swift
│   │   │   ├── SyncService.swift
│   │   │   └── OfflineQueueService.swift
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   │   ├── Components/
│   │   │   ├── Screens/
│   │   │   │   ├── Auth/
│   │   │   │   ├── Dashboard/
│   │   │   │   ├── Plans/
│   │   │   │   ├── Sessions/
│   │   │   │   ├── Progress/
│   │   │   │   └── Profile/
│   │   │   └── DesignSystem/
│   │   │       ├── Colors.swift
│   │   │       ├── Typography.swift
│   │   │       ├── Spacing.swift
│   │   │       └── Animations.swift
│   │   └── STEALApp.swift
│   ├── STEALTests/
│   └── STEALUITests/
├── android-app/
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── settings.gradle.kts
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml
│   │       │   ├── java/com/steel/
│   │       │   │   ├── SteelApplication.kt
│   │       │   │   ├── MainActivity.kt
│   │       │   │   ├── data/
│   │       │   │   │   ├── local/
│   │       │   │   │   │   ├── AppDatabase.kt
│   │       │   │   │   │   ├── dao/
│   │       │   │   │   │   │   ├── UserDao.kt
│   │       │   │   │   │   │   ├── ProfileDao.kt
│   │       │   │   │   │   │   ├── ExerciseDao.kt
│   │       │   │   │   │   │   ├── WorkoutPlanDao.kt
│   │       │   │   │   │   │   └── SessionDao.kt
│   │       │   │   │   │   └── entity/
│   │       │   │   │   │       ├── UserEntity.kt
│   │       │   │   │   │       ├── ProfileEntity.kt
│   │       │   │   │   │       └── ...
│   │       │   │   │   ├── remote/
│   │       │   │   │   │   ├── PocketBaseApi.kt
│   │       │   │   │   │   └── dto/
│   │       │   │   │   ├── repository/
│   │       │   │   │   │   └── ...
│   │       │   │   │   └── sync/
│   │       │   │   │       └── SyncWorker.kt
│   │       │   │   ├── domain/
│   │       │   │   │   ├── model/
│   │       │   │   │   └── repository/
│   │       │   │   ├── ui/
│   │       │   │   │   ├── theme/
│   │       │   │   │   │   ├── Color.kt
│   │       │   │   │   │   ├── Theme.kt
│   │       │   │   │   │   ├── Type.kt
│   │       │   │   │   │   └── Spacing.kt
│   │       │   │   │   ├── components/
│   │       │   │   │   └── screens/
│   │       │   │   │       ├── auth/
│   │       │   │   │       ├── dashboard/
│   │       │   │   │       ├── plans/
│   │       │   │   │       ├── sessions/
│   │       │   │   │       ├── progress/
│   │       │   │   │       └── profile/
│   │       │   │   └── navigation/
│   │       │   │       └── NavGraph.kt
│   │       └── test/
│   └── gradle/
│       └── wrapper/
└── scripts/
    ├── generate-models.sh
    └── sync-pocketbase-schema.sh
```

---

## Setup Commands

### Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js (LTS)
brew install node@20

# Install pnpm
npm install -g pnpm

# Install Kotlin Multiplatform Mobile plugin via IntelliJ IDEA or Android Studio

# Install Xcode (macOS only)
# Download from Mac App Store, then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Install CocoaPods
sudo gem install cocoapods

# Install Android Studio
# Download from https://developer.android.com/studio
# Install: Android SDK, Kotlin plugin, Compose Compiler

# Set up Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Clone and Setup Monorepo

```bash
# Create project directory
mkdir -p ~/Projects/STEEL-Mobile
cd ~/Projects/STEEL-Mobile

# Initialize git repo
git init
git add .
git commit -m "Initial commit: STEEL-Mobile monorepo structure"

# Create workspace files
```

### Create Root Package.json

```json
{
  "name": "steel-mobile",
  "version": "0.1.0",
  "private": true,
  "description": "STEAL Fitness Mobile App — iOS + Android with PocketBase",
  "scripts": {
    "ios": "cd ios-app && xcodebuild -scheme STEAL -destination 'platform=iOS Simulator,name=iPhone 15'",
    "android": "cd android-app && ./gradlew installDebug",
    "shared:build": "cd shared && ./gradlew build",
    "shared:iosX64": "cd shared && ./gradlew iosX64",
    "shared:iosArm64": "cd shared && ./gradlew iosArm64",
    "shared:android": "cd shared && ./gradlew assembleDebug",
    "clean": "rm -rf ios-app/build android-app/.gradle shared/build"
  },
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=8.0.0"
  }
}
```

### Create pnpm-workspace.yaml

```yaml
packages:
  - 'shared'
  - 'ios-app'
  - 'android-app'
```

---

## Shared KMP Module Setup

### shared/build.gradle.kts

```kotlin
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTargetWithSimulatorTests

plugins {
    kotlin("multiplatform") version "2.0.21"
    kotlin("plugin.serialization") version "2.0.21"
    id("com.android.library") version "8.2.0"
    id("org.jetbrains.kotlinx.kover") version "0.8.3"
}

kotlin {
    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
            isStatic = true
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
            implementation("io.ktor:ktor-client-core:3.0.1")
            implementation("io.ktor:ktor-client-content-negotiation:3.0.1")
            implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.1")
        }
        
        commonTest.dependencies {
            implementation(kotlin("test"))
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
        }
        
        androidMain.dependencies {
            implementation("io.ktor:ktor-client-android:3.0.1")
        }
        
        iosMain.dependencies {
            implementation("io.ktor:ktor-client-darwin:3.0.1")
        }
    }
}

android {
    namespace = "com.steel.shared"
    compileSdk = 34
    
    defaultConfig {
        minSdk = 24
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
```

---

## iOS App Setup

### Xcode Project Configuration

1. **Create new Xcode project:**
```bash
cd ios-app
# Open Xcode → Create new project → iOS App → SwiftUI
# Product Name: STEAL
# Team: (your team)
# Organization: Steel Fitness
# Interface: SwiftUI
# Language: Swift
```

2. **Enable capabilities:**
   - Background Modes → Background fetch
   - Push Notifications (for Phase 5)
   - HealthKit (optional, Phase 5)

3. **Add PocketBase Swift SDK:**
```ruby
# ios-app/STEAL.xcworkspace/xcshareddata/swiftpm/Package.swift
dependencies: [
    .package(url: "https://github.com/pocketbase/pocketbase", from: "0.21.0")
]
```

### Design System Implementation

```swift
// iOS/STEAL/Views/DesignSystem/Colors.swift
import SwiftUI

extension Color {
    // Core Backgrounds
    static let background = Color("background")
    static let backgroundSecondary = Color("background-secondary")
    static let foreground = Color("foreground")
    
    // Cards
    static let card = Color("card")
    static let cardForeground = Color("card-foreground")
    static let cardBorder = Color("card-border")
    static let cardBorderHover = Color("card-border-hover")
    
    // Primary (Blood Red)
    static let primary = Color("primary")
    static let primaryHover = Color("primary-hover")
    static let primaryActive = Color("primary-active")
    static let primaryForeground = Color("primary-foreground")
    static let primaryGlow = Color("primary-glow")
    
    // Secondary (Forged Steel Orange)
    static let secondary = Color("secondary")
    static let secondaryHover = Color("secondary-hover")
    static let secondaryActive = Color("secondary-active")
    static let secondaryForeground = Color("secondary-foreground")
    
    // Muted
    static let muted = Color("muted")
    static let mutedForeground = Color("muted-foreground")
    
    // Tactical (Military Green)
    static let tactical = Color("tactical")
    static let tacticalHover = Color("tactical-hover")
    
    // Ink (Text hierarchy)
    static let inkHigh = Color("ink-high")
    static let inkMid = Color("ink-mid")
    static let inkLow = Color("ink-low")
    static let inkDim = Color("ink-dim")
    
    // Surfaces
    static let surface0 = Color("surface-0")
    static let surface1 = Color("surface-1")
    static let surface2 = Color("surface-2")
    static let surface3 = Color("surface-3")
    static let surface4 = Color("surface-4")
}
```

---

## Android App Setup

### Android Studio Project

1. **Create new project:**
   - File → New → New Project
   - Select "Empty Compose Activity"
   - Name: STEAL
   - Package name: com.steel
   - Language: Kotlin
   - Minimum SDK: 24 (Android 7.0)

2. **Add dependencies (app/build.gradle.kts):**
```kotlin
dependencies {
    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.8.3")
    
    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")
    
    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    annotationProcessor("androidx.room:room-compiler:2.6.1")
    
    // KMP Shared Module
    implementation(project(":shared"))
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    
    // Ktor
    implementation("io.ktor:ktor-client-android:3.0.1")
}
```

### Design System Implementation

```kotlin
// android-app/app/src/main/java/com/steel/ui/theme/Color.kt
package com.steel.ui.theme

import androidx.compose.ui.graphics.Color

// Core Backgrounds
val Background = Color(0xFF050505)
val BackgroundSecondary = Color(0xFF0A0A0A)
val Foreground = Color(0xFFE5E5E5)

// Cards
val Card = Color(0xFF0A0A0A)
val CardForeground = Color(0xFFE5E5E5)
val CardBorder = Color(0xFF1A1A1A)
val CardBorderHover = Color(0xFF2A2A2A)

// Primary (Blood Red)
val Primary = Color(0xFF8B0000)
val PrimaryHover = Color(0xFF9F1239)
val PrimaryActive = Color(0xFFB91C1C)
val PrimaryForeground = Color(0xFFFFFFFF)

// Secondary (Forged Steel Orange)
val Secondary = Color(0xFFC2410C)
val SecondaryHover = Color(0xFFEA580C)
val SecondaryActive = Color(0xFFF97316)
val SecondaryForeground = Color(0xFFFFFFFF)

// Muted
val Muted = Color(0xFF1A1A1A)
val MutedForeground = Color(0xFFA1A1AA)

// Tactical (Military Green)
val Tactical = Color(0xFF166534)
val TacticalHover = Color(0xFF15803D)

// Ink (Text hierarchy)
val InkHigh = Color(0xFFE5E5E5)
val InkMid = Color(0xFFC9C9C9)
val InkLow = Color(0xFFA1A1AA)
val InkDim = Color(0xFF737373)

// Surfaces
val Surface0 = Color(0xFF050505)
val Surface1 = Color(0xFF0A0A0A)
val Surface2 = Color(0xFF111111)
val Surface3 = Color(0xFF171717)
val Surface4 = Color(0xFF1F1F1F)
```

---

## Data Models (Common)

### User Model

```kotlin
// shared/src/commonMain/kotlin/com/steel/models/User.kt
package com.steel.models

import kotlinx.serialization.Serializable

@Serializable
data class User(
    val id: String,
    val email: String,
    val name: String? = null,
    val avatar: String? = null,
    val created: String,
    val updated: String,
    
    // Auth-specific
    val emailVisibility: Boolean = false,
    val verified: Boolean = false
)
```

### Profile Model

```kotlin
// shared/src/commonMain/kotlin/com/steel/models/Profile.kt
package com.steel.models

import kotlinx.serialization.Serializable

@Serializable
data class Profile(
    val id: String,
    val user: String,
    val age: Int? = null,
    val height: Int? = null,      // cm
    val weight: Double? = null,   // kg
    val gender: Gender? = null,
    val fitnessLevel: FitnessLevel? = null,
    val limitations: List<String>? = null,
    val injuryHistory: String? = null,
    val onboardingComplete: Boolean = false,
    val created: String,
    val updated: String
)

@Serializable
enum class Gender {
    male, female, other, prefer_not_to_say
}

@Serializable
enum class FitnessLevel {
    beginner, intermediate, advanced
}
```

### Exercise Model

```kotlin
// shared/src/commonMain/kotlin/com/steel/models/Exercise.kt
package com.steel.models

import kotlinx.serialization.Serializable

@Serializable
data class Exercise(
    val id: String,
    val name: String,
    val slug: String,
    val muscleGroups: List<String>? = null,
    val equipment: List<String>? = null,
    val category: ExerciseCategory? = null,
    val difficulty: ExerciseDifficulty? = null,
    val instructions: String? = null,
    val videoUrl: String? = null,
    val created: String,
    val updated: String
)

@Serializable
enum class ExerciseCategory {
    compound, isolation, cardio, mobility, warmup, cooldown
}

@Serializable
enum class ExerciseDifficulty {
    beginner, intermediate, advanced
}
```

### Workout Session Model

```kotlin
// shared/src/commonMain/kotlin/com/steel/models/WorkoutSession.kt
package com.steel.models

import kotlinx.serialization.Serializable

@Serializable
data class WorkoutSession(
    val id: String,
    val user: String,
    val planDay: String? = null,
    val plan: String? = null,
    val startedAt: String? = null,
    val completedAt: String? = null,
    val status: SessionStatus = SessionStatus.IN_PROGRESS,
    val mood: SessionMood? = null,
    val energyLevel: Int? = null,  // 1-5
    val sessionNotes: String? = null,
    val therapyReflection: String? = null,
    val created: String,
    val updated: String
)

@Serializable
enum class SessionStatus {
    in_progress, completed, skipped
}

@Serializable
enum class SessionMood {
    great, good, okay, rough, terrible
}
```

### Session Set Model

```kotlin
// shared/src/commonMain/kotlin/com/steel/models/SessionSet.kt
package com.steel.models

import kotlinx.serialization.Serializable

@Serializable
data class SessionSet(
    val id: String,
    val session: String,
    val exercise: String? = null,
    val setNumber: Int? = null,
    val reps: Int? = null,
    val weight: Double? = null,   // kg
    val rpe: Double? = null,      // 1-10
    val completed: Boolean = false,
    val notes: String? = null,
    val created: String,
    val updated: String
)
```

---

## PocketBase API Client

```kotlin
// shared/src/commonMain/kotlin/com/steel/api/PocketBaseClient.kt
package com.steel.api

import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class PocketBaseClient(baseUrl: String) {
    
    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
            })
        }
    }
    
    private val apiUrl = baseUrl.trimEnd('/')
    
    // Auth
    suspend fun login(email: String, password: String): AuthResponse {
        return client.post("$apiUrl/api/auths/auth-with-password") {
            setBody(mapOf("identity" to email, "password" to password))
        }.body()
    }
    
    suspend fun logout() {
        token = null
    }
    
    // Generic CRUD
    suspend fun <T> get(collection: String, id: String): T {
        return client.get("$apiUrl/api/collections/$collection/$id").body()
    }
    
    suspend fun <T> getAll(collection: String, filter: String? = null): List<T> {
        val url = if (filter != null) {
            "$apiUrl/api/collections/$collection?filter=$filter"
        } else {
            "$apiUrl/api/collections/$collection"
        }
        return client.get(url).body()
    }
    
    suspend fun <T> create(collection: String, data: Any): T {
        return client.post("$apiUrl/api/collections/$collection") {
            setBody(data)
        }.body()
    }
    
    suspend fun <T> update(collection: String, id: String, data: Any): T {
        return client.patch("$apiUrl/api/collections/$collection/$id") {
            setBody(data)
        }.body()
    }
    
    suspend fun delete(collection: String, id: String) {
        client.delete("$apiUrl/api/collections/$collection/$id")
    }
    
    // Auth token management
    var token: String? = null
        set(value) {
            field = value
            if (value != null) {
                client.requestBuilder {
                    headers.set("Authorization", value)
                }
            }
        }
}

data class AuthResponse(
    val token: String,
    val record: User
)
```

---

## Setup Script

```bash
#!/bin/bash
# scripts/setup.sh

set -e

echo "🔧 Setting up STEEL-Mobile..."

# Create directories
mkdir -p shared/src/commonMain/kotlin/com/steel/{models,api,sync,utils}
mkdir -p shared/src/androidMain/kotlin/com/steel
mkdir -p shared/src/iosMain/kotlin/com/steel
mkdir -p ios-app/STEAL/{Models,Services,ViewModels,Views/{Components,Screens,DesignSystem}}
mkdir -p android-app/app/src/main/java/com/steel/{data,ui/{theme,components,screens}}
mkdir -p docs

echo "✅ Directory structure created"

# Initialize KMP shared module
cd shared
echo "📦 Initializing shared KMP module..."
# Add build.gradle.kts content here

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open ios-app/STEAL.xcodeproj in Xcode"
echo "2. Open android-app in Android Studio"
echo "3. Configure PocketBase URL in .env files"
echo "4. Run shared:build to verify KMP setup"
```

---

## Environment Configuration

### iOS (.xcconfig)

```
POCKETBASE_URL=https://your-pocketbase-instance.com
APP_NAME=STEAL
BUNDLE_ID=com.steel.fitness
```

### Android (local.properties / BuildConfig)

```kotlin
buildConfigField("String", "POCKETBASE_URL", "\"https://your-pocketbase-instance.com\"")
```

---

## Testing Setup

### Unit Tests (KMP Common)

```kotlin
// shared/src/commonTest/kotlin/com/steel/models/UserTest.kt
package com.steel.models

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlinx.serialization.json.Json

class UserTest {
    @Test
    fun testUserSerialization() {
        val json = Json { ignoreUnknownKeys = true }
        val userData = """
            {
                "id": "user123",
                "email": "test@example.com",
                "name": "Test User",
                "created": "2024-01-01 00:00:00.000Z",
                "updated": "2024-01-01 00:00:00.000Z"
            }
        """
        
        val user = json.decodeFromString<User>(userData)
        assertEquals("user123", user.id)
        assertEquals("test@example.com", user.email)
    }
}
```

---

## Phase 0 Deliverables Checklist

- [x] Project structure defined
- [x] Design tokens documented (colors, typography, spacing)
- [ ] Shared KMP module created with all models
- [ ] PocketBase API client implemented
- [ ] iOS SwiftUI project scaffolded
- [ ] Android Compose project scaffolded
- [ ] Design system implemented on both platforms
- [ ] Basic navigation structure created
- [ ] Unit tests for data models
- [ ] README with setup instructions

---

## Next Phase: Phase 1 - Core & Authentication

Phase 1 will cover:
- Complete authentication flow (login, register, password reset)
- Onboarding screens
- Tab navigation structure
- Core layout components
- First UI screens (Dashboard, Plans, Sessions)