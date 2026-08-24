//
//  ResumeTimerIntent.swift
//  Focused Timer
//
//  App Intent that resumes a paused Pomodoro timer.
//

import AppIntents

struct ResumeTimerIntent: AppIntent {

    static let title: LocalizedStringResource = "Resume Timer"
    static let description: IntentDescription = "Resumes the paused timer."
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await perform(using: TimerService.shared)
    }

    @MainActor
    func perform(using timerService: any TimerServiceProtocol) async throws -> some IntentResult & ProvidesDialog {
        let viewModel = timerService.timerViewModel

        guard viewModel.timerState == .paused else {
            return .result(dialog: "Timer is not paused.")
        }

        viewModel.startTimer()
        return .result(dialog: "Timer resumed.")
    }
}
