---
name: gen-test
description: Generate a unit test file for a given Swift source file, following project conventions (Swift Testing framework, protocol mocks, Swift 6 concurrency patterns)
disable-model-invocation: true
---
# Generate a unit test file for a given Swift source file, following project conventions (Swift Testing framework, protocol mocks, Swift 6 concurrency patterns)

Generate unit tests for the file specified in the arguments.

Follow these project-specific conventions:

- Use Swift Testing framework (@Test, @Suite, #expect)
- Use #filePath (not #file) in XCTest APIs
- Protocol-backed test doubles live in Focused TimerTests/Mock/
- TimerViewModel is NOT @MainActor; SettingsViewModel IS @MainActor
- Identifier names must be ≥4 chars (SwiftLint rule)
- Check existing tests in Focused TimerTests/ for patterns to follow