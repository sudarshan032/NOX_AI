# Demo App - Production-Ready Frontend

A Flutter application with production-grade architecture. Complete working frontend ready to be handed off to backend/agent integration developers.

## Directory Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Core utilities
│   ├── constants/
│   │   └── app_constants.dart   # App-wide constants & route names
│   ├── theme/
│   │   └── app_theme.dart       # Theme provider & colors
│   ├── utils/
│   │   ├── extensions.dart      # Dart/Flutter extensions
│   │   └── page_transitions.dart # Navigation transitions
│   └── core.dart                # Barrel export
│
├── data/                        # Data layer (PRODUCTION - commented)
│   ├── models/                  # Data models templates
│   ├── repositories/            # Repository pattern templates
│   ├── services/                # API service templates
│   └── data.dart                # Barrel export
│
├── providers/                   # State management (PRODUCTION - commented)
│   └── app_providers.dart       # Riverpod providers template
│
├── routes/                      # Navigation
│   └── app_router.dart          # Route configuration
│
├── shared/                      # Shared components
│   ├── widgets/
│   │   └── shared_widgets.dart  # Reusable widgets
│   └── shared.dart              # Barrel export
│
└── features/                    # Feature modules
    ├── splash/                  # Splash screen
    │   └── screens/
    ├── onboarding/              # Onboarding flow (3 screens)
    │   └── screens/
    ├── auth/                    # Authentication (3 screens)
    │   └── screens/
    ├── home/                    # Home/Dashboard
    │   └── screens/
    ├── tasks/                   # Tasks management
    │   └── screens/
    ├── calls/                   # Call logs & details (2 screens)
    │   └── screens/
    ├── calendar/                # Calendar view
    │   └── screens/
    ├── memories/                # Memories feature
    │   └── screens/
    ├── notifications/           # Notifications
    │   └── screens/
    ├── profile/                 # Profile settings
    │   └── screens/
    └── features.dart            # Barrel export
```

## Getting Started

### Current State (Working Frontend)

The app runs with:
- Static/mock data in each screen
- Theme switching works (dark/light mode)
- All navigation works with Navigator 1.0
- No external API calls

### Enabling Production Features

1. **Add Dependencies** - Uncomment in `pubspec.yaml`:
   ```yaml
   flutter_riverpod: ^2.5.1
   go_router: ^14.2.0
   dio: ^5.4.3
   flutter_secure_storage: ^9.2.2
   # ... see pubspec.yaml for full list
   ```

2. **Enable State Management** - Uncomment in `lib/providers/app_providers.dart`

3. **Enable API Service** - Uncomment in `lib/data/services/api_service.dart`

4. **Enable Models** - Uncomment in `lib/data/models/` files

5. **Enable Repositories** - Uncomment in `lib/data/repositories/`

6. **Enable Routing** - Replace Navigator with go_router in `lib/routes/app_router.dart`

7. **Update main.dart** - Wrap app with `ProviderScope` and use `router.config`

## Architecture

### Layer Responsibility

| Layer | Purpose |
|-------|---------|
| **Screens/Features** | UI components, user interaction |
| **Providers** | State management, business logic |
| **Repositories** | Data operations, API abstraction |
| **Services** | External integrations (API, storage) |
| **Models** | Data structures, serialization |

### Data Flow

```
Screen → Provider → Repository → Service → API
   ↑         ↓          ↓           ↓        ↓
   └─────── State ←─── Data ←──── Response ←─┘
```

## Shared Widgets

Import from `lib/shared/shared.dart`:

```dart
import 'package:nox_ai/shared/shared.dart';

// Available widgets:
AppNavItem()        // Bottom navigation item
AppCard()           // Styled card container
AppFilterChip()     // Filter/tab selection chip
AppPrimaryButton()  // Primary action button
AppSecondaryButton()// Secondary/outline button
AppLoadingIndicator()// Loading spinner
AppEmptyState()     // Empty list placeholder
```

## Theme Usage

```dart
import 'package:nox_ai/core/theme/app_theme.dart';

// Access theme colors via BuildContext extension:
context.bg           // Background color
context.textPrimary  // Primary text color
context.textSecondary// Secondary text color
context.gold         // Accent/gold color
context.cardBg       // Card background
context.cardBorder   // Card border
context.orbBg        // Voice orb background
context.logoPath     // Theme-appropriate logo path

// Toggle theme:
ThemeProvider().toggleTheme();
```

## Next Steps for Production

1. [ ] Uncomment dependencies in pubspec.yaml and run `flutter pub get`
2. [ ] Set up API base URL in `AppConstants`
3. [ ] Uncomment and configure API service
4. [ ] Uncomment model classes and run build_runner for JSON serialization
5. [ ] Uncomment repositories and connect to API
6. [ ] Uncomment Riverpod providers
7. [ ] Replace Navigator with go_router
8. [ ] Add environment configuration (dev/staging/prod)
9. [ ] Set up CI/CD pipeline
10. [ ] Add comprehensive tests

## Commands

```bash
# Run app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate code (after enabling json_serializable/freezed)
dart run build_runner build --delete-conflicting-outputs
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)
