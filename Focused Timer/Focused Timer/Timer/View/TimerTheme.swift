//
//  TimerTheme.swift
//  Focused Timer
//
//  Centralizes all visual theming decisions per timer type.
//  By isolating colors here, Liquid Glass material adoption and dark-mode
//  variants only require changes in one place.
//

import SwiftUI

struct TimerTheme {

    /// The primary accent color for the circular progress ring.
    let accentColor: Color

    // MARK: - Factory

    /// Returns the correct theme for a given timer phase.
    static func theme(for timerType: TimerType) -> TimerTheme {
        switch timerType {
        case .focused:
            return TimerTheme(accentColor: .accentColor)
        case .shortBreak:
            return TimerTheme(accentColor: .shortBreakColor)
        case .longBreak:
            return TimerTheme(accentColor: .longBreakColor)
        }
    }

    /// Convenience accessor — returns just the accent color for a timer type.
    static func color(for timerType: TimerType) -> Color {
        theme(for: timerType).accentColor
    }
}
