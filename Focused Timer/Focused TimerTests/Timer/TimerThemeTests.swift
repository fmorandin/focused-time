//
//  TimerThemeTests.swift
//  Focused TimerTests
//
//  Tests for TimerTheme — verifies that each timer phase produces a theme,
//  that the convenience color(for:) accessor is consistent with theme(for:).accentColor,
//  and that all three phases produce distinct colors.
//

import SwiftUI
import Testing
@testable import Focused_Timer

@Suite("TimerTheme Tests")
struct TimerThemeTests {

    // MARK: - theme(for:) factory returns a value

    @Test("theme(for: .focused) returns a TimerTheme")
    func focusedThemeExists() {
        let theme = TimerTheme.theme(for: .focused)
        // Verifies the factory doesn't crash and returns a usable theme.
        _ = theme.accentColor
    }

    @Test("theme(for: .shortBreak) returns a TimerTheme")
    func shortBreakThemeExists() {
        let theme = TimerTheme.theme(for: .shortBreak)
        _ = theme.accentColor
    }

    @Test("theme(for: .longBreak) returns a TimerTheme")
    func longBreakThemeExists() {
        let theme = TimerTheme.theme(for: .longBreak)
        _ = theme.accentColor
    }

    // MARK: - color(for:) == theme(for:).accentColor

    @Test("color(for: .focused) matches theme(for: .focused).accentColor")
    func colorFocusedMatchesTheme() {
        #expect(TimerTheme.color(for: .focused) == TimerTheme.theme(for: .focused).accentColor)
    }

    @Test("color(for: .shortBreak) matches theme(for: .shortBreak).accentColor")
    func colorShortBreakMatchesTheme() {
        #expect(TimerTheme.color(for: .shortBreak) == TimerTheme.theme(for: .shortBreak).accentColor)
    }

    @Test("color(for: .longBreak) matches theme(for: .longBreak).accentColor")
    func colorLongBreakMatchesTheme() {
        #expect(TimerTheme.color(for: .longBreak) == TimerTheme.theme(for: .longBreak).accentColor)
    }

    // MARK: - Distinct colors per phase

    @Test("each timer type produces a distinct accent color")
    func distinctColorsPerPhase() {
        let focusedColor = TimerTheme.color(for: .focused)
        let shortBreakColor = TimerTheme.color(for: .shortBreak)
        let longBreakColor = TimerTheme.color(for: .longBreak)

        #expect(focusedColor != shortBreakColor)
        #expect(focusedColor != longBreakColor)
        #expect(shortBreakColor != longBreakColor)
    }

    // MARK: - Determinism

    @Test("theme(for:) returns the same color on repeated calls")
    func themeDeterministic() {
        #expect(TimerTheme.color(for: .focused) == TimerTheme.color(for: .focused))
        #expect(TimerTheme.color(for: .shortBreak) == TimerTheme.color(for: .shortBreak))
        #expect(TimerTheme.color(for: .longBreak) == TimerTheme.color(for: .longBreak))
    }
}
