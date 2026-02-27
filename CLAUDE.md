# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build & Test

All commands run from the repo root. The Xcode project is at `Focused Timer/Focused Timer.xcodeproj`.

```bash
# Run all tests (unit + UI)
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

# Run a single test class
xcodebuild test \
  -project "Focused Timer/Focused Timer.xcodeproj" \
  -scheme "Focused Timer" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing "Focused TimerTests/TimerViewModelTests"
```

### Linting

SwiftLint v0.57.1 is required (enforced by Xcode Cloud CI). It runs as an Xcode build phase on every build. To run manually:

```bash
swiftlint lint --config "Focused Timer/.swiftlint.yml"
```

Key SwiftLint constraints to be aware of:

- **4-character minimum** for identifier names (use `application` not `app`)
- **120-character line length** limit
- `explicit_self` analyzer rule is enabled
- `colon`, `comma`, `control_statement` rules are disabled

## Architecture

### MVVM with Protocol-Based Dependency Injection

All major dependencies are abstracted behind protocols to enable unit testing without mocks needing real system services:

- `TimerModelProtocol` / `SettingsModelProtocol` — data access
- `RepeatingTimerFactoryProtocol` / `RepeatingTimerProtocol` — timer creation
- `LocalNotificationManaging` / `UserNotificationCenterProtocol` — notifications
- `SystemSoundPlaying` — audio feedback
- `NotificationFlagStoring` — lightweight UserDefaults flag access

`TimerViewModel` takes all these as constructor parameters, enabling full unit testing with test doubles.

### Data Layer

`NetworkManager` is a generic UserDefaults wrapper (not a network layer despite the name). All persistence goes through it. `TimerModel` and `SettingsModel` are thin structs that delegate entirely to `NetworkManager`.

### Localization

All user-facing strings must go in `Focused Timer/Focused Timer/Shared/Constants/Localizable.xcstrings` (the String Catalog). Reference them directly — no wrapper enum:

- **SwiftUI** initializers that accept `LocalizedStringKey` (`Text`, `Toggle`, `Label`, `Section`, alert `title:`/`message:`, `.accessibilityLabel`, `.accessibilityValue`): use a string literal → `Text("key")`
- **Non-SwiftUI** code that must return/pass `LocalizedStringResource` (e.g. `primaryButtonText`, `getCorrectTranslation()`): inline → `LocalizedStringResource("key", table: "Localizable")`

### UI Testing Infrastructure

`BaseFeature` is the `@MainActor` base class for all UI tests. The app supports a `"UI-Testing"` launch argument that triggers `AppDelegate` to clear `UserDefaults`, disable animations, and set fast timer durations via environment variables (`UI_TEST_FOCUSED_SECONDS`, `UI_TEST_SHORT_BREAK_SECONDS`, `UI_TEST_LONG_BREAK_SECONDS`, `UI_TEST_NUMBER_OF_CYCLES`). All UI test subclasses must redeclare `@unchecked Sendable`.

## Swift 6 Concurrency Patterns

- `TimerViewModel` is **not** `@MainActor` — it's an `ObservableObject` without main actor isolation
- `SettingsViewModel` **is** `@MainActor`
- `AppDelegate` is `@MainActor class ... @preconcurrency UNUserNotificationCenterDelegate`
- UI test `setUp`/`tearDown` use `MainActor.assumeIsolated { }` because XCTest ObjC bridge makes them `nonisolated`
- Use `#filePath` (not `#file`) for `XCTFail` and similar APIs
