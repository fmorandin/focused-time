//
//  WidgetTimerToggleIntent.swift
//  FocusedTimerWidgets
//
//  AppIntent that toggles the timer between running and paused by updating App Groups
//  UserDefaults directly. Never touches TimerService — widget intents run in a separate
//  process and cannot access the main app singleton.
//
//  isDiscoverable = false keeps this out of the Shortcuts app (widget-only).
//

import AppIntents
import Foundation
import WidgetKit

struct WidgetTimerToggleIntent: AppIntent {

    static let title: LocalizedStringResource = "Toggle Timer"
    static let isDiscoverable: Bool = false

    // Overridable for unit tests — points at the App Groups suite in production.
    nonisolated(unsafe) static var storageSuiteName: String = WidgetTimerState.appGroupID

    func perform() async throws -> some IntentResult {
        guard
            let defaults = UserDefaults(suiteName: Self.storageSuiteName),
            let data = defaults.data(forKey: WidgetTimerState.storageKey),
            var state = try? JSONDecoder().decode(WidgetTimerState.self, from: data)
        else { return .result() }

        state.toggle()

        if let encoded = try? JSONEncoder().encode(state) {
            defaults.set(encoded, forKey: WidgetTimerState.storageKey)
        }

        // Signal the main app so it can re-sync without waiting for a foreground
        // transition (relevant when the app is foregrounded but the user interacts
        // with the widget from Control Center / Notification Center / Stack widgets).
        WidgetStateBridge.postChange()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
