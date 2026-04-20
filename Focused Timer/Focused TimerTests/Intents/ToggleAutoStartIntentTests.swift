//
//  ToggleAutoStartIntentTests.swift
//  Focused TimerTests
//  Tests ToggleAutoStartIntent side effects.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("ToggleAutoStartIntent", .serialized)
struct ToggleAutoStartIntentTests {

    @Test("enabling auto-start disables alarm and enables notifications")
    func enablingAutoStartAppliesDependentToggles() async throws {
        let defaults = UserDefaults.standard
        let keys = [
            UserDefaultKeys.autoStartToggle,
            UserDefaultKeys.enableAlarm,
            UserDefaultKeys.enableNotifications
        ]
        let previousValues = Dictionary(uniqueKeysWithValues: keys.map { userDefaultKey in
            (userDefaultKey, defaults.object(forKey: userDefaultKey))
        })
        defer {
            for (userDefaultKey, value) in previousValues {
                if let value {
                    defaults.set(value, forKey: userDefaultKey)
                } else {
                    defaults.removeObject(forKey: userDefaultKey)
                }
            }
        }

        defaults.set(true, forKey: UserDefaultKeys.enableAlarm)
        defaults.set(false, forKey: UserDefaultKeys.enableNotifications)

        var intent = ToggleAutoStartIntent()
        intent.enabled = true
        _ = try await intent.perform()

        #expect(defaults.bool(forKey: UserDefaultKeys.autoStartToggle) == true)
        #expect(defaults.bool(forKey: UserDefaultKeys.enableAlarm) == false)
        #expect(defaults.bool(forKey: UserDefaultKeys.enableNotifications) == true)
    }

    @Test("disabling auto-start does not override alarm and notifications")
    func disablingAutoStartKeepsDependentToggles() async throws {
        let defaults = UserDefaults.standard
        let keys = [
            UserDefaultKeys.autoStartToggle,
            UserDefaultKeys.enableAlarm,
            UserDefaultKeys.enableNotifications
        ]
        let previousValues = Dictionary(uniqueKeysWithValues: keys.map { userDefaultKey in
            (userDefaultKey, defaults.object(forKey: userDefaultKey))
        })
        defer {
            for (userDefaultKey, value) in previousValues {
                if let value {
                    defaults.set(value, forKey: userDefaultKey)
                } else {
                    defaults.removeObject(forKey: userDefaultKey)
                }
            }
        }

        defaults.set(true, forKey: UserDefaultKeys.enableAlarm)
        defaults.set(false, forKey: UserDefaultKeys.enableNotifications)

        var intent = ToggleAutoStartIntent()
        intent.enabled = false
        _ = try await intent.perform()

        #expect(defaults.bool(forKey: UserDefaultKeys.autoStartToggle) == false)
        #expect(defaults.bool(forKey: UserDefaultKeys.enableAlarm) == true)
        #expect(defaults.bool(forKey: UserDefaultKeys.enableNotifications) == false)
    }
}
