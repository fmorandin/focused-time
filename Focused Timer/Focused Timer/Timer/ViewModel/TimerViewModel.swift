//
//  TimerViewModel.swift
//  Focused Timer
//
//  Thin SwiftUI adapter over TimerUseCase.
//  Owns @Published state for observation, formats raw values for display,
//  and delegates all business logic to the use case.
//

import AVFoundation
import SwiftUI
import os

// MARK: - Timer infrastructure protocols (kept here for proximity to their use)

protocol RepeatingTimerProtocol: AnyObject {
    func invalidate()
}

protocol SystemSoundPlaying {
    func playSystemSound(_ id: SystemSoundID)
}

struct AudioSystemSoundPlayer: SystemSoundPlaying {
    func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}

protocol NotificationFlagStoring {
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: NotificationFlagStoring {}

protocol RepeatingTimerFactoryProtocol {
    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping (RepeatingTimerProtocol) -> Void
    ) -> RepeatingTimerProtocol
}

private final class FoundationRepeatingTimer: RepeatingTimerProtocol {
    private var timer: Timer?

    init(timer: Timer) {
        self.timer = timer
    }

    func invalidate() {
        timer?.invalidate()
    }
}

struct FoundationRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
    private final class FoundationTimerTarget: NSObject {
        var timer: FoundationRepeatingTimer?
        let block: (RepeatingTimerProtocol) -> Void

        init(block: @escaping (RepeatingTimerProtocol) -> Void) {
            self.block = block
        }

        @objc func fire() {
            guard let timer else { return }
            block(timer)
        }
    }

    func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping (RepeatingTimerProtocol) -> Void
    ) -> RepeatingTimerProtocol {
        let target = FoundationTimerTarget(block: block)
        let selectorTimer = Timer.scheduledTimer(
            timeInterval: interval,
            target: target,
            selector: #selector(FoundationTimerTarget.fire),
            userInfo: nil,
            repeats: repeats
        )

        let createdTimer = FoundationRepeatingTimer(timer: selectorTimer)
        target.timer = createdTimer
        return createdTimer
    }
}

// MARK: - ViewModel

final class TimerViewModel: ObservableObject {

    // MARK: - Published Variables (view-facing state)

    @Published var totalTime: Int
    @Published var timerState: TimerState = .initial
    @Published var timerTo: CGFloat = 1
    @Published var counter: Int
    @Published var countTime: String
    @Published var timerType: TimerType = .focused
    @Published var totalNumberOfCycles: Int
    @Published var numberOfCompletedCycles: Int
    @Published var accentCircleColor: Color

    // MARK: - Computed Display Properties

    var primaryButtonImageName: String {
        switch timerState {
        case .running:
            return ImageNames.pause
        case .paused, .initial:
            return ImageNames.play
        }
    }

    var primaryButtonText: LocalizedStringResource {
        switch timerState {
        case .running:
            return LocalizedStringResource("pauseTimer", table: "Localizable")
        case .paused:
            return LocalizedStringResource("resumeTimer", table: "Localizable")
        case .initial:
            return LocalizedStringResource("playTimer", table: "Localizable")
        }
    }

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerViewModel.self)
    )

    private let useCase: TimerUseCase
    private let dateFormatter = DateComponentsFormatter()

    // MARK: - Initializer

    init(
        timerModel: TimerModelProtocol,
        timerFactory: RepeatingTimerFactoryProtocol = FoundationRepeatingTimerFactory(),
        nowProvider: @escaping () -> Date = Date.init,
        localNotificationManager: LocalNotificationManaging = LocalNotificationManager(),
        soundPlayer: SystemSoundPlaying = AudioSystemSoundPlayer(),
        notificationFlagStore: NotificationFlagStoring = UserDefaults.standard
    ) {
        Self.logger.notice("🛠 Initializing Timer View Model.")

        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.unitsStyle = .positional

        useCase = TimerUseCase(
            timerModel: timerModel,
            timerFactory: timerFactory,
            nowProvider: nowProvider,
            localNotificationManager: localNotificationManager,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlagStore
        )

        totalTime = useCase.totalTime
        counter = useCase.counter
        countTime = dateFormatter.string(from: TimeInterval(useCase.counter)) ?? "-"
        totalNumberOfCycles = useCase.totalNumberOfCycles
        numberOfCompletedCycles = useCase.numberOfCompletedCycles
        accentCircleColor = TimerTheme.color(for: useCase.timerType)

        useCase.onStateChange = { [weak self] in
            self?.syncFromUseCase()
        }
    }

    // MARK: - Public Methods (delegates to use case)

    func startTimer() {
        Self.logger.notice("▶️ Starting timer (ViewModel delegate).")
        // Sync any direct counter assignment (used in tests) back to the use case
        // before kicking off the tick loop.
        useCase.counter = counter
        useCase.startTimer()
    }

    func pauseTimer() {
        Self.logger.notice("⏸ Pausing timer (ViewModel delegate).")
        useCase.pauseTimer()
    }

    func resetUpdateTimer() {
        Self.logger.notice("🔄 Resetting timer (ViewModel delegate).")
        useCase.resetUpdateTimer()
    }

    func moveAppToBackground() {
        useCase.moveAppToBackground()
    }

    func moveAppToForeground() {
        useCase.moveAppToForeground()
    }

    func shouldDisplaySettingsAlert() -> Bool {
        timerState == .running || timerState == .paused
    }

    func shouldKeepScreenOn() -> Bool {
        useCase.isKeepScreenOnEnabled
    }

    // MARK: - Private

    private func syncFromUseCase() {
        counter = useCase.counter
        totalTime = useCase.totalTime
        timerState = useCase.timerState
        timerType = useCase.timerType
        timerTo = useCase.timerTo
        numberOfCompletedCycles = useCase.numberOfCompletedCycles
        totalNumberOfCycles = useCase.totalNumberOfCycles
        countTime = dateFormatter.string(from: TimeInterval(useCase.counter)) ?? "-"
        accentCircleColor = TimerTheme.color(for: useCase.timerType)
    }
}
