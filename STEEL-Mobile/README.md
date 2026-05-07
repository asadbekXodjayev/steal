# STEEL-Mobile

**STEAL Fitness Mobile App** — Native iOS (SwiftUI) + Android (Jetpack Compose) with Kotlin Multiplatform shared logic.

> "Steal Forges Steel" — Brutal industrial powerlifting aesthetic. Raw. Heavy. Dangerous.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     STEEL-Mobile Monorepo                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐    ┌──────────────────┐               │
│  │   iOS App        │    │   Android App    │               │
│  │   SwiftUI        │    │   Jetpack Compose│               │
│  │   SwiftData      │    │   Room           │               │
│  └────────┬─────────┘    └────────┬─────────┘               │
│           │                       │                          │
│           └───────────┬───────────┘                          │
│                       │                                       │
│              ┌────────▼────────┐                             │
│              │  Shared KMP     │                             │
│              │  - Models       │                             │
│              │  - API Client   │                             │
│              │  - Sync Logic   │                             │
│              └────────┬────────┘                             │
│                       │                                       │
│              ┌────────▼────────┐                             │
│              │  PocketBase     │                             │
│              │  Backend API    │                             │
│              └─────────────────┘                             │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## 📱 Tech Stack

| Platform | Technology | Version |
|----------|------------|---------|
| iOS | Swift 6 + SwiftUI | iOS 16+ |
| Android | Kotlin 2.0 + Jetpack Compose | API 24+ |
| Shared | Kotlin Multiplatform | 2.0.21 |
| Backend | PocketBase | 0.21+ |
| HTTP | Ktor Client | 3.0.1 |
| Serialization | kotlinx.serialization | 1.7.3 |

## 🗂️ Project Structure

```
STEEL-Mobile/
├── README.md                 # This file
├── PHASE-0-SETUP.md          # Phase 0 setup documentation
├── package.json              # Root package with npm scripts
├── pnpm-workspace.yaml       # Workspace configuration
├── docs/                     # Documentation
│   ├── ARCHITECTURE.md       # System architecture
│   ├── API.md                # API reference
│   └── SETUP.md              # Setup guide
├── shared/                   # KMP shared module
│   └── src/
│       ├── commonMain/       # Shared Kotlin code
│       ├── androidMain/      # Android-specific code
│       └── iosMain/          # iOS-specific code
├── ios-app/                  # iOS SwiftUI app
│   └── STEAL/
│       ├── Models/           # Data models
│       ├── Services/         # API & sync services
│       ├── ViewModels/       # State management
│       └── Views/            # UI components
└── android-app/              # Android Compose app
    └── app/
        ├── data/             # Data layer
        ├── domain/           # Business logic
        └── ui/               # Compose UI
```

## 🎨 Design System

### Colors

| Token | Dark Mode | Light Mode | Usage |
|-------|-----------|------------|-------|
| `--background` | `#050505` | `#f5f5f5` | Main background |
| `--primary` | `#8B0000` | `#8B0000` | Blood red accent |
| `--secondary` | `#C2410C` | `#C2410C` | Forged steel orange |
| `--tactical` | `#166534` | `#166534` | Military green |
| `--ink-high` | `#E5E5E5` | `#1a1a1a` | Primary text |
| `--ink-low` | `#a1a1aa` | `#525252` | Secondary text |

### Typography

- **Headings:** Barlow Condensed (aggressive, condensed)
- **Body:** System UI (clean, readable)
- **Data:** JetBrains Mono (tabular numbers)

### Spacing

```
space-1: 4px    space-2: 8px    space-3: 12px
space-4: 16px   space-5: 20px   space-6: 24px
space-8: 32px   space-10: 40px  space-12: 48px
```

## 🚀 Quick Start

### Prerequisites

- macOS for iOS development (Xcode 15+)
- Android Studio (Ladybug or newer)
- Node.js 20+ with pnpm
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/steel-mobile.git
cd steel-mobile

# Install dependencies (if any)
pnpm install

# Run iOS app
pnpm ios

# Run Android app
pnpm android

# Build shared module
pnpm shared:build
```

## 📦 PocketBase Collections

| Collection | Purpose |
|------------|---------|
| `users` | Authentication |
| `profiles` | User profile data |
| `goals` | Fitness goals |
| `exercises` | Exercise library |
| `workout_plans` | User workout plans |
| `plan_days` | Plan day structure |
| `plan_exercises` | Exercises in plan days |
| `plan_templates` | Pre-made templates |
| `workout_sessions` | Session logging |
| `session_sets` | Individual sets |
| `exercise_translations` | Exercise translations |

## 🔄 Development Phases

### Phase 0: Project Setup & Design Tokens ✅
- [x] Project structure
- [x] Design tokens
- [x] Data models
- [x] API client scaffold

### Phase 1: Core & Authentication
- [ ] Login/Register flow
- [ ] Password reset
- [ ] Onboarding screens
- [ ] Tab navigation
- [ ] Core UI components

### Phase 2: Offline-First Data Layer
- [ ] Room database (Android)
- [ ] SwiftData (iOS)
- [ ] Sync manager
- [ ] Offline queue
- [ ] Conflict resolution

### Phase 3: Workout Plans & Session Logging
- [ ] Plan browsing
- [ ] Plan activation
- [ ] Session creation
- [ ] Set logging UI
- [ ] Exercise media

### Phase 4: Progress, Charts & Achievements
- [ ] Progress tracking
- [ ] Charts (volume, strength)
- [ ] PR detection
- [ ] Achievements system
- [ ] Muscle balance radar

### Phase 5: Polish, Notifications, Performance
- [ ] Push notifications
- [ ] Background sync
- [ ] Performance optimization
- [ ] Accessibility
- [ ] Animations

### Phase 6: Publishing Guide
- [ ] App Store submission
- [ ] Play Store submission
- [ ] Release notes
- [ ] Version management

## 🧪 Testing

```bash
# Run shared module tests
cd shared && ./gradlew jvmTest

# Run iOS tests
cd ios-app && xcodebuild test -scheme STEAL

# Run Android tests
cd android-app && ./gradlew test
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

```
type(scope): description

feat:     New feature
fix:      Bug fix
refactor: Code refactoring
docs:     Documentation
test:     Tests
chore:    Maintenance
```

## 📄 License

Copyright © 2024 Steel Fitness. All rights reserved.

## 🤝 Support

- Issues: GitHub Issues
- Email: support@stealfitness.com