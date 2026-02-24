//
//  Shared.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI

// MARK: - Haptics

@MainActor
struct HapticsConstants {

    let impactLight = UIImpactFeedbackGenerator(style: .light)
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
}

// MARK: - Default values for timers

enum DefaultValuesConstants: Int {

    case defaultFocusedTime = 25
    case defaultShortBreakTime = 5
    case defaultLongBreakTime = 30
    case defaultNumberOfCycles = 4

    func inSeconds() -> Int {
        self.rawValue * 60
    }
}
