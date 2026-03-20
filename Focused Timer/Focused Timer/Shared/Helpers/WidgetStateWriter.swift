//
//  WidgetStateWriter.swift
//  Focused Timer
//
//  Encodes WidgetTimerState into App Groups UserDefaults and signals WidgetKit to reload
//  all timelines. Call this whenever the timer state changes so widgets stay in sync.
//
//  Requires: WidgetKit.framework linked to the main app target (Phase 0 manual step).
//

import Foundation
import WidgetKit
import os

struct WidgetStateWriter {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WidgetStateWriter.self)
    )

    /// Writes `state` to App Groups UserDefaults and reloads all widget timelines.
    /// Silently no-ops if the App Groups suite is unavailable (e.g. in unit tests).
    static func write(_ state: WidgetTimerState) {
        guard
            let defaults = UserDefaults(suiteName: UserDefaultKeys.appGroupSuite),
            let encoded = try? JSONEncoder().encode(state)
        else {
            logger.notice("⚠️ WidgetStateWriter: failed to encode state or open App Groups suite.")
            return
        }
        defaults.set(encoded, forKey: UserDefaultKeys.widgetTimerState)
        WidgetCenter.shared.reloadAllTimelines()
        logger.notice("📡 Widget state written — state: \(state.state), type: \(state.timerType).")
    }
}
