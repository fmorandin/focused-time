//
//  WidgetTimerState.swift
//  Focused Timer
//
//  Shared Codable struct representing the timer state written to App Groups UserDefaults.
//  Added to BOTH the main app target and the FocusedTimerWidgets extension target.
//  Import Foundation only — no SwiftUI, no WidgetKit.
//

import Foundation

struct WidgetTimerState: Codable {

    /// TimerType.rawValue — "Focus" | "Short Break" | "Long Break"
    var timerType: String

    /// Non-nil when running: the Date at which the counter reaches zero.
    var endTime: Date?

    /// Counter value at the moment of last write. Used when paused or initial.
    var remainingSeconds: Int

    /// Full phase duration in seconds. Used for progress arc calculations.
    var totalSeconds: Int

    var completedCycles: Int
    var totalCycles: Int

    /// "running" | "paused" | "initial"
    var state: String

    /// Timestamp of last write. Used to detect widget-initiated changes while the app was backgrounded.
    var updatedAt: Date

    // MARK: - Shared Storage Constants

    /// App Groups suite identifier shared between the main app and the widget extension.
    static let appGroupID = "group.br.com.felipemorandin.FocusedTimer"

    /// UserDefaults key used to store the encoded WidgetTimerState blob.
    static let storageKey = "widgetTimerState"

    // MARK: - Toggle Logic

    /// Toggles between running and paused, updating all dependent fields atomically.
    /// Extracted here so the unit-test target can exercise the logic without importing
    /// the widget extension module.
    mutating func toggle(at date: Date = Date()) {
        if state == "running" {
            // Running → pause: derive remaining seconds from the live deadline.
            let remaining = endTime.map { max(1, Int($0.timeIntervalSince(date))) }
                ?? remainingSeconds
            remainingSeconds = remaining
            endTime = nil
            state = "paused"
        } else {
            // Paused / initial → running: set a fresh deadline.
            endTime = date.addingTimeInterval(TimeInterval(remainingSeconds))
            state = "running"
        }
        updatedAt = date
    }

    // MARK: - Placeholder

    static var placeholder: WidgetTimerState {
        WidgetTimerState(
            timerType: "Focus",
            endTime: nil,
            remainingSeconds: 25 * 60,
            totalSeconds: 25 * 60,
            completedCycles: 0,
            totalCycles: 4,
            state: "initial",
            updatedAt: Date()
        )
    }
}
