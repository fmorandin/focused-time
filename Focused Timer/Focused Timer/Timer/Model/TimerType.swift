//
//  TimerType.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 09/02/21.
//

import SwiftUI

enum TimerType: String {
    case focused = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    func getCorrectTranslation() -> LocalizedStringKey {
        switch self {
        case .focused:
            return Translation.focusName
        case .shortBreak:
            return Translation.shortBreakName
        case .longBreak:
            return Translation.longBreakName
        }
    }
}
