//
//  TimerType.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 09/02/21.
//

import AppIntents
import Foundation

enum TimerType: String {

    case focused = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    func getCorrectTranslation() -> LocalizedStringResource {

        switch self {
        case .focused:
            return LocalizedStringResource("focusName", table: "Localizable")
        case .shortBreak:
            return LocalizedStringResource("shortBreakName", table: "Localizable")
        case .longBreak:
            return LocalizedStringResource("longBreakName", table: "Localizable")
        }
    }

    var alarmTitle: LocalizedStringResource {
        switch self {
        case .focused:
            return LocalizedStringResource("alarmTitleFocus", table: "Localizable")
        case .shortBreak:
            return LocalizedStringResource("alarmTitleShortBreak", table: "Localizable")
        case .longBreak:
            return LocalizedStringResource("alarmTitleLongBreak", table: "Localizable")
        }
    }

    var userDefaultKey: String {
        switch self {
        case .focused:
            return UserDefaultKeys.focusedTime
        case .shortBreak:
            return UserDefaultKeys.shortBreakTime
        case .longBreak:
            return UserDefaultKeys.longBreakTime
        }
    }
}

// MARK: - AppEnum

extension TimerType: AppEnum {

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Timer Type")
    }

    static var caseDisplayRepresentations: [TimerType: DisplayRepresentation] {
        [
            .focused: "Focus",
            .shortBreak: "Short Break",
            .longBreak: "Long Break"
        ]
    }
}
