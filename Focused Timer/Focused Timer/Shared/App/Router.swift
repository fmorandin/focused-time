//
//  Router.swift
//  Focused Timer
//
//  Centralizes all navigation state for the app.
//  Views read from and write to the router rather than managing their own
//  @State presentation booleans. This enables the coordinator pattern for
//  future features: ads interstitials, paywall, conditional onboarding.
//

import Foundation
import Observation

@Observable
final class Router {

    // MARK: - Tab Navigation

    enum AppTab {
        case timer, settings, help
    }

    var selectedTab: AppTab = .timer

    /// Destinations that can be pushed on top of the settings tab.
    enum SettingsRoute: Hashable {
        case changelog
    }

    /// Navigation stack backing the settings tab.
    var settingsPath: [SettingsRoute] = []

    // MARK: - What's New

    /// Whether the "What's New" modal is on screen.
    var isWhatsNewPresented = false

    // MARK: - Cross-Feature Signaling

    /// Set to `true` by the settings tab when the user changes settings.
    /// `TimerView` observes this and resets the timer when it becomes `true`,
    /// then resets it back to `false`. Replaces the old `NotificationCenter` approach.
    var settingsDidChange = false

    /// Whether to show the "timer is running" warning in the settings tab.
    /// Populated before setting `selectedTab = .settings`.
    var settingsDisplaysWarning = false

    // MARK: - Actions

    func selectSettings(isTimerActive: Bool) {
        settingsDisplaysWarning = isTimerActive
        selectedTab = .settings
    }

    func selectHelp() {
        selectedTab = .help
    }

    func signalSettingsChanged() {
        settingsDidChange = true
    }

    func presentWhatsNew() {
        isWhatsNewPresented = true
    }

    func dismissWhatsNew() {
        isWhatsNewPresented = false
    }
}
