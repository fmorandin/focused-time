//
//  WidgetTimerToggleIntentTests.swift
//  Focused TimerTests
//
//  Tests for the toggle logic extracted from WidgetTimerToggleIntent into WidgetTimerState.toggle().
//  By testing the pure mutating function directly we avoid needing to import the widget extension
//  module, keeping the tests fast and self-contained.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("WidgetTimerState toggle() Tests")
struct WidgetTimerToggleIntentTests {

    // MARK: - Running → Paused

    @Test("running → paused: state changes to paused")
    func runningToPausedChangesState() {
        var state = makeRunningState(remainingSeconds: 300)

        state.toggle()

        #expect(state.state == "paused")
    }

    @Test("running → paused: endTime is cleared to nil")
    func runningToPausedClearsEndTime() {
        var state = makeRunningState(remainingSeconds: 300)

        state.toggle()

        #expect(state.endTime == nil)
    }

    @Test("running → paused: remainingSeconds derived from endTime")
    func runningToPausedDerivesRemainingFromEndTime() {
        let toggleDate = Date(timeIntervalSince1970: 1_000)
        let endTime = Date(timeIntervalSince1970: 1_120) // 120 seconds away
        var state = WidgetTimerState(
            timerType: "Focus",
            endTime: endTime,
            remainingSeconds: 120,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "running",
            updatedAt: toggleDate.addingTimeInterval(-10)
        )

        state.toggle(at: toggleDate)

        #expect(state.remainingSeconds == 120)
    }

    @Test("running → paused: remainingSeconds clamped to minimum 1")
    func runningToPausedClampedToMinimumOne() {
        // endTime is in the past relative to toggleDate
        let toggleDate = Date(timeIntervalSince1970: 2_000)
        let endTime = Date(timeIntervalSince1970: 1_000) // already passed
        var state = WidgetTimerState(
            timerType: "Focus",
            endTime: endTime,
            remainingSeconds: 0,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "running",
            updatedAt: toggleDate.addingTimeInterval(-100)
        )

        state.toggle(at: toggleDate)

        #expect(state.remainingSeconds >= 1)
    }

    // MARK: - Paused → Running

    @Test("paused → running: state changes to running")
    func pausedToRunningChangesState() {
        var state = makePausedState(remainingSeconds: 500)

        state.toggle()

        #expect(state.state == "running")
    }

    @Test("paused → running: endTime is set")
    func pausedToRunningSetsEndTime() {
        var state = makePausedState(remainingSeconds: 500)

        state.toggle()

        #expect(state.endTime != nil)
    }

    @Test("paused → running: endTime equals toggleDate + remainingSeconds")
    func pausedToRunningEndTimeMatchesRemaining() throws {
        let toggleDate = Date(timeIntervalSince1970: 5_000)
        var state = WidgetTimerState(
            timerType: "Short Break",
            endTime: nil,
            remainingSeconds: 300,
            totalSeconds: 600,
            completedCycles: 1,
            totalCycles: 4,
            state: "paused",
            updatedAt: toggleDate.addingTimeInterval(-10)
        )

        state.toggle(at: toggleDate)

        let resultEndTime = try #require(state.endTime)
        let expected = toggleDate.addingTimeInterval(300)
        #expect(resultEndTime == expected)
    }

    // MARK: - Initial → Running

    @Test("initial → running: treated same as paused")
    func initialToRunningSetsRunningState() throws {
        var state = WidgetTimerState(
            timerType: "Focus",
            endTime: nil,
            remainingSeconds: 1500,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "initial",
            updatedAt: Date(timeIntervalSince1970: 100)
        )

        state.toggle()

        #expect(state.state == "running")
        try #require(state.endTime != nil)
    }

    // MARK: - updatedAt

    @Test("toggle always refreshes updatedAt to the provided date")
    func toggleRefreshesUpdatedAt() {
        let oldTimestamp = Date(timeIntervalSince1970: 0)
        let toggleDate = Date(timeIntervalSince1970: 9_999)
        var state = makePausedState(remainingSeconds: 900)
        state.updatedAt = oldTimestamp

        state.toggle(at: toggleDate)

        #expect(state.updatedAt == toggleDate)
    }

    // MARK: - Non-Timer Fields Preserved

    @Test("toggle preserves timerType, totalSeconds, completedCycles, totalCycles")
    func togglePreservesNonTimerFields() {
        var state = WidgetTimerState(
            timerType: "Long Break",
            endTime: nil,
            remainingSeconds: 900,
            totalSeconds: 1800,
            completedCycles: 3,
            totalCycles: 4,
            state: "paused",
            updatedAt: Date(timeIntervalSince1970: 50)
        )

        state.toggle()

        #expect(state.timerType == "Long Break")
        #expect(state.totalSeconds == 1800)
        #expect(state.completedCycles == 3)
        #expect(state.totalCycles == 4)
    }

    // MARK: - Helpers

    private func makeRunningState(remainingSeconds: Int) -> WidgetTimerState {
        let endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        return WidgetTimerState(
            timerType: "Focus",
            endTime: endTime,
            remainingSeconds: remainingSeconds,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "running",
            updatedAt: Date(timeIntervalSinceNow: -10)
        )
    }

    private func makePausedState(remainingSeconds: Int) -> WidgetTimerState {
        WidgetTimerState(
            timerType: "Focus",
            endTime: nil,
            remainingSeconds: remainingSeconds,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "paused",
            updatedAt: Date(timeIntervalSinceNow: -10)
        )
    }
}
