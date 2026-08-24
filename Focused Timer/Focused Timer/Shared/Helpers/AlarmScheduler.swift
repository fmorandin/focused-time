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

@MainActor
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

@MainActor
protocol AlarmIdentifierStoring: AnyObject {
    var alarmIdentifier: UUID? { get set }
}

@MainActor
final class UserDefaultsAlarmIdentifierStore: AlarmIdentifierStoring {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var alarmIdentifier: UUID? {
        get {
            guard let value = defaults.string(forKey: UserDefaultKeys.alarmIdentifier) else { return nil }
            return UUID(uuidString: value)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: UserDefaultKeys.alarmIdentifier)
        }
    }
}

// MARK: - Implementation

@MainActor
final class AlarmKitScheduler: AlarmScheduling {

    typealias ScheduleOperation = @MainActor (UUID, Date, LocalizedStringResource) async throws -> Void
    typealias CancelOperation = @MainActor (UUID) -> Void

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AlarmKitScheduler.self)
    )

    private let authorizationProvider: () -> Bool
    private let identifierStore: any AlarmIdentifierStoring
    private let uuidProvider: () -> UUID
    private let scheduleOperation: ScheduleOperation
    private let cancelOperation: CancelOperation
    private var scheduleTask: Task<Void, Never>?
    private var scheduleGeneration = 0

    // MARK: - Initializer

    init(
        authorizationProvider: @escaping () -> Bool = {
            AlarmManager.shared.authorizationState == .authorized
        },
        identifierStore: any AlarmIdentifierStoring = UserDefaultsAlarmIdentifierStore(),
        uuidProvider: @escaping () -> UUID = UUID.init,
        scheduleOperation: @escaping ScheduleOperation = AlarmKitScheduler.scheduleWithAlarmKit,
        cancelOperation: @escaping CancelOperation = AlarmKitScheduler.cancelWithAlarmKit
    ) {
        self.authorizationProvider = authorizationProvider
        self.identifierStore = identifierStore
        self.uuidProvider = uuidProvider
        self.scheduleOperation = scheduleOperation
        self.cancelOperation = cancelOperation

        if let persistedIdentifier = identifierStore.alarmIdentifier {
            cancelOperation(persistedIdentifier)
            identifierStore.alarmIdentifier = nil
        }
    }

    // MARK: - Public Methods

    func scheduleAlarm(remainingTime: TimeInterval, timerType: TimerType) {
        guard authorizationProvider() else {
            Self.logger.notice("🔔 AlarmKit not authorized — skipping alarm scheduling.")
            return
        }

        cancelAlarm()

        scheduleGeneration += 1
        let generation = scheduleGeneration
        let alarmID = uuidProvider()
        let fireDate = Date.now.addingTimeInterval(remainingTime)
        let alarmTitle = timerType.alarmTitle
        identifierStore.alarmIdentifier = alarmID

        scheduleTask = Task { @MainActor [weak self, alarmID, fireDate, alarmTitle, generation] in
            guard let self else { return }
            do {
                try await scheduleOperation(alarmID, fireDate, alarmTitle)
            } catch {
                guard scheduleGeneration == generation else { return }
                if identifierStore.alarmIdentifier == alarmID {
                    identifierStore.alarmIdentifier = nil
                }
                Self.logger.error("🚨 Failed to schedule alarm: \(error.localizedDescription)")
                return
            }

            guard scheduleGeneration == generation, !Task.isCancelled else {
                cancelOperation(alarmID)
                return
            }

            Self.logger.notice("⏰ Alarm scheduled (id: \(alarmID.uuidString)).")
        }
    }

    func cancelAlarm() {
        scheduleGeneration += 1
        scheduleTask?.cancel()
        scheduleTask = nil

        guard let alarmIdentifier = identifierStore.alarmIdentifier else { return }
        identifierStore.alarmIdentifier = nil
        cancelOperation(alarmIdentifier)
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

    private static func scheduleWithAlarmKit(
        alarmID: UUID,
        fireDate: Date,
        alarmTitle: LocalizedStringResource
    ) async throws {
        let alertContent = makeAlertContent(title: alarmTitle)
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
    }

    private static func cancelWithAlarmKit(alarmID: UUID) {
        guard let alarms = try? AlarmManager.shared.alarms,
              let alarm = alarms.first(where: { $0.id == alarmID }) else {
            try? AlarmManager.shared.cancel(id: alarmID)
            return
        }

        if alarm.state == .alerting {
            try? AlarmManager.shared.stop(id: alarmID)
        } else {
            try? AlarmManager.shared.cancel(id: alarmID)
        }
    }
}
