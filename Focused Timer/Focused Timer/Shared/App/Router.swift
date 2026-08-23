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

    // MARK: - Launch Presentation

    enum LaunchPresentation: Hashable, Identifiable {
        case onboarding
        case whatsNew

        var id: Self { self }
    }

    /// A single presentation slot prevents onboarding and What's New from ever
    /// competing for the same launch.
    var launchPresentation: LaunchPresentation?

    var isOnboardingPresented: Bool {
        self.launchPresentation == .onboarding
    }

    var isWhatsNewPresented: Bool {
        self.launchPresentation == .whatsNew
    }

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
        guard self.launchPresentation == nil else { return }
        self.launchPresentation = .whatsNew
    }

    func dismissWhatsNew() {
        guard self.launchPresentation == .whatsNew else { return }
        self.launchPresentation = nil
    }

    func presentOnboarding() {
        guard self.launchPresentation == nil else { return }
        self.launchPresentation = .onboarding
    }

    func dismissOnboarding() {
        guard self.launchPresentation == .onboarding else { return }
        self.launchPresentation = nil
    }
}
