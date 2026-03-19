//
//  FocusedTimerShortcuts.swift
//  Focused Timer
//
//  Registers pre-built Siri phrases so users can control the timer by voice.
//

import AppIntents

struct FocusedTimerShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartTimerIntent(),
            phrases: [
                "Start a focus session in \(.applicationName)",
                "Start \(.applicationName)"
            ],
            shortTitle: "Start Timer",
            systemImageName: "play.circle.fill"
        )
        AppShortcut(
            intent: PauseTimerIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "Pause the timer in \(.applicationName)"
            ],
            shortTitle: "Pause Timer",
            systemImageName: "pause.circle.fill"
        )
        AppShortcut(
            intent: ResumeTimerIntent(),
            phrases: [
                "Resume \(.applicationName)",
                "Continue \(.applicationName)"
            ],
            shortTitle: "Resume Timer",
            systemImageName: "play.circle"
        )
        AppShortcut(
            intent: ResetTimerIntent(),
            phrases: [
                "Reset \(.applicationName)",
                "Reset the timer in \(.applicationName)"
            ],
            shortTitle: "Reset Timer",
            systemImageName: "arrow.clockwise.circle.fill"
        )
        AppShortcut(
            intent: GetTimerStatusIntent(),
            phrases: [
                "How much time is left in \(.applicationName)",
                "Check \(.applicationName)"
            ],
            shortTitle: "Timer Status",
            systemImageName: "clock.fill"
        )
        AppShortcut(
            intent: SetTimerDurationIntent(),
            phrases: [
                "Set focus duration in \(.applicationName)"
            ],
            shortTitle: "Set Duration",
            systemImageName: "slider.horizontal.3"
        )
    }
}
