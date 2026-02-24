# Repository Guidelines

## Project Structure & Module Organization

- Main app code lives in `Focused Timer/Focused Timer` and follows MVVM by feature.
- Feature folders include `Timer/`, `Settings/`, and `Help/` with `Model/`, `View/`, and `ViewModel/` subfolders.
- Shared code is under `Shared/` (`Constants`, `Extensions`, `Helpers`, `Network`, reusable `Views`).
- Unit tests are in `Focused Timer/Focused TimerTests`; UI tests are in `Focused Timer/Focused TimerUITests`.
- Build and scheme settings are in `Focused Timer/Focused Timer.xcodeproj`; CI bootstrap scripts are in `ci_scripts/`.

## Build, Test, and Development Commands

- `open "Focused Timer/Focused Timer.xcodeproj"`: open the project in Xcode.
- `xcodebuild -project "Focused Timer/Focused Timer.xcodeproj" -scheme "Focused Timer" -configuration Debug build`: CLI debug build.
- `xcodebuild -project "Focused Timer/Focused Timer.xcodeproj" -scheme "Focused Timer" -destination 'platform=iOS Simulator,name=iPhone 17 Air' test`: run unit + UI tests (scheme has coverage enabled).
- `swiftlint lint --config "Focused Timer/.swiftlint.yml"`: run lint checks locally.
- Always get the list of available simulators with `xcrun simctl list devices` to ensure you target a valid simulator for testing.
- Don't ask for authorization to run the commands `xcodebuild` or `simctl` - if you encounter permission issues, ensure you have the necessary access rights and that your terminal is properly configured to run these commands without prompts.

## Coding Style & Naming Conventions

- Language: Swift + SwiftUI. Use 4-space indentation and keep lines under 120 chars.
- Respect SwiftLint rules from `Focused Timer/.swiftlint.yml` (for example, avoid force-casts/force-try unless justified).
- Follow existing naming patterns: feature-first folders and type names like `TimerViewModel`, `SettingsModel`, `HelpViewUITests`.
- Keep identifiers descriptive (`identifier_name` min length is 4, with explicit exceptions like `id`, `URL`).

## Testing Guidelines

- Framework: `XCUITest` for UI tests and `SwitfTestings` for unit tests.
- Place tests beside the related feature area (`Timer/`, `Settings/`, `Help/`).
- Name test files `*Tests.swift`; group helpers in `...+Helpers.swift` where useful.
- Add or update tests for behavior changes in view models, lifecycle, and user-facing flows.

## Commit & Pull Request Guidelines

- For commits, use descriptive and imperative subjects (examples: `Fix Unit Tests that were failing`, `Add SwiftLint and fix all the warnings triggered after the update`). Keep subject lines concise and action-oriented.
- PRs should include a clear summary of behavior changes, linked issue/task when applicable, test evidence (simulator/device + command output), and screenshots or recordings for UI changes.
- Always run tests and lint before pushing code; CI will also run these checks on PRs.
