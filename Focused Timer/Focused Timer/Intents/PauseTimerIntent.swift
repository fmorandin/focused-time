//
//  PauseTimerIntent.swift
//  Focused Timer
//
//  App Intent that pauses the running Pomodoro timer.
//

import AppIntents

struct PauseTimerIntent: AppIntent {

    static let title: LocalizedStringResource = "Pause Timer"
    static let description: IntentDescription = "Pauses the currently running timer."
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await perform(using: TimerService.shared)
    }

    @MainActor
    func perform(using timerService: any TimerServiceProtocol) async throws -> some IntentResult & ProvidesDialog {
        let viewModel = timerService.timerViewModel

        guard viewModel.timerState == .running else {
            return .result(dialog: "Timer is not running.")
        }

        viewModel.pauseTimer()
        return .result(dialog: "Timer paused.")
    }
}
