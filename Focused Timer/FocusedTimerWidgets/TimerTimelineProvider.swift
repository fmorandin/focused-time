//
//  TimerTimelineProvider.swift
//  FocusedTimerWidgets
//
//  Reads App Groups UserDefaults to build a single-entry timeline.
//  Running timers use a live-countdown Text(timerInterval:) — no per-second entries needed.
//  The timeline refreshes itself when the phase ends (running) or after 15 minutes (paused/initial).
//

import Foundation
import WidgetKit

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let timerState: WidgetTimerState
}

struct TimerTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> TimerWidgetEntry {
        TimerWidgetEntry(date: Date(), timerState: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> Void) {
        completion(TimerWidgetEntry(date: Date(), timerState: readWidgetState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerWidgetEntry>) -> Void) {
        let currentDate = Date()
        let state = readWidgetState()
        let entry = TimerWidgetEntry(date: currentDate, timerState: state)

        let reloadPolicy: TimelineReloadPolicy
        if state.state == "running", let endTime = state.endTime {
            // Refresh shortly after the phase ends so the next phase label appears promptly.
            reloadPolicy = .after(endTime.addingTimeInterval(2))
        } else {
            // Static display — no urgent refresh needed.
            reloadPolicy = .after(currentDate.addingTimeInterval(15 * 60))
        }

        completion(Timeline(entries: [entry], policy: reloadPolicy))
    }

    // MARK: - Private

    private func readWidgetState() -> WidgetTimerState {
        guard
            let defaults = UserDefaults(suiteName: WidgetTimerState.appGroupID),
            let data = defaults.data(forKey: WidgetTimerState.storageKey),
            let state = try? JSONDecoder().decode(WidgetTimerState.self, from: data)
        else { return .placeholder }
        return state
    }
}
