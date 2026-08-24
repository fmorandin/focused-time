//
//  SetNumberOfCyclesIntent.swift
//  Focused Timer
//
//  App Intent that sets the number of Pomodoro cycles before a long break.
//

import AppIntents

struct SetNumberOfCyclesIntent: AppIntent {

    static let title: LocalizedStringResource = "Set Number of Cycles"
    static let description: IntentDescription = "Sets the number of focus cycles before a long break."
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Cycles", inclusiveRange: (1, 99))
    var cycles: Int

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let settingsModel = SettingsModel()
        settingsModel.saveNumberOfCycles(numberOfCycles: cycles, for: UserDefaultKeys.numberOfCycles)
        return .result(dialog: "Number of cycles set to \(cycles).")
    }
}
