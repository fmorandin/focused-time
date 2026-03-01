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

final class Router: ObservableObject {

    // MARK: - Sheet Presentation

    @Published var isShowingSettings = false
    @Published var isShowingHelp = false

    // MARK: - Cross-Feature Signaling

    /// Set to `true` by the settings sheet when the user changes settings.
    /// `TimerView` observes this and resets the timer when it becomes `true`,
    /// then resets it back to `false`. Replaces the old `NotificationCenter` approach.
    @Published var settingsDidChange = false

    /// Whether to show the "timer is running" warning in the settings sheet.
    /// Populated by the caller before setting `isShowingSettings = true`.
    var settingsDisplaysWarning = false

    // MARK: - Actions

    func openSettings(isTimerActive: Bool) {
        settingsDisplaysWarning = isTimerActive
        isShowingSettings = true
    }

    func openHelp() {
        isShowingHelp = true
    }

    func signalSettingsChanged() {
        settingsDidChange = true
    }
}
