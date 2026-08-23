# Focused Timer

A Pomodoro timer app for iOS that helps you concentrate and finish tasks by making it simple to follow the Pomodoro technique.

## Screenshots

| Timer | Settings | Help |
|---|---|---|
| ![Timer screen](docs/screenshots/01-timer.png) | ![Settings screen](docs/screenshots/02-settings.png) | ![Help screen](docs/screenshots/03-help.png) |

## Motivation

This app has always been a playground for me to learn new things. Version 1.0 was created when I wanted to learn how `SwiftUI` works and to get more familiar with the `MVVM` architecture. While thinking about a good candidate app, the need for a personal timer became apparent — so the two goals merged into one: build the app you'd actually use.

Version 2.0 was a more radical experiment: learning what I can do using AI to code an entire set of features end to end — from the domain logic and App Intents to AlarmKit integration and the test suite.

Version 2.1 continues that experiment with first-launch onboarding, a "What's New" screen so returning users can see what changed, clearer assistive-technology semantics, layouts that adapt to accessibility text sizes, accessible validation, and reduced motion.

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

### Onboarding

A concise guide explains focus sessions, short and long breaks, cycle tracking, and where to customize the app. It appears only on the first opening of a fresh installation. Existing installations are migrated silently, so adding onboarding in an update does not interrupt returning users.

### What's New

The first time the app is opened after an update that has release notes, a "What's New" sheet shows what changed in the latest version. It never appears on a fresh install, and it never appears twice for the same version.

The full release history is always available from **Settings → What's New**, independent of whether the modal has been seen.

### Accessibility

Focused Timer supports native accessibility features across its common tasks:

- VoiceOver labels and values for timer state, remaining time, cycle progress, controls, and settings
- Voice Control through native, visibly named controls
- Dynamic Type, including adaptive timer and Settings layouts at accessibility sizes
- Light and dark interfaces using system and adaptive colors
- Reduce Motion for timer, button, validation, and cycle transitions
- Text, symbols, and shapes in addition to color for important state and validation
- Accessible explanations for invalid input and unavailable settings

## Technologies

- **SwiftUI** — Declarative UI framework
- **MVVM** — Architecture pattern with protocol-based dependency injection for full unit testability
- **App Intents** — Siri & Shortcuts integration to start, pause, reset, and configure the timer hands-free
- **AlarmKit** — Schedules an alarm that rings even when the device is in silent mode
- **StoreKit** — Requests an App Store review after a full Pomodoro set completes
- **XCTest / Swift Testing** — Unit, UI, and snapshot tests
- **UserDefaults** — Local persistence via a `StorageRepository` abstraction
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
| `AlarmScheduling` | AlarmKit integration |
| `StorageRepository` | Key-value persistence |
| `ChangelogLoading` / `ChangelogDataProviding` | Loads and decodes the bundled changelog |
| `WhatsNewModelProtocol` | Persists which release the user has already seen |
| `OnboardingModelProtocol` | Persists whether the first-launch guide has been presented |

`TimerViewModel` accepts all of these as constructor parameters, enabling full injection of test doubles.

### Data Layer

`UserDefaultsRepository` is a generic `UserDefaults` wrapper conforming to the `StorageRepository` protocol. `TimerModel` and `SettingsModel` are thin structs that delegate entirely to it, and tests swap in an in-memory implementation.

### Localization

All user-facing strings live in `Focused Timer/Focused Timer/Shared/Constants/Localizable.xcstrings`.

Supported languages:
- English (`en`)
- Portuguese — Brazil (`pt-BR`)

Release notes are not part of the string catalog. Each supported language has its own changelog
file under `Focused Timer/Focused Timer/WhatsNew/Resources/Changelog_<language>.json`, resolved
at runtime by `BundleChangelogLoader` against `Bundle.main.preferredLocalizations`, falling back
to English. Adding a language means adding both a `Changelog_<language>.json` file **and** an
entry in `LocalizationTests.supportedLanguages` — the localization test suite checks the two stay
in sync, and fails the build if a release is added to one language's changelog but not the
other's.

