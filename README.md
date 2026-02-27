# Focused Timer

A Pomodoro timer app for iOS that helps you concentrate and finish tasks by making it simple to follow the Pomodoro technique.

## Motivation

The main motivation to create this app was to learn how `SwiftUI` works and to get more familiar with the `MVVM` architecture. While thinking about a good candidate app, the need for a personal timer became apparent — so the two goals merged into one: build the app you'd actually use.

## Features

### Timer Types

- **Focus** — Default 25 minutes. The main work session, shown in the accent (orange) color.
- **Short Break** — Default 5 minutes. A quick rest between focus sessions, shown in blue.
- **Long Break** — Default 30 minutes. An extended rest after completing a full cycle, shown in green.

### Cycle Tracking

The app tracks how many focus sessions you've completed. After a configurable number of sessions (default: 4), a long break is triggered automatically. The current cycle progress is displayed as `X/Y` on the main screen.

### Timer Controls

- **Play / Pause** — Starts or pauses the current timer.
- **Reset** — Returns the timer to its initial state.

Both controls include haptic feedback.

### Settings

All timer values and app behaviors are fully configurable:

| Setting | Default |
|---|---|
| Focused time | 25 minutes |
| Short break | 5 minutes |
| Long break | 30 minutes |
| Number of cycles | 4 |
| Auto-start next timer | Off |
| Play sounds on completion | On |
| Keep screen on | Off |

Settings are persisted across launches. A **Reset to Defaults** option is available with a confirmation dialog.

### Notifications

Local push notifications are scheduled when the timer finishes while the app is in the background. Notifications are automatically cleared when the app returns to the foreground.

### Background Handling

When the app moves to the background, the current timestamp is saved. On return, elapsed time is calculated and the timer is updated accordingly — even if the app was terminated and relaunched.

### Help Screen

An in-app help screen explains the Pomodoro technique and each timer type, fully localized.

## Technologies

- **SwiftUI** — Declarative UI framework
- **MVVM** — Architecture pattern with protocol-based dependency injection for full unit testability
- **XCTest** — Unit and UI tests
- **UserDefaults** — Local persistence via a generic `NetworkManager` wrapper
- **UNUserNotificationCenter** — Local push notifications
- **Xcode Cloud** — CI/CD pipeline
- **SwiftLint** — Static analysis enforced on every build

## Architecture

### MVVM with Protocol-Based Dependency Injection

All major dependencies are abstracted behind protocols so unit tests run without real system services:

| Protocol | Purpose |
|---|---|
| `TimerModelProtocol` / `SettingsModelProtocol` | Data access |
| `RepeatingTimerFactoryProtocol` / `RepeatingTimerProtocol` | Timer creation |
| `LocalNotificationManaging` / `UserNotificationCenterProtocol` | Notifications |
| `SystemSoundPlaying` | Audio feedback |
| `NotificationFlagStoring` | Lightweight UserDefaults flag access |

`TimerViewModel` accepts all of these as constructor parameters, enabling full injection of test doubles.

### Data Layer

`NetworkManager` is a generic `UserDefaults` wrapper. `TimerModel` and `SettingsModel` are thin structs that delegate entirely to it.

### Localization

All user-facing strings live in `Focused Timer/Focused Timer/Shared/Constants/Localizable.xcstrings`.

Supported languages:
- English (`en`)
- Portuguese — Brazil (`pt-BR`)

### Swift 6 Concurrency

- `TimerViewModel` is **not** `@MainActor` — it's an `ObservableObject` without main actor isolation.
- `SettingsViewModel` **is** `@MainActor`.
- `AppDelegate` uses `@preconcurrency UNUserNotificationCenterDelegate`.

## Testing

### Unit Tests

- `TimerViewModelTests`
- `SettingsViewModelTests`
- `LocalNotificationManagerTests`
- `AppDelegateTests`
- `TimerViewLifecycleTests`
- `LocalizationTests`

### UI Tests

All UI tests extend `BaseFeature`, an `@MainActor` base class. The app supports a `"UI-Testing"` launch argument that clears `UserDefaults`, disables animations, and accepts fast timer durations via environment variables (`UI_TEST_FOCUSED_SECONDS`, `UI_TEST_SHORT_BREAK_SECONDS`, `UI_TEST_LONG_BREAK_SECONDS`, `UI_TEST_NUMBER_OF_CYCLES`).

```bash
# Run all tests
xcodebuild test \
  -project "Focused Timer/Focused Timer.xcodeproj" \
  -scheme "Focused Timer" \
  -destination "platform=iOS Simulator,name=iPhone 16"

# Run only unit tests
xcodebuild test \
  -project "Focused Timer/Focused Timer.xcodeproj" \
  -scheme "Focused Timer" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing "Focused TimerTests"
```

## SwiftLint

SwiftLint v0.57.1 runs as an Xcode build phase on every build.

- Install locally: `brew install swiftlint`
- Run manually from the project root:

```bash
swiftlint lint --config "Focused Timer/.swiftlint.yml"
```

Key constraints:
- 4-character minimum for identifier names
- 120-character line length limit
- `explicit_self` analyzer rule enabled

Xcode Cloud installs and validates the pinned version via `ci_scripts/ci_post_clone.sh` before each build.

## Download

The app is available on the [App Store](https://apps.apple.com/br/app/focused-timer/id1563481123).
