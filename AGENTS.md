# AGENTS.md — Prayer Times

## Project Overview

**Prayer Times** is an open-source, ad-free, offline Flutter mobile app that helps Muslims around the world stay on track with their prayer times. The project aims to combine a rich feature set with a free-to-use experience, sustained through community collaboration.

> **Platform:** Android only (the `ios/` directory has been removed; do not add iOS/macOS code paths).

### Tech Stack

| Area | Technology |
|------|-----------|
| Framework | Flutter (Dart SDK ^3.10.0) |
| State management | `flutter_riverpod` (Provider, NotifierProvider, FutureProvider) |
| Routing | `go_router` (ShellRoute for persistent bottom navigation bar) |
| Local storage | `hive` + `hive_flutter` (key-value) |
| Prayer calculations | `adhan_dart` |
| Local notifications | `flutter_local_notifications` |
| Background scheduling | `workmanager` (periodic daily task) |
| Location | `geolocator`, `geocoding`, `flutter_compass` |
| Hijri calendar | `hijri` |
| Date/time formatting | `intl` |
| Timezone | `timezone` + `flutter_timezone` (resolves device IANA timezone name, stored in `general` box) |
| SVG icons | `flutter_svg` |
| Logging | `logging` (records printed via `debugPrint` in debug mode only) |
| Styling | Custom `CustomPainter` for Islamic pattern tiling, gradients, compass |

> **Note:** `drift` is declared in `pubspec.yaml` but not used anywhere in `lib/` — a candidate for removal unless it is planned for future use.

### Directory Structure

```
lib/
├── main.dart                              # Entry point, GoRouter config, Workmanager setup
├── app/
│   └── shell/                             # Persistent shell: TopBar + Bottom Navigation
│       ├── app_shell.dart                 # Gradient background + Islamic pattern + shell layout
│       ├── widgets/
│       │   ├── navigation_bar.dart       # Bottom nav (Prayers / Qibla / Settings)
│       │   └── top_bar.dart               # App bar: next prayer name, countdown timer, location
├── core/
│   ├── enums/                             # PrayersEnums, AthanSoundEnums, NotificationsEnums, SvgIconDataEnums, SettingsCategoryEnums
│   ├── style/                             # Colors, fonts, icons, background pattern, painter helpers
│   ├── extensions/                        # String, notifications, svg_icon_data, enum_list extensions
│   └── services/
│       ├── prayer_times/                  # IPrayerTimes abstraction + PrayerTimes impl + provider
│       ├── notifications/                 # Inotifications abstraction + Notifications impl + NotificationModel + provider
│       ├── storage/hive/                  # IHiveStorage abstraction + HiveStorage impl + provider
│       ├── location/                      # ILocation abstraction + Location impl + provider (GPS, Qibla calc, geocoding)
│       └── compass/                       # ICompass abstraction + Compass impl + provider
└── features/
    ├── home/                              # Home screen: prayer list, calendar, next-prayer notifier
    │   ├── domain/notifiers/
    │   │   ├── next_prayer_notifier.dart  # Tracks which prayer is next
    │   │   └── calendar_offset_notifier.dart # Calendar day offset (+/- for browsing days)
    │   └── presentation/
    │       ├── screens/
    │       │   ├── home_screen.dart       # Main prayer list screen
    │       │   └── home_screen_empty_state.dart
    │       └── widgets/
    │           ├── calendar.dart           # Hijri + Gregorian date card with prev/next arrows
    │           └── prayer_card.dart        # Per-prayer card: name, time, mute toggle
    └── qibla/                             # Qibla compass screen
        ├── domain/notifiers/
        │   └── qibla_direction_notifier.dart # GPS position + Qibla direction providers
        └── presentation/
            ├── screens/qibla_screen.dart
            └── widgets/
                ├── qibla_compass.dart         # Animated compass with heading + Qibla indicator
                ├── location_info_card.dart    # Location, coordinates, distance-to-Mecca card
                └── direction_indicator.dart   # "Qibla Direction: N° N" status chip
```

### Configuration & Defaults

All defaults are defined in `lib/core/services/storage/hive/hive_storage.dart` and documented in `docs/storage.md`.

On startup the app fetches the device GPS position (when permission is granted) and the device IANA timezone (via `flutter_timezone`) and persists them into the `general` box, so prayer times follow the real user location. If location is unavailable, the stored values (Cairo defaults) are kept. All downstream consumers (`PrayerTimes`, notifications) read from storage — never hardcode coordinates or timezones.

**Prayer times** (8 entries, in order):
`fajr`, `sunrise`, `dhuhr`, `asr`, `maghrib`, `isha`, `midnight`, `lastThird`

**Default location**: Cairo, Egypt (`30.0444, 31.2357`, timezone `Africa/Cairo`)

**Default calculation method**: `egyptian` (from `adhan_dart`)

**Default Athan sounds**:
- `fajr, dhuhr, asr, maghrib, isha` → `abdulbasit`
- `sunrise, midnight, lastThird` → `defaultSound` (no Athan, system notification sound)

**Default notification mute states**:
- `sunrise, midnight, lastThird` → `true` (muted by default)
- All others → `false` (enabled by default)

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run static analysis
flutter analyze

# Check formatting (fails if files are not formatted)
dart format --set-exit-if-changed .

