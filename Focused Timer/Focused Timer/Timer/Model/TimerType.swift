//
//  TimerType.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 09/02/21.
//

import SwiftUI

enum TimerType: String {
    case focused = "Focus"
    case rest = "Rest"
    case longBreak = "Long Break"

    func getCorrectTranslation() -> LocalizedStringKey {
        switch self {
        case .focused:
            return Translation.focusName
        case .rest:
            return Translation.restName
        case .longBreak:
            return Translation.longBreakName
        }
    }
}
