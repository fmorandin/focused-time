//
//  SetTimerDurationIntent.swift
//  Focused Timer
//
//  App Intent that sets the duration (in minutes) for a specific timer type.
//

import AppIntents

struct SetTimerDurationIntent: AppIntent {

    static let title: LocalizedStringResource = "Set Timer Duration"
    static let description: IntentDescription = "Sets the duration in minutes for a timer type."
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Timer Type")
    var timerType: TimerType

    @Parameter(title: "Minutes", inclusiveRange: (1, 999))
    var minutes: Int

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let settingsModel = SettingsModel()
        settingsModel.saveTime(time: minutes, for: timerType.userDefaultKey)

        let typeName = timerType.getCorrectTranslation()
        return .result(dialog: "\(typeName) duration set to \(minutes) minutes.")
    }
}
