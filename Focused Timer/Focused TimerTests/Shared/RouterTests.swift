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

    @Test("Router starts with all sheets hidden and no pending signal")
    func initialState() {
        let router = Router()

        #expect(router.isShowingSettings == false)
        #expect(router.isShowingHelp == false)
        #expect(router.settingsDidChange == false)
        #expect(router.settingsDisplaysWarning == false)
    }

    // MARK: - openSettings

    @Test("openSettings sets isShowingSettings to true")
    func openSettingsSetsFlag() {
        let router = Router()
        router.openSettings(isTimerActive: false)
        #expect(router.isShowingSettings == true)
    }

    @Test("openSettings stores warning flag matching isTimerActive true")
    func openSettingsWarningWhenTimerActive() {
        let router = Router()
        router.openSettings(isTimerActive: true)
        #expect(router.settingsDisplaysWarning == true)
    }

    @Test("openSettings stores warning flag matching isTimerActive false")
    func openSettingsNoWarningWhenTimerInactive() {
        let router = Router()
        router.openSettings(isTimerActive: false)
        #expect(router.settingsDisplaysWarning == false)
    }

    @Test("openSettings does not affect isShowingHelp")
    func openSettingsDoesNotAffectHelp() {
        let router = Router()
        router.openSettings(isTimerActive: false)
        #expect(router.isShowingHelp == false)
    }

    // MARK: - openHelp

    @Test("openHelp sets isShowingHelp to true")
    func openHelpSetsFlag() {
        let router = Router()
        router.openHelp()
        #expect(router.isShowingHelp == true)
    }

    @Test("openHelp does not affect isShowingSettings")
    func openHelpDoesNotAffectSettings() {
        let router = Router()
        router.openHelp()
        #expect(router.isShowingSettings == false)
    }

    // MARK: - signalSettingsChanged

    @Test("signalSettingsChanged sets settingsDidChange to true")
    func signalSettingsChangedSetsFlag() {
        let router = Router()
        router.signalSettingsChanged()
        #expect(router.settingsDidChange == true)
    }

    @Test("signalSettingsChanged does not affect sheet presentation flags")
    func signalSettingsChangedDoesNotOpenSheets() {
        let router = Router()
        router.signalSettingsChanged()
        #expect(router.isShowingSettings == false)
        #expect(router.isShowingHelp == false)
    }

    // MARK: - Combined scenarios

    @Test("settingsDisplaysWarning updates correctly on repeated calls")
    func settingsDisplaysWarningUpdates() {
        let router = Router()
        router.openSettings(isTimerActive: true)
        #expect(router.settingsDisplaysWarning == true)

        router.openSettings(isTimerActive: false)
        #expect(router.settingsDisplaysWarning == false)
    }
}
