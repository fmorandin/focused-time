//
//  ResetTimerIntent.swift
//  Focused Timer
//
//  App Intent that resets the Pomodoro timer to its initial state.
//

import AppIntents

struct ResetTimerIntent: AppIntent {

    static let title: LocalizedStringResource = "Reset Timer"
    static let description: IntentDescription = "Resets the timer to its initial state."
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await perform(using: TimerService.shared)
    }

    @MainActor
    func perform(using timerService: any TimerServiceProtocol) async throws -> some IntentResult & ProvidesDialog {
        let viewModel = timerService.timerViewModel
        viewModel.resetUpdateTimer()
        return .result(dialog: "Timer reset.")
    }
}
