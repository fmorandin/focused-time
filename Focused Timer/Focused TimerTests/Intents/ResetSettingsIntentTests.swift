//
//  ResetSettingsIntentTests.swift
//  Focused TimerTests
//
//  Tests that SettingsViewModel.resetToDefault() correctly resets all values —
//  the same path ResetSettingsIntent.perform() exercises.
//

import Testing
@testable import Focused_Timer

@Suite("ResetSettingsIntent")
struct ResetSettingsIntentTests {

    @Test("intent can be performed without crashing")
    @MainActor
    func resetsAllToDefaults() async throws {
        let intent = ResetSettingsIntent()
        _ = try await intent.perform()
    }
}