# Run tests
flutter test
```

### Linting & CI

The CI workflow (`.github/workflows/lint.yml`) runs on every pull request and executes:
1. **Super Linter** (general files) — configured via `.github/linters/.jscpd.json`
2. **flutter analyze** — uses `analysis_options.yaml` which includes `package:flutter_lints/flutter.yaml`
3. **dart format check** — enforces `dart format` formatting

CI pins a specific Flutter version (currently `3.38.1`, set in `lint.yml`) — keep this in sync with your local Flutter version to avoid CI failures.

**Code style requirements:**
- Follow `flutter_lints` rules (see `analysis_options.yaml`)
- Code must be formatted with `dart format` before committing
- Use single quotes throughout (project convention)

## Architecture & Patterns

### State Management (Riverpod)

- **Providers** (`Provider<T>`) for read-only service instances (e.g. `prayerTimesProvider`, `locationProvider`, `compassProvider`, `notificationsProvider`, `hiveStorageProvider`)
- **NotifierProvider** for state that needs to mutate and notify (e.g. `nextPrayerProvider`, `calendarOffsetProvider`)
- **FutureProvider** for async operations (e.g. `hiveStorageProvider` returns a `FutureProvider<IHiveStorage>`, `qiblaDirectionProvider` returns `FutureProvider<double>`)
- Use `ref.watch(...)` for reactive rebuilds, `ref.read(...)` for one-time access

### Service Abstraction Pattern

Every core service follows a consistent structure:
1. `I<Type>` abstract class in the same directory declaring the public interface
2. `<Type>` concrete implementation
3. `<type>Provider` exposing the implementation via Riverpod

Example: `iprayer_times.dart` → `prayer_times.dart` → `prayer_times_provider.dart`

### Navigation

`go_router` with a `ShellRoute` wraps all main screens in `AppShell`, which provides:
- Top bar (TopBar) — shows next prayer name + live countdown timer
- Bottom navigation bar (NavigationBar) — switches between `/home` and `/qibla`

Routes:
- `/home` → `HomeScreen`
- `/qibla` → `QiblaScreen`

### Background Notification Scheduling

`workmanager` registers a periodic daily task (`schedule_prayer_notifications`) that runs in a separate isolate (`callbackDispatcher` in `main.dart`). It reads `prayerTimesProvider` and `notificationsProvider`, then calls `scheduleTodayPrayerNotifications()` to reschedule all remaining prayer notifications for today. The `ExistingPeriodicWorkPolicy.keep` ensures the task persists across app restarts.

**Hive is not multi-isolate safe**: the background task closes all Hive boxes (`storage.dispose()`) as soon as it finishes, and disposes its `ProviderContainer`.

**Notification details:**
- Each Athan sound gets its own Android notification channel (`prayer_channel_<sound>`) — on Android 8+ the channel sound overrides per-notification sound. Details are built by `NotificationModel.prayerNotificationDetails()`.
- Raw sound assets live in `android/app/src/main/res/raw/` as `athan_<name>.mp3` (e.g. `athan_abdulbasit.mp3`); `AthanSoundEnums.defaultSound` uses the system default notification sound (no custom audio resource).
- `schedule()` checks `canScheduleExactNotifications()` and falls back to `AndroidScheduleMode.inexactAllowWhileIdle` when exact alarms are denied (Android 14+).
- Notification taps rely on Android's default launch behavior (open the app); no custom tap handling.
- Prayer notifications use stable IDs (`prayer.index + 1`); past prayers are skipped when scheduling.

### Storage (Hive)

`HiveStorage` manages three Hive boxes:
- `soundMuteSettings` — per-prayer mute booleans (keyed by `PrayersEnums.name`)
- `athanSoundSettings` — per-prayer Athan sound (keyed by `PrayersEnums.name`)
- `general` — latitude, longitude, location (timezone string), locale, calculation_method

Defaults are returned when a key has never been set (no need for explicit initialization writes).

## Testing

Tests use Flutter's `flutter_test` framework and live under `test/`, mirroring the `lib/` structure:

- `test/core/services/storage/hive_storage_test.dart` — unit tests for `HiveStorage` defaults and getters/setters

**Test conventions:**
- Use a `ProviderContainer` to resolve providers (as in `hive_storage_test.dart`)
- Initialize storage with `storage.init(temp: true)` in `setUp` and `clear()` + `dispose()` in `tearDown`, then `providerContainer.invalidate(...)` for isolation
- The abstract service interfaces (`I*`) are designed to be easily mocked for unit testing of other services

## Pull Request Guidelines

Branching convention: `<type>/<short-description>`

| Type | Purpose |
|------|---------|
| `feature/` | New features or significant enhancements |
| `bugfix/` | Bug fixes or issue resolution |
| `hotfix/` | Urgent/critical production fixes |
| `chore/` | Routine maintenance, dependency updates, refactoring |
| `docs/` | Documentation-only changes |
| `test/` | Adding, updating, or improving tests |
| `devops/` | CI/CD and GitHub Actions changes |

PRs should follow the template at `.github/PULL_REQUEST_TEMPLATE.md` (description, motivation, issues fixed, how to test).

Refer to the [docs](./docs) for technical details, and see `docs/storage.md` for the storage schema.