### What's New

`WhatsNewUseCase` decides whether to show the modal by comparing the newest version *present in
the changelog* against the highest version the user has already seen (persisted via
`WhatsNewModelProtocol`) — not against the app's own `MARKETING_VERSION`. That means:

- A fresh install seeds the "last seen" version silently; nothing is shown.
- A patch release with no changelog entry shows nothing.
- Skipping several versions shows only the newest release's notes.
- A downgrade never shows anything and never moves the stored watermark backwards.

The release is marked as seen at presentation time, not on dismiss, so a force-quit mid-read
can't reopen the same notes on the next launch — the full changelog in Settings covers that case
instead.

### Launch Presentation Coordination

`Router.LaunchPresentation` provides one presentation slot shared by onboarding and What's New.
Onboarding has priority on a genuine first launch; What's New is evaluated only when onboarding
does not claim that launch. This makes the two sheets mutually exclusive rather than relying on
timing between independent presentation flags.

`OnboardingModel` records presentation immediately and detects existing installations before the
current launch writes its defaults. That keeps onboarding limited to the first opening after a
fresh install without showing it retroactively to current users.

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
- `AppVersionTests`
- `ChangelogTests`
- `ChangelogLoaderTests`
- `ChangelogResourceTests` — integration tests against the real bundled changelog files
- `WhatsNewUseCaseTests`
- `WhatsNewViewModelTests`
- `OnboardingTests`
- `ChangelogEntryStyleTests`
- Accessibility semantics and common-screen audits

### UI Tests

All UI tests extend `BaseFeature`, an `@MainActor` base class. The app supports a `"UI-Testing"` launch argument that clears `UserDefaults`, disables animations, and accepts fast timer durations via environment variables (`UI_TEST_FOCUSED_SECONDS`, `UI_TEST_SHORT_BREAK_SECONDS`, `UI_TEST_LONG_BREAK_SECONDS`, `UI_TEST_NUMBER_OF_CYCLES`).

`"UI-Testing"` also suppresses onboarding and the "What's New" modal, since it wipes `UserDefaults`
on every launch and would otherwise re-trigger first-launch presentation. A subclass can opt in
with `"UI-Testing-Onboarding"` or `"UI-Testing-WhatsNew"` — see `OnboardingForcedUITests` and
`WhatsNewForcedUITests`.

`AccessibilityUITests` runs XCTest accessibility audits on the Timer, Settings, and Help screens,
while focused suites audit the forced onboarding and What's New presentations. Snapshot tests also
cover the onboarding layout alongside the existing common-screen and accessibility-size snapshots.

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

SwiftLint runs as an Xcode build phase on every build. No specific version is pinned — the lint rules are version-agnostic, so the latest SwiftLint works fine.

- Install locally: `brew install swiftlint`
- Run manually from the project root:

```bash
swiftlint lint --config "Focused Timer/.swiftlint.yml"
```

Key constraints:
- 4-character minimum for identifier names
- 120-character line length limit
- `explicit_self` analyzer rule enabled

Xcode Cloud installs the latest SwiftLint via `ci_scripts/ci_post_clone.sh` before each build.

## Release Checklist

1. Add the new release to **both** `Changelog_en.json` and `Changelog_pt-BR.json` under `Focused Timer/Focused Timer/WhatsNew/Resources/`, with the same `version` in each.
2. Bump `MARKETING_VERSION` (and `CURRENT_PROJECT_VERSION`) in `project.pbxproj`.
3. Run `ChangelogResourceTests` — it fails if a version is missing from either language, if any entry is untranslated, or if the changelog announces a version ahead of the build.
4. Re-record the `SettingsSnapshotTests` `FormView` snapshots only if the Settings layout changed.
## Download

The app is available on the [App Store](https://apps.apple.com/app/focused-timer/id1563481123).
