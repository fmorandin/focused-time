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

// MARK: - Protocol

protocol AlarmScheduling {
    func scheduleAlarm(remainingTime: TimeInterval)
    func cancelAlarm()
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

    func scheduleAlarm(remainingTime: TimeInterval) {
        guard AlarmManager.shared.authorizationState == .authorized else {
            Self.logger.notice("🔔 AlarmKit not authorized — skipping alarm scheduling.")
            return
        }

        cancelAlarm()

        let alarmID = UUID()
        let fireDate = Date.now.addingTimeInterval(remainingTime)

        Task { @MainActor [alarmID, fireDate] in
            do {
                let title = LocalizedStringResource("alarmTitle", table: "Localizable")
                let alertContent = Self.makeAlertContent(title: title)
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
