//
//  AlarmScheduler.swift
//  Focused Timer
//
//  AlarmKit integration: schedules an alarm when the timer starts so the device
//  rings or vibrates even when set to silent mode.
//

import AlarmKit
import Foundation
import os
import SwiftUI

// MARK: - Protocols

protocol AlarmScheduling {
    func scheduleAlarm(remainingTime: TimeInterval, timerType: TimerType)
    func cancelAlarm()
}

protocol AlarmAuthorizationChecking {
    var isDeniedBySystem: Bool { get }
}

// MARK: - Authorization Checker

struct AlarmKitAuthorizationChecker: AlarmAuthorizationChecking {
    var isDeniedBySystem: Bool {
        // In UI testing, `requestAlarmKitPermission()` is skipped and the simulator
        // may have a stale `.denied` state from a previous run. Return `false` so
        // UI tests can exercise the conflict-caption logic independently of the
        // system's AlarmKit authorization.
        guard !ProcessInfo.processInfo.arguments.contains("UI-Testing") else { return false }
        return AlarmManager.shared.authorizationState == .denied
    }
}

// MARK: - Metadata

struct FocusedTimerAlarmMetadata: AlarmMetadata {}

// MARK: - Implementation

final class AlarmKitScheduler: AlarmScheduling {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AlarmKitScheduler.self)
    )

    // MARK: - Public Methods

    func scheduleAlarm(remainingTime: TimeInterval, timerType: TimerType) {
        guard AlarmManager.shared.authorizationState == .authorized else {
            Self.logger.notice("🔔 AlarmKit not authorized — skipping alarm scheduling.")
            return
        }

        cancelAlarm()

        let alarmID = UUID()
        let fireDate = Date.now.addingTimeInterval(remainingTime)
        let alarmTitle = timerType.alarmTitle

        Task { @MainActor [alarmID, fireDate, alarmTitle] in
            do {
                let alertContent = Self.makeAlertContent(title: alarmTitle)
                let presentation = AlarmPresentation(alert: alertContent)
                let attributes = AlarmAttributes(
                    presentation: presentation,
                    metadata: FocusedTimerAlarmMetadata(),
                    tintColor: Color.orange
                )
                let configuration = AlarmManager.AlarmConfiguration<FocusedTimerAlarmMetadata>.alarm(
                    schedule: .fixed(fireDate),
                    attributes: attributes
                )
                _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
                Self.logger.notice("⏰ Alarm scheduled (id: \(alarmID.uuidString)).")
            } catch {
                Self.logger.error("🚨 Failed to schedule alarm: \(error.localizedDescription)")
            }
        }
    }

    func cancelAlarm() {
        guard let alarms = try? AlarmManager.shared.alarms else { return }
        for alarm in alarms {
            if alarm.state == .alerting {
                try? AlarmManager.shared.stop(id: alarm.id)
            } else {
                try? AlarmManager.shared.cancel(id: alarm.id)
            }
        }
    }

    // MARK: - Private Methods

    private static func makeAlertContent(title: LocalizedStringResource) -> AlarmPresentation.Alert {
        if #available(iOS 26.1, *) {
            return AlarmPresentation.Alert(title: title)
        } else {
            return AlarmPresentation.Alert(
                title: title,
                stopButton: AlarmButton(
                    text: LocalizedStringResource("alarmStopButton", table: "Localizable"),
                    textColor: .white,
                    systemImageName: "stop.fill"
                )
            )
        }
    }
}
