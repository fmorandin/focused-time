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

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let viewModel = TimerService.shared.timerViewModel

        guard viewModel.timerState == .running else {
            return .result(dialog: "Timer is not running.")
        }

        viewModel.pauseTimer()
        return .result(dialog: "Timer paused.")
    }
}
