//
//  SettingsViewModelAlarmAuthTests.swift
//  Focused TimerTests
//

import Foundation
import Testing
import UIKit
@testable import Focused_Timer

@MainActor
@Suite("SettingsViewModel Alarm Authorization Tests", .serialized)
struct SettingsViewModelAlarmAuthTests {

    private final class AlarmAuthorizationCheckerStub: AlarmAuthorizationChecking {
        var isDeniedBySystem: Bool = false
    }

    @Test("checkAlarmAuthorizationStatus sets denied flag when alarm is denied")
    func checkAlarmAuthorizationStatusSetsDeniedFlag() {
        let checker = AlarmAuthorizationCheckerStub()
        checker.isDeniedBySystem = true
        let settingsViewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            alarmAuthorizationChecker: checker
        )

        settingsViewModel.checkAlarmAuthorizationStatus()

        #expect(settingsViewModel.isAlarmDeniedBySystem == true)
    }

    @Test("checkAlarmAuthorizationStatus clears denied flag when alarm is authorized")
    func checkAlarmAuthorizationStatusClearsDeniedFlag() {
        let checker = AlarmAuthorizationCheckerStub()
        checker.isDeniedBySystem = false
        let settingsViewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            alarmAuthorizationChecker: checker
        )
        settingsViewModel.isAlarmDeniedBySystem = true

        settingsViewModel.checkAlarmAuthorizationStatus()

        #expect(settingsViewModel.isAlarmDeniedBySystem == false)
    }

    @Test("isAlarmDeniedBySystem is false initially")
    func isAlarmDeniedBySystemIsFalseInitially() {
        let checker = AlarmAuthorizationCheckerStub()
        let settingsViewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            alarmAuthorizationChecker: checker
        )

        #expect(settingsViewModel.isAlarmDeniedBySystem == false)
    }

    @Test("openAlarmSettings opens the settings URL exactly once per call")
    func openAlarmSettingsOpensURLOnce() async {
        let urlOpenerSpy = URLOpenerSpy()
        let settingsViewModel = SettingsViewModel(
            settingsModel: SettingsModelMock(),
            urlOpener: urlOpenerSpy
        )

        await settingsViewModel.openAlarmSettings()

        #expect(urlOpenerSpy.openedURLs.count == 1)
        #expect(urlOpenerSpy.openedURLs.first?.absoluteString == UIApplication.openSettingsURLString)
    }
}

@MainActor
private final class URLOpenerSpy: URLOpening {
    var openedURLs: [URL] = []

    func open(_ targetURL: URL) async -> Bool {
        openedURLs.append(targetURL)
        return true
    }
}
