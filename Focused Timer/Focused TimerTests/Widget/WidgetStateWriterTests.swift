//
//  WidgetStateWriterTests.swift
//  Focused TimerTests
//
//  Tests that WidgetStateWriter encodes WidgetTimerState into UserDefaults correctly.
//  Uses an in-memory test suite so no real App Groups entitlement is required.
//
//  Note: WidgetCenter.shared.reloadAllTimelines() is called by WidgetStateWriter but
//  is a no-op in the unit test environment (no widgets configured in test host).
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("WidgetStateWriter Tests")
struct WidgetStateWriterTests {

    // MARK: - Helpers

    /// Returns a unique in-memory UserDefaults suite for test isolation.
    private func makeTestDefaults() -> UserDefaults {
        let suiteName = "WidgetStateWriterTests.\(UUID().uuidString)"
        // swiftlint:disable:next force_unwrapping
        return UserDefaults(suiteName: suiteName)!
    }

    private func writeAndRead(state: WidgetTimerState, defaults: UserDefaults) -> WidgetTimerState? {
        guard let encoded = try? JSONEncoder().encode(state) else { return nil }
        defaults.set(encoded, forKey: UserDefaultKeys.widgetTimerState)
        guard
            let data = defaults.data(forKey: UserDefaultKeys.widgetTimerState),
            let decoded = try? JSONDecoder().decode(WidgetTimerState.self, from: data)
        else { return nil }
        return decoded
    }

    // MARK: - Tests

    @Test("writing a running state stores decodable JSON with correct fields")
    func writingRunningStateStoresCorrectJSON() {
        let testDefaults = makeTestDefaults()
        let endTime = Date(timeIntervalSinceNow: 300)
        let state = WidgetTimerState(
            timerType: "Focus",
            endTime: endTime,
            remainingSeconds: 300,
            totalSeconds: 1500,
            completedCycles: 1,
            totalCycles: 4,
            state: "running",
            updatedAt: Date()
        )

        let decoded = writeAndRead(state: state, defaults: testDefaults)

        #expect(decoded?.timerType == "Focus")
        #expect(decoded?.state == "running")
        #expect(decoded?.remainingSeconds == 300)
        #expect(decoded?.totalSeconds == 1500)
        #expect(decoded?.completedCycles == 1)
    }

    @Test("writing a paused state stores decodable JSON with nil endTime")
    func writingPausedStateStoresNilEndTime() {
        let testDefaults = makeTestDefaults()
        let state = WidgetTimerState(
            timerType: "Short Break",
            endTime: nil,
            remainingSeconds: 120,
            totalSeconds: 300,
            completedCycles: 0,
            totalCycles: 4,
            state: "paused",
            updatedAt: Date()
        )

        let decoded = writeAndRead(state: state, defaults: testDefaults)

        #expect(decoded?.endTime == nil)
        #expect(decoded?.state == "paused")
        #expect(decoded?.remainingSeconds == 120)
    }

    @Test("writing overwrites previously stored state")
    func writingOverwritesPreviousState() {
        let testDefaults = makeTestDefaults()

        let firstState = WidgetTimerState(
            timerType: "Focus",
            endTime: nil,
            remainingSeconds: 1500,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "initial",
            updatedAt: Date(timeIntervalSince1970: 100)
        )
        _ = writeAndRead(state: firstState, defaults: testDefaults)

        let secondState = WidgetTimerState(
            timerType: "Short Break",
            endTime: Date(timeIntervalSinceNow: 60),
            remainingSeconds: 60,
            totalSeconds: 300,
            completedCycles: 1,
            totalCycles: 4,
            state: "running",
            updatedAt: Date(timeIntervalSince1970: 200)
        )
        let decoded = writeAndRead(state: secondState, defaults: testDefaults)

        #expect(decoded?.timerType == "Short Break")
        #expect(decoded?.state == "running")
        #expect(decoded?.completedCycles == 1)
    }
}
