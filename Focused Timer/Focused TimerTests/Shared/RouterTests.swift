//
//  RouterTests.swift
//  Focused TimerTests
//
//  Tests for Router — the coordinator that centralises navigation state and
//  cross-feature signalling, replacing ad-hoc @State booleans and NotificationCenter.
//

import Testing
@testable import Focused_Timer

@MainActor
@Suite("Router Tests", .serialized)
struct RouterTests {

    // MARK: - Initial State

    @Test("Router starts on the timer tab with no pending signal")
    func initialState() {
        let router = Router()

        #expect(router.selectedTab == .timer)
        #expect(router.settingsDidChange == false)
        #expect(router.settingsDisplaysWarning == false)
    }

    // MARK: - selectSettings

    @Test("selectSettings navigates to the settings tab")
    func selectSettingsSetsTab() {
        let router = Router()
        router.selectSettings(isTimerActive: false)
        #expect(router.selectedTab == .settings)
    }

    @Test("selectSettings stores warning flag matching isTimerActive true")
    func selectSettingsWarningWhenTimerActive() {
        let router = Router()
        router.selectSettings(isTimerActive: true)
        #expect(router.settingsDisplaysWarning == true)
    }

    @Test("selectSettings stores warning flag matching isTimerActive false")
    func selectSettingsNoWarningWhenTimerInactive() {
        let router = Router()
        router.selectSettings(isTimerActive: false)
        #expect(router.settingsDisplaysWarning == false)
    }

    @Test("selectSettings does not navigate to help tab")
    func selectSettingsDoesNotSelectHelp() {
        let router = Router()
        router.selectSettings(isTimerActive: false)
        #expect(router.selectedTab != .help)
    }

    // MARK: - selectHelp

    @Test("selectHelp navigates to the help tab")
    func selectHelpSetsTab() {
        let router = Router()
        router.selectHelp()
        #expect(router.selectedTab == .help)
    }

    @Test("selectHelp does not navigate to settings tab")
    func selectHelpDoesNotSelectSettings() {
        let router = Router()
        router.selectHelp()
        #expect(router.selectedTab != .settings)
    }

    // MARK: - signalSettingsChanged

    @Test("signalSettingsChanged sets settingsDidChange to true")
    func signalSettingsChangedSetsFlag() {
        let router = Router()
        router.signalSettingsChanged()
        #expect(router.settingsDidChange == true)
    }

    @Test("signalSettingsChanged does not change the selected tab")
    func signalSettingsChangedDoesNotChangeTab() {
        let router = Router()
        router.signalSettingsChanged()
        #expect(router.selectedTab == .timer)
    }

    // MARK: - Combined scenarios

    @Test("settingsDisplaysWarning updates correctly on repeated calls")
    func settingsDisplaysWarningUpdates() {
        let router = Router()
        router.selectSettings(isTimerActive: true)
        #expect(router.settingsDisplaysWarning == true)

        router.selectSettings(isTimerActive: false)
        #expect(router.settingsDisplaysWarning == false)
    }
}
