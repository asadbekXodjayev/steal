# STEEL-Mobile Architecture

## Overview

STEEL-Mobile is a cross-platform mobile application built with Kotlin Multiplatform (KMP) to share business logic and data models between iOS (SwiftUI) and Android (Jetpack Compose) while maintaining native performance and UX on each platform.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        STEEL-Mobile App                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────┐    ┌─────────────────────────┐         │
│  │      iOS Platform        │    │     Android Platform     │         │
│  │                         │    │                         │         │
│  │  ┌───────────────────┐  │    │  ┌───────────────────┐  │         │
│  │  │  SwiftUI Views    │  │    │  │  Compose UI       │  │         │
│  │  └─────────┬─────────┘  │    │  └─────────┬─────────┘  │         │
│  │            │             │    │            │             │         │
│  │  ┌─────────▼─────────┐  │    │  ┌─────────▼─────────┐  │         │
│  │  │   ViewModels      │  │    │  │   ViewModels      │  │         │
│  │  │   (Observable)    │  │    │  │   (ViewModel)     │  │         │
│  │  └─────────┬─────────┘  │    │  └─────────┬─────────┘  │         │
│  │            │             │    │            │             │         │
│  │  ┌─────────▼─────────┐  │    │  ┌─────────▼─────────┐  │         │
│  │  │  SwiftData        │  │    │  │  Room Database    │  │         │
│  │  │  (Local Cache)    │  │    │  │  (Local Cache)    │  │         │
│  │  └─────────┬─────────┘  │    │  └─────────┬─────────┘  │         │
│  └────────────┼─────────────┘    └────────────┼─────────────┘         │
│               │                                │                       │
│               └──────────────┬─────────────────┘                       │
│                              │                                         │
│                      ┌───────▼────────┐                               │
│                      │  Shared KMP    │                               │
│                      │  Module        │                               │
│                      │                │                               │
│                      │  ┌──────────┐  │                               │
│                      │  │ Models   │  │  ← Data classes (serializable)│
│                      │  └────┬─────┘  │                               │
│                      │       │        │                               │
│                      │  ┌────▼─────┐  │                               │
│                      │  │  API     │  │  ← Ktor client, endpoints    │
│                      │  └────┬─────┘  │                               │
│                      │       │        │                               │
│                      │  ┌────▼─────┐  │                               │
│                      │  │  Sync    │  │  ← Offline-first sync logic  │
│                      │  └────┬─────┘  │                               │
│                      │       │        │                               │
│                      └───────┼────────┘                               │
│                              │                                         │
│                      ┌───────▼────────┐                               │
│                      │   PocketBase   │                               │
│                      │   Backend API  │                               │
│                      └────────────────┘                               │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Layer Architecture

### 1. Presentation Layer (Platform-Specific)

**iOS (SwiftUI)**
- Views: SwiftUI components following the design system
- ViewModels: Observable objects managing UI state
- Navigation: SwiftUI NavigationStack / TabView

**Android (Jetpack Compose)**
- UI: Composable functions following the design system
- ViewModels: AndroidX ViewModel with stateFlow
- Navigation: Navigation Compose

### 2. Domain Layer (Shared KMP)

**Models**
- All data models defined as Kotlin data classes
- Serializable with kotlinx.serialization
- Platform-agnostic business logic

**Use Cases** (Phase 2+)
- Interactors for complex business operations
- Validation logic
- Data transformation

### 3. Data Layer (Shared KMP + Platform)

**Shared KMP**
- API Client: Ktor HTTP client with PocketBase endpoints
- Sync Manager: Offline-first synchronization logic
- Repository Interfaces: Abstract data access

**Platform-Specific**
- iOS: SwiftData for local persistence
- Android: Room database for local persistence
- Platform-specific implementations of repositories

### 4. Network Layer

**PocketBase API**
- RESTful API endpoints
- WebSocket for real-time updates (future)
- Authentication via JWT tokens

**Ktor Client**
- Cross-platform HTTP client
- Content negotiation with JSON serialization
- Request/response interceptors

## Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │────▶│   View      │────▶│  ViewModel  │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                                ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  PocketBase │◀───▶│  Sync Mgr   │◀───▶│  Repository │
│   (Remote)  │     │  (Offline)  │     │  (Shared)   │
└─────────────┘     └─────────────┘     └─────────────┘
                            │
                            ▼
                   ┌────────────────┐
                   │ Local Database │
                   │ (SwiftData/    │
                   │   Room)        │
                   └────────────────┘
```

## State Management

### iOS
- `@Observable` macros (Swift 6)
- `@StateObject` for view-owned state
- `@EnvironmentObject` for shared state
- Combine for reactive streams

### Android
- `ViewModel` with `StateFlow`
- `remember` for composable state
- Hilt for dependency injection (Phase 2+)

## Offline-First Strategy

1. **Read Path**: Always read from local database first
2. **Write Path**: Write to local, sync to remote in background
3. **Sync**: Periodic background sync with conflict resolution
4. **Queue**: Offline operations queued for later sync

## Security

1. **Authentication**: JWT tokens stored in Keychain (iOS) / EncryptedSharedPreferences (Android)
2. **Network**: HTTPS only, certificate pinning (Phase 5)
3. **Data**: Encrypted local database
4. **Biometrics**: FaceID/TouchID / BiometricPrompt (Phase 5)

## Performance Considerations

1. **Image Loading**: Coil (Android) / Kingfisher (iOS) with caching
2. **Lists**: Lazy lists with proper recycling
3. **Memory**: Weak references for observers, proper cleanup
4. **Battery**: Efficient sync intervals, batch operations

## Testing Strategy

### Unit Tests (Shared)
- Model serialization/deserialization
- Business logic in use cases
- Repository logic with mocked dependencies

### UI Tests
- iOS: XCUITest
- Android: Compose UI Test

### Integration Tests
- API client with mock server
- Database operations
- Sync logic

## Project Structure Details

```
STEEL-Mobile/
├── shared/                          # KMP shared module
│   └── src/
│       ├── commonMain/
│       │   └── kotlin/com/steel/
│       │       ├── models/          # Data models
│       │       ├── api/             # API client
│       │       ├── sync/            # Sync logic
│       │       └── repository/      # Repository interfaces
│       ├── androidMain/
│       │   └── kotlin/com/steel/
│       │       ├── platform/        # Android-specific
│       │       └── data/            # Android data layer
│       └── iosMain/
│           └── kotlin/com/steel/
│               ├── platform/        # iOS-specific
│               └── data/            # iOS data layer
│
├── ios-app/                         # iOS SwiftUI app
│   └── STEAL/
│       ├── STEALApp.swift           # App entry point
│       ├── Models/                  # Swift-specific models
│       ├── Services/                # Platform services
│       ├── ViewModels/              # UI state management
│       └── Views/                   # SwiftUI components
│
└── android-app/                     # Android Compose app
    └── app/
        └── src/main/java/com/steel/
            ├── SteelApplication.kt  # App entry point
            ├── MainActivity.kt      # Host for Compose
            ├── data/                # Data layer
            ├── domain/              # Business logic
            └── ui/                  # Compose UI
```

## Dependencies

### Shared (KMP)
- Kotlin 2.0.21
- kotlinx-coroutines 1.9.0
- kotlinx-serialization 1.7.3
- Ktor 3.0.1

### iOS
- SwiftUI (iOS 16+)
- SwiftData (iOS 17+)
- Combine

### Android
- Jetpack Compose BOM 2024.10.01
- Room 2.6.1
- AndroidX Lifecycle 2.8.6
- Navigation Compose 2.8.3

## Version Compatibility

| Component | Minimum Version |
|-----------|-----------------|
| iOS | 16.0 (17+ for SwiftData) |
| Android | API 24 (Android 7.0) |
| Xcode | 15.0 |
| Android Studio | Ladybug (2024.2) |
| Kotlin | 2.0.21 |
| Swift | 6.0 |

## Future Enhancements

1. **Real-time Sync**: PocketBase WebSocket integration
2. **Push Notifications**: APNs (iOS) / FCM (Android)
3. **HealthKit Integration**: Fitness data sync
4. **Apple Watch App**: Companion app
5. **Dark/Light Theme**: System-aware theming
6. **Accessibility**: Full VoiceOver / TalkBack support