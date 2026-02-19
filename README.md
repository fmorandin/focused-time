# Focused Timer
Focused Timer was created to help everyone who needs to concentrate and finish tasks by making it very simple to follow the basic Pomodoro rules.

## Motivation
The main motivation to create this app was learn how `SwiftUI` works and also try to get more familiar with the `MVVM` architeture.
While I was thinking about what kind app would be a good candidate to fullfil the goal above I noticed that I could use myself a timer app to help me get
my activities done so I decided to merge the two things and make the app that I would use (the most commom developer thinking, right?).

## Technologies
Since this is a very simple app with no network requirements, everything is only done localy on the device.
The app was created using `SwiftUI` and `MVVM`.
It also have Unit and UI Tests - all using `XCTest` and saves user preferences in `UserDefaults`.

## SwiftLint
SwiftLint runs on every build (including incremental builds) through an Xcode Run Script Build Phase.

- Install locally with Homebrew:
  - `brew install swiftlint`
- Manual run from project root:
  - `swiftlint lint --config "Focused Timer/.swiftlint.yml"`
- Xcode Cloud:
  - `ci_scripts/ci_post_clone.sh` installs SwiftLint and validates the pinned version before the build starts.

## Download
The app can be installed via [AppStore](https://apps.apple.com/br/app/focused-timer/id1563481123).
