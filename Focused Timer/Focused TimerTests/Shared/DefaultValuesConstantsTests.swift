//
//  DefaultValuesConstantsTests.swift
//  Focused TimerTests
//
//  Tests for DefaultValuesConstants — verifies that inSeconds() correctly
//  converts each enum's rawValue (minutes) to seconds, and that raw values
//  match the documented design choices (25/5/30/4).
//

import Testing
@testable import Focused_Timer

@Suite("DefaultValuesConstants Tests")
struct DefaultValuesConstantsTests {

    // MARK: - Raw values

    @Test("defaultFocusedTime raw value is 25 minutes")
    func focusedTimeRawValue() {
        #expect(DefaultValuesConstants.defaultFocusedTime.rawValue == 25)
    }

    @Test("defaultShortBreakTime raw value is 5 minutes")
    func shortBreakTimeRawValue() {
        #expect(DefaultValuesConstants.defaultShortBreakTime.rawValue == 5)
    }

    @Test("defaultLongBreakTime raw value is 30 minutes")
    func longBreakTimeRawValue() {
        #expect(DefaultValuesConstants.defaultLongBreakTime.rawValue == 30)
    }

    @Test("defaultNumberOfCycles raw value is 4")
    func numberOfCyclesRawValue() {
        #expect(DefaultValuesConstants.defaultNumberOfCycles.rawValue == 4)
    }

    // MARK: - inSeconds() conversion

    @Test("defaultFocusedTime inSeconds returns 1500")
    func focusedTimeInSeconds() {
        #expect(DefaultValuesConstants.defaultFocusedTime.inSeconds() == 1500)
    }

    @Test("defaultShortBreakTime inSeconds returns 300")
    func shortBreakTimeInSeconds() {
        #expect(DefaultValuesConstants.defaultShortBreakTime.inSeconds() == 300)
    }

    @Test("defaultLongBreakTime inSeconds returns 1800")
    func longBreakTimeInSeconds() {
        #expect(DefaultValuesConstants.defaultLongBreakTime.inSeconds() == 1800)
    }

    @Test("inSeconds converts rawValue by multiplying by 60")
    func inSecondsMultipliesBy60() {
        // Verifies the formula for all timer cases generically.
        let timerCases: [DefaultValuesConstants] = [
            .defaultFocusedTime,
            .defaultShortBreakTime,
            .defaultLongBreakTime
        ]
        for timerCase in timerCases {
            #expect(timerCase.inSeconds() == timerCase.rawValue * 60)
        }
    }
}
