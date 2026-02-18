//
//  TimerViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 28/09/20.
//

import XCTest
import AudioToolbox
@testable import Focused_Timer

final class TimerViewModelTests: XCTestCase {

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

    private var timerFactory: TestRepeatingTimerFactory!
    private var timerViewModel: TimerViewModel!

    override func setUp() {
        super.setUp()
        timerFactory = TestRepeatingTimerFactory()
        timerViewModel = TimerViewModel(timerModel: TimerModelMock(), timerFactory: timerFactory)
    }

    override func tearDown() {
        timerViewModel = nil
        timerFactory = nil
        super.tearDown()
    }

    func test_StartTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, 2)

        timerViewModel.startTimer()
        timerFactory.advance()

        XCTAssertEqual(timerViewModel.timerState, .running)
        XCTAssertEqual(timerViewModel.counter, 4)

        // 5 ticks to reach zero + 1 tick to trigger mode change
        timerFactory.advance(by: 5)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)
    }

    func test_PauseTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)

        timerViewModel.startTimer()
        timerFactory.advance()
        timerViewModel.pauseTimer()

        XCTAssertEqual(timerViewModel.timerState, .paused)
        let pausedCounter = timerViewModel.counter

        // The timer was invalidated, so extra ticks should not change the counter.
        timerFactory.advance(by: 3)
        XCTAssertEqual(timerViewModel.counter, pausedCounter)
    }

    func test_ResetTimer() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)

        timerViewModel.startTimer()
        timerFactory.advance(by: 2)

        XCTAssertEqual(timerViewModel.timerState, .running)
        XCTAssertEqual(timerViewModel.counter, 3)

        timerViewModel.resetUpdateTimer()

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.timerType, .focused)
    }

    func test_FocusAndShortBreakTimes() {
        XCTAssertEqual(timerViewModel.timerType, .focused)

        // Focused cycle end -> short break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.timerType, .shortBreak)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // Short break end -> focused
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)

        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerType, .focused)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)
    }

    // swiftlint:disable function_body_length
    func test_CompleteFlowIncludingLongBreak() {
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.totalNumberOfCycles, 2)
        XCTAssertEqual(timerViewModel.timerType, .focused)

        // 1st focused -> short break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        XCTAssertEqual(timerViewModel.timerType, .shortBreak)
        XCTAssertEqual(timerViewModel.counter, 2)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // 1st short break -> focused
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)
        XCTAssertEqual(timerViewModel.timerType, .focused)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 1)

        // 2nd focused -> long break
        timerViewModel.startTimer()
        timerFactory.advance(by: 6)
        XCTAssertEqual(timerViewModel.timerType, .longBreak)
        XCTAssertEqual(timerViewModel.counter, 3)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 2)

        // Long break -> focused and cycles reset
        timerViewModel.startTimer()
        timerFactory.advance(by: 4)
        XCTAssertEqual(timerViewModel.timerState, .initial)
        XCTAssertEqual(timerViewModel.counter, 5)
        XCTAssertEqual(timerViewModel.timerTo, 1.0)
        XCTAssertEqual(timerViewModel.numberOfCompletedCycles, 0)
        XCTAssertEqual(timerViewModel.timerType, .focused)
    }
    // swiftlint:enable function_body_length

    func test_MoveAppToForeground_UsesInjectedNowProvider() {
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

        let deterministicVM = TimerViewModel(
            timerModel: TimeAwareTimerModelMock(savedRemainingTime: 20, savedTimestamp: savedDate),
            timerFactory: timerFactory,
            nowProvider: { nowDate }
        )

        deterministicVM.startTimer()
        timerFactory.advance() // set state to running

        deterministicVM.moveAppToForeground()

        XCTAssertEqual(deterministicVM.counter, 16)
    }

    func test_StartTimerTwice_UsesSingleActiveTimer() {
        timerViewModel.startTimer()
        timerViewModel.startTimer()

        timerFactory.advance()

        XCTAssertEqual(timerViewModel.counter, 4)
    }

    func test_MoveAppToBackground_WhenRunning_SavesAndSchedulesNotification() {
        let timerModel = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let vm = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            localNotificationManager: notificationManager
        )

        vm.startTimer()
        timerFactory.advance()
        vm.moveAppToBackground()

        XCTAssertEqual(timerModel.savedRemainingTimesFromBackground, [4])
        XCTAssertEqual(notificationManager.scheduledRemainingTimes, [4.0])
    }

    func test_MoveAppToBackground_WhenNotRunning_DoesNothing() {
        let timerModel = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let vm = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            localNotificationManager: notificationManager
        )

        vm.moveAppToBackground()

        XCTAssertTrue(timerModel.savedRemainingTimesFromBackground.isEmpty)
        XCTAssertTrue(notificationManager.scheduledRemainingTimes.isEmpty)
    }

    func test_MoveAppToForeground_AlwaysClearsNotifications() {
        let notificationManager = NotificationManagerSpy()
        let vm = TimerViewModel(
            timerModel: TimerModelSpy(),
            timerFactory: timerFactory,
            localNotificationManager: notificationManager
        )

        vm.moveAppToForeground()

        XCTAssertEqual(notificationManager.clearCalls, 1)
    }

    func test_MoveAppToForeground_WhenSavedTimesMissing_DoesNotChangeCounter() {
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (nil, nil)
        let vm = TimerViewModel(timerModel: timerModel, timerFactory: timerFactory)

        vm.startTimer()
        timerFactory.advance()
        let counterBeforeForeground = vm.counter

        vm.moveAppToForeground()

        XCTAssertEqual(vm.counter, counterBeforeForeground)
    }

    func test_MoveAppToForeground_WhenBackgroundTimeExceedsRemaining_ClampsCounterToZero() {
        let nowDate = Date(timeIntervalSince1970: 20)
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (2, Date(timeIntervalSince1970: 10))
        let vm = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            nowProvider: { nowDate }
        )

        vm.startTimer()
        timerFactory.advance()
        vm.moveAppToForeground()

        XCTAssertEqual(vm.counter, 0)
    }

    func test_MoveAppToForeground_WhenTimerNotRunning_DoesNotApplySavedTimes() {
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (1, Date(timeIntervalSince1970: 0))
        let vm = TimerViewModel(timerModel: timerModel, timerFactory: timerFactory, nowProvider: { Date(timeIntervalSince1970: 100) })

        let initialCounter = vm.counter
        vm.moveAppToForeground()

        XCTAssertEqual(vm.counter, initialCounter)
    }

    func test_TimerFinishesFromNotification_DoesNotPlaySoundAndResetsFlag() {
        let timerModel = TimerModelSpy()
        timerModel.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerMock()
        let notificationFlags = NotificationFlagStoreMock()
        notificationFlags.value = true
        let vm = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlags
        )

        vm.counter = 0
        vm.startTimer()
        timerFactory.advance()

        XCTAssertTrue(soundPlayer.playedSoundIDs.isEmpty)
        XCTAssertEqual(notificationFlags.setCalls.count, 1)
        XCTAssertEqual(notificationFlags.setCalls.first?.0, false)
        XCTAssertEqual(notificationFlags.setCalls.first?.1, UserDefaultKeys.isNotification)
    }

    func test_TimerFinishesWithPlaySoundEnabled_PlaysSound() {
        let timerModel = TimerModelSpy()
        timerModel.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerMock()
        let notificationFlags = NotificationFlagStoreMock()
        notificationFlags.value = false
        let vm = TimerViewModel(
            timerModel: timerModel,
            timerFactory: timerFactory,
            soundPlayer: soundPlayer,
            notificationFlagStore: notificationFlags
        )

        vm.counter = 0
        vm.startTimer()
        timerFactory.advance()

        XCTAssertEqual(soundPlayer.playedSoundIDs.count, 1)
    }
}
