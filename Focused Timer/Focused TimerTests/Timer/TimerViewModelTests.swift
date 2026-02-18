//
//  TimerViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 28/09/20.
//

import AudioToolbox
import Testing
@testable import Focused_Timer

@Suite("TimerViewModel Tests", .serialized)
struct TimerViewModelTests {

    fileprivate final class TestRepeatingTimer: RepeatingTimerProtocol {
        private(set) var isInvalidated = false
        private let block: (RepeatingTimerProtocol) -> Void

        init(block: @escaping (RepeatingTimerProtocol) -> Void) {
            self.block = block
        }

        func tick() {
            guard !isInvalidated else { return }
            block(self)
        }

        func invalidate() {
            isInvalidated = true
        }
    }

    fileprivate final class TestRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
        private(set) var createdTimers: [TestRepeatingTimer] = []

        func scheduledTimer(
            withTimeInterval _: TimeInterval,
            repeats _: Bool,
            block: @escaping (RepeatingTimerProtocol) -> Void
        ) -> RepeatingTimerProtocol {
            let timer = TestRepeatingTimer(block: block)
            createdTimers.append(timer)
            return timer
        }

        func advance(by ticks: Int = 1) {
            guard ticks > 0 else { return }

            for _ in 0..<ticks {
                let activeTimers = createdTimers.filter { !$0.isInvalidated }
                activeTimers.forEach { $0.tick() }
            }
        }
    }

    private final class NotificationManagerSpy: LocalNotificationManaging {
        private(set) var clearCalls = 0
        private(set) var scheduledRemainingTimes: [Double] = []

        func clearScheduledNotifications() {
            clearCalls += 1
        }

        func scheduleLocalNotification(remainingTime: Double) {
            scheduledRemainingTimes.append(remainingTime)
        }
    }

    private final class NotificationFlagStoreMock: NotificationFlagStoring {
        var value = false
        private(set) var setCalls: [(Bool, String)] = []

        func bool(forKey _: String) -> Bool {
            value
        }

        func set(_ value: Bool, forKey defaultName: String) {
            self.value = value
            setCalls.append((value, defaultName))
        }
    }

    private final class SoundPlayerMock: SystemSoundPlaying {
        private(set) var playedSoundIDs: [SystemSoundID] = []

        func playSystemSound(_ id: SystemSoundID) {
            playedSoundIDs.append(id)
        }
    }

    private final class TimerModelSpy: TimerModelProtocol {
        var times: [String: Int] = [
            UserDefaultKeys.focusedTime: 5,
            UserDefaultKeys.shortBreakTime: 2,
            UserDefaultKeys.longBreakTime: 3
        ]
        var toggles: [String: Bool] = [
            UserDefaultKeys.autoStartToggle: false,
            UserDefaultKeys.playTimerSounds: false,
            UserDefaultKeys.keepScreenOn: true
        ]
        var numberOfCycles = "2"
        var savedTimes: (Int?, Date?) = (0, Date())
        private(set) var savedRemainingTimesFromBackground: [Int] = []

        func getTime(for keyName: String) -> Int {
            times[keyName] ?? 0
        }

        func saveMoveToBackgroundTime(remainingTime: Int) {
            savedRemainingTimesFromBackground.append(remainingTime)
        }

        func getSavedTimes() -> (Int?, Date?) {
            savedTimes
        }

        func getNumberOfCycles(for _: String) -> String {
            numberOfCycles
        }

        func getToggle(for keyName: String) -> Bool {
            toggles[keyName] ?? false
        }
    }

    private func makeSUT(
        timerModel: TimerModelProtocol = TimerModelMock(),
        nowProvider: @escaping () -> Date = Date.init,
        localNotificationManager: LocalNotificationManaging = NotificationManagerSpy(),
        soundPlayer: SystemSoundPlaying = SoundPlayerMock(),
        notificationFlagStore: NotificationFlagStoring = NotificationFlagStoreMock()
    ) -> (viewModel: TimerViewModel, timerFactory: TestRepeatingTimerFactory) {
        let timerFactory = TestRepeatingTimerFactory()
        let viewModel = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            nowProvider: nowProvider,
            localNotificationManager: localNotificationManager,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlagStore
        )

        return (viewModel, timerFactory)
    }

    @Test("Start timer decrements and transitions to short break")
    func startTimer() {
        let (timerViewModel, timerFactory) = makeSUT()

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerTo == 1.0)
        #expect(timerViewModel.numberOfCompletedCycles == 0)
        #expect(timerViewModel.totalNumberOfCycles == 2)

        timerViewModel.startTimer()
        timerFactory.advance()

        #expect(timerViewModel.timerState == .running)
        #expect(timerViewModel.counter == 4)

        // 5 ticks to reach zero + 1 tick to trigger mode change.
        timerFactory.advance(by: 5)

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 2)
        #expect(timerViewModel.timerTo == 1.0)
        #expect(timerViewModel.numberOfCompletedCycles == 1)
    }

    @Test("Pause timer invalidates the active timer")
    func pauseTimer() {
        let (timerViewModel, timerFactory) = makeSUT()

        #expect(timerViewModel.timerState == .initial)

        timerViewModel.startTimer()
        timerFactory.advance()
        timerViewModel.pauseTimer()

        #expect(timerViewModel.timerState == .paused)
        let pausedCounter = timerViewModel.counter

        // The timer was invalidated, so extra ticks should not change the counter.
        timerFactory.advance(by: 3)
        #expect(timerViewModel.counter == pausedCounter)
    }

    @Test("Reset timer restores initial focused state")
    func resetTimer() {
        let (timerViewModel, timerFactory) = makeSUT()

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)

        timerViewModel.startTimer()
        timerFactory.advance(by: 2)

        #expect(timerViewModel.timerState == .running)
        #expect(timerViewModel.counter == 3)

        timerViewModel.resetUpdateTimer()

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerTo == 1.0)
        #expect(timerViewModel.numberOfCompletedCycles == 0)
        #expect(timerViewModel.timerType == .focused)
    }

    @Test("Focus and short break timers transition correctly")
    func focusAndShortBreakTimes() {
        let (timerViewModel, timerFactory) = makeSUT()

        #expect(timerViewModel.timerType == .focused)

        // Focused cycle end -> short break.
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 2)
        #expect(timerViewModel.timerType == .shortBreak)
        #expect(timerViewModel.numberOfCompletedCycles == 1)

        // Short break end -> focused.
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerType == .focused)
        #expect(timerViewModel.numberOfCompletedCycles == 1)
    }

    // swiftlint:disable function_body_length
    @Test("Full flow reaches long break and resets cycles")
    func completeFlowIncludingLongBreak() {
        let (timerViewModel, timerFactory) = makeSUT()

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerTo == 1.0)
        #expect(timerViewModel.numberOfCompletedCycles == 0)
        #expect(timerViewModel.totalNumberOfCycles == 2)
        #expect(timerViewModel.timerType == .focused)

        // 1st focused -> short break.
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        #expect(timerViewModel.timerType == .shortBreak)
        #expect(timerViewModel.counter == 2)
        #expect(timerViewModel.numberOfCompletedCycles == 1)

        // 1st short break -> focused.
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)
        #expect(timerViewModel.timerType == .focused)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.numberOfCompletedCycles == 1)

        // 2nd focused -> long break.
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        #expect(timerViewModel.timerType == .longBreak)
        #expect(timerViewModel.counter == 3)
        #expect(timerViewModel.numberOfCompletedCycles == 2)

        // Long break -> focused and cycles reset.
        timerViewModel.startTimer()
        timerFactory.advance(by: 4)
        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerTo == 1.0)
        #expect(timerViewModel.numberOfCompletedCycles == 0)
        #expect(timerViewModel.timerType == .focused)
    }
    // swiftlint:enable function_body_length

    @Test("moveAppToForeground uses injected now provider")
    func moveAppToForegroundUsesInjectedNowProvider() {
        let savedDate = Date(timeIntervalSince1970: 10)
        let nowDate = Date(timeIntervalSince1970: 14)

        struct TimeAwareTimerModelMock: TimerModelProtocol {
            let savedRemainingTime: Int
            let savedTimestamp: Date

            func getTime(for key: String) -> Int {
                TimerModelMock().getTime(for: key)
            }

            func saveMoveToBackgroundTime(remainingTime _: Int) {}

            func getSavedTimes() -> (Int?, Date?) {
                (savedRemainingTime, savedTimestamp)
            }

            func getNumberOfCycles(for keyName: String) -> String {
                TimerModelMock().getNumberOfCycles(for: keyName)
            }

            func getToggle(for keyName: String) -> Bool {
                TimerModelMock().getToggle(for: keyName)
            }
        }

        let timerFactory = TestRepeatingTimerFactory()
        let viewModel = TimerViewModel(
            timerModel: TimeAwareTimerModelMock(savedRemainingTime: 20, savedTimestamp: savedDate),
            timerFactory: timerFactory,
            nowProvider: { nowDate }
        )

        viewModel.startTimer()
        timerFactory.advance() // Sets state to running.
        viewModel.moveAppToForeground()

        #expect(viewModel.counter == 16)
    }

    @Test("Calling startTimer twice keeps a single active timer")
    func startTimerTwiceUsesSingleActiveTimer() {
        let (timerViewModel, timerFactory) = makeSUT()

        timerViewModel.startTimer()
        timerViewModel.startTimer()

        timerFactory.advance()

        #expect(timerViewModel.counter == 4)
    }

    @Test("moveAppToBackground when running saves remaining time and schedules notification")
    func moveAppToBackgroundWhenRunningSavesAndSchedulesNotification() {
        let timerModel = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (viewModel, timerFactory) = makeSUT(
            timerModel: timerModel,
            localNotificationManager: notificationManager
        )

        viewModel.startTimer()
        timerFactory.advance()
        viewModel.moveAppToBackground()

        #expect(timerModel.savedRemainingTimesFromBackground == [4])
        #expect(notificationManager.scheduledRemainingTimes == [4.0])
    }

    @Test("moveAppToBackground when not running does nothing")
    func moveAppToBackgroundWhenNotRunningDoesNothing() {
        let timerModel = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (viewModel, _) = makeSUT(
            timerModel: timerModel,
            localNotificationManager: notificationManager
        )

        viewModel.moveAppToBackground()

        #expect(timerModel.savedRemainingTimesFromBackground.isEmpty)
        #expect(notificationManager.scheduledRemainingTimes.isEmpty)
    }

    @Test("moveAppToForeground always clears notifications")
    func moveAppToForegroundAlwaysClearsNotifications() {
        let notificationManager = NotificationManagerSpy()
        let (viewModel, _) = makeSUT(
            timerModel: TimerModelSpy(),
            localNotificationManager: notificationManager
        )

        viewModel.moveAppToForeground()

        #expect(notificationManager.clearCalls == 1)
    }

    @Test("moveAppToForeground with missing saved times keeps current counter")
    func moveAppToForegroundWhenSavedTimesMissingDoesNotChangeCounter() {
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (nil, nil)
        let (viewModel, timerFactory) = makeSUT(timerModel: timerModel)

        viewModel.startTimer()
        timerFactory.advance()
        let counterBeforeForeground = viewModel.counter

        viewModel.moveAppToForeground()

        #expect(viewModel.counter == counterBeforeForeground)
    }

    @Test("moveAppToForeground clamps counter to zero when background time exceeds remaining")
    func moveAppToForegroundWhenBackgroundTimeExceedsRemainingClampsCounterToZero() {
        let nowDate = Date(timeIntervalSince1970: 20)
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (2, Date(timeIntervalSince1970: 10))
        let (viewModel, timerFactory) = makeSUT(
            timerModel: timerModel,
            nowProvider: { nowDate }
        )

        viewModel.startTimer()
        timerFactory.advance()
        viewModel.moveAppToForeground()

        #expect(viewModel.counter == 0)
    }

    @Test("moveAppToForeground does not apply saved times when timer is not running")
    func moveAppToForegroundWhenTimerNotRunningDoesNotApplySavedTimes() {
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (1, Date(timeIntervalSince1970: 0))
        let (viewModel, _) = makeSUT(
            timerModel: timerModel,
            nowProvider: { Date(timeIntervalSince1970: 100) }
        )

        let initialCounter = viewModel.counter
        viewModel.moveAppToForeground()

        #expect(viewModel.counter == initialCounter)
    }

    @Test("Timer completion from notification skips sound and resets notification flag")
    func timerFinishesFromNotificationDoesNotPlaySoundAndResetsFlag() throws {
        let timerModel = TimerModelSpy()
        timerModel.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerMock()
        let notificationFlags = NotificationFlagStoreMock()
        notificationFlags.value = true
        let (viewModel, timerFactory) = makeSUT(
            timerModel: timerModel,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlags
        )

        viewModel.counter = 0
        viewModel.startTimer()
        timerFactory.advance()

        #expect(soundPlayer.playedSoundIDs.isEmpty)
        #expect(notificationFlags.setCalls.count == 1)
        let call = try #require(notificationFlags.setCalls.first)
        #expect(call.0 == false)
        #expect(call.1 == UserDefaultKeys.isNotification)
    }

    @Test("Timer completion plays sound when enabled and not triggered from notification")
    func timerFinishesWithPlaySoundEnabledPlaysSound() {
        let timerModel = TimerModelSpy()
        timerModel.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerMock()
        let notificationFlags = NotificationFlagStoreMock()
        notificationFlags.value = false
        let (viewModel, timerFactory) = makeSUT(
            timerModel: timerModel,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlags
        )

        viewModel.counter = 0
        viewModel.startTimer()
        timerFactory.advance()

        #expect(soundPlayer.playedSoundIDs.count == 1)
    }
}
