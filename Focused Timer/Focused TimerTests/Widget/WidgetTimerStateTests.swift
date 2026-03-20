//
//  WidgetTimerStateTests.swift
//  Focused TimerTests
//
//  Tests for WidgetTimerState: Codable round-trip and placeholder defaults.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("WidgetTimerState Tests")
struct WidgetTimerStateTests {

    // MARK: - Codable Round-Trip

    @Test("Codable round-trip preserves all fields")
    func codableRoundTrip() throws {
        let original = WidgetTimerState(
            timerType: "Short Break",
            endTime: Date(timeIntervalSince1970: 1_000_000),
            remainingSeconds: 300,
            totalSeconds: 600,
            completedCycles: 2,
            totalCycles: 4,
            state: "running",
            updatedAt: Date(timeIntervalSince1970: 999_000)
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetTimerState.self, from: encoded)

        #expect(decoded.timerType == original.timerType)
        #expect(decoded.endTime == original.endTime)
        #expect(decoded.remainingSeconds == original.remainingSeconds)
        #expect(decoded.totalSeconds == original.totalSeconds)
        #expect(decoded.completedCycles == original.completedCycles)
        #expect(decoded.totalCycles == original.totalCycles)
        #expect(decoded.state == original.state)
        #expect(decoded.updatedAt == original.updatedAt)
    }

    @Test("Codable round-trip with nil endTime preserves nil")
    func codableRoundTripNilEndTime() throws {
        let original = WidgetTimerState(
            timerType: "Focus",
            endTime: nil,
            remainingSeconds: 1500,
            totalSeconds: 1500,
            completedCycles: 0,
            totalCycles: 4,
            state: "paused",
            updatedAt: Date(timeIntervalSince1970: 0)
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetTimerState.self, from: encoded)

        #expect(decoded.endTime == nil)
        #expect(decoded.state == "paused")
    }

    // MARK: - Placeholder

    @Test("placeholder has Focus timer type")
    func placeholderTimerType() {
        #expect(WidgetTimerState.placeholder.timerType == "Focus")
    }

    @Test("placeholder has initial state")
    func placeholderState() {
        #expect(WidgetTimerState.placeholder.state == "initial")
    }

    @Test("placeholder endTime is nil")
    func placeholderEndTimeIsNil() {
        #expect(WidgetTimerState.placeholder.endTime == nil)
    }

    @Test("placeholder remainingSeconds matches totalSeconds")
    func placeholderTimeConsistency() {
        let placeholder = WidgetTimerState.placeholder
        #expect(placeholder.remainingSeconds == placeholder.totalSeconds)
    }

    @Test("placeholder has positive remaining seconds")
    func placeholderPositiveTime() {
        #expect(WidgetTimerState.placeholder.remainingSeconds > 0)
    }

    @Test("placeholder has positive total cycles")
    func placeholderPositiveCycles() {
        #expect(WidgetTimerState.placeholder.totalCycles > 0)
    }

    // MARK: - Storage Constants

    @Test("appGroupID is non-empty")
    func appGroupIDNonEmpty() {
        #expect(!WidgetTimerState.appGroupID.isEmpty)
    }

    @Test("storageKey is non-empty")
    func storageKeyNonEmpty() {
        #expect(!WidgetTimerState.storageKey.isEmpty)
    }
}
