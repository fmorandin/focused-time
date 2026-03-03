//
//  TimerTypeTests.swift
//  Focused TimerTests
//
//  Tests for TimerType — verifies raw values and that getCorrectTranslation()
//  returns a LocalizedStringResource pointing at the right Localizable key
//  for each enum case.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("TimerType Tests")
struct TimerTypeTests {

    // MARK: - Raw values

    @Test("focused raw value is 'Focus'")
    func focusedRawValue() {
        #expect(TimerType.focused.rawValue == "Focus")
    }

    @Test("shortBreak raw value is 'Short Break'")
    func shortBreakRawValue() {
        #expect(TimerType.shortBreak.rawValue == "Short Break")
    }

    @Test("longBreak raw value is 'Long Break'")
    func longBreakRawValue() {
        #expect(TimerType.longBreak.rawValue == "Long Break")
    }

    // MARK: - getCorrectTranslation

    @Test("focused getCorrectTranslation returns the focusName key")
    func focusedTranslationKey() {
        let resource = TimerType.focused.getCorrectTranslation()
        let expected = LocalizedStringResource("focusName", table: "Localizable")
        #expect(resource == expected)
    }

    @Test("shortBreak getCorrectTranslation returns the shortBreakName key")
    func shortBreakTranslationKey() {
        let resource = TimerType.shortBreak.getCorrectTranslation()
        let expected = LocalizedStringResource("shortBreakName", table: "Localizable")
        #expect(resource == expected)
    }

    @Test("longBreak getCorrectTranslation returns the longBreakName key")
    func longBreakTranslationKey() {
        let resource = TimerType.longBreak.getCorrectTranslation()
        let expected = LocalizedStringResource("longBreakName", table: "Localizable")
        #expect(resource == expected)
    }

    // MARK: - Distinct keys

    @Test("each case returns a distinct LocalizedStringResource key")
    func allTranslationKeysAreDistinct() {
        let resources = [
            TimerType.focused.getCorrectTranslation(),
            TimerType.shortBreak.getCorrectTranslation(),
            TimerType.longBreak.getCorrectTranslation()
        ]
        #expect(resources[0] != resources[1])
        #expect(resources[0] != resources[2])
        #expect(resources[1] != resources[2])
    }
}
