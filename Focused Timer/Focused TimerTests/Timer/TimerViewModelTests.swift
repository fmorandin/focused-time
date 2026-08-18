//
//  TimerViewModelTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 28/09/20.
//

// swiftlint:disable file_length
import AudioToolbox
import Testing
@testable import Focused_Timer

private final class TestRepeatingTimer: RepeatingTimerProtocol {
    private(set) var isInvalidated = false
    private let block: (any RepeatingTimerProtocol) -> Void

    init(block: @escaping (any RepeatingTimerProtocol) -> Void) {
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

private final class TestRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
    private(set) var createdTimers: [TestRepeatingTimer] = []

    func scheduledTimer(
        withTimeInterval _: TimeInterval,
        repeats _: Bool,
        block: @escaping (any RepeatingTimerProtocol) -> Void
    ) -> any RepeatingTimerProtocol {
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

    func scheduleLocalNotification(remainingTime: Double, timerType: TimerType) {
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

private final class LiveActivityManagerMock: LiveActivityManaging, @unchecked Sendable {
    private(set) var events: [LiveActivityEvent] = []
    func handle(_ event: LiveActivityEvent) { events.append(event) }
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
        UserDefaultKeys.keepScreenOn: true,
        UserDefaultKeys.enableNotifications: true
    ]
    var numberOfCycles = "2"
    var savedTimes: (Int?, Date?) = (nil, nil)
    var savedBackgroundState: BackgroundTimerState?
    private(set) var savedRemainingTimesFromBackground: [Int] = []

    func getTime(for keyName: String) -> Int {
        times[keyName] ?? 0
    }

    func saveMoveToBackgroundTime(
        remainingTime: Int,
        timerType: TimerType,
        numberOfCompletedCycles: Int,
        previousPhaseWasFocus: Bool
    ) {
        savedRemainingTimesFromBackground.append(remainingTime)
    }

    func getSavedTimes() -> (Int?, Date?) {
        savedTimes
    }

    func getSavedBackgroundTimerState() -> BackgroundTimerState? { savedBackgroundState }

    func clearSavedBackgroundState() {}

    func getNumberOfCycles(for _: String) -> String {
        numberOfCycles
    }

    func getToggle(for keyName: String) -> Bool {
        toggles[keyName] ?? false
    }

    func getStartingTimerType() -> TimerType {
        .focused
    }
}

private func makeSUT(
    timerModel: any TimerModelProtocol = TimerModelMock(),
    nowProvider: @escaping () -> Date = Date.init,
    localNotificationManager: any LocalNotificationManaging = NotificationManagerSpy(),
    soundPlayer: any SystemSoundPlaying = SoundPlayerMock(),
    notificationFlagStore: any NotificationFlagStoring = NotificationFlagStoreMock(),
    liveActivityManager: any LiveActivityManaging = LiveActivityManagerMock(),
    isReviewEnabled: Bool = false
) -> (viewModel: TimerViewModel, timerFactory: TestRepeatingTimerFactory) {
    let timerFactory = TestRepeatingTimerFactory()
    let viewModel = TimerViewModel(
        timerModel: timerModel,
        timerFactory: timerFactory,
        nowProvider: nowProvider,
        localNotificationManager: localNotificationManager,
        soundPlayer: soundPlayer,
        notificationFlagStore: notificationFlagStore,
        liveActivityManager: liveActivityManager,
        isReviewEnabled: isReviewEnabled
    )

    return (viewModel, timerFactory)
}

@Suite("TimerViewModel Tests", .serialized)
// swiftlint:disable:next type_body_length
struct TimerViewModelTests {
    @Test("Timer transitions emit semantic Live Activity events without per-second updates")
    func liveActivityIntegration() {
        let manager = LiveActivityManagerMock()
        let (viewModel, timerFactory) = makeSUT(liveActivityManager: manager)
        #expect(manager.events == [.reconcile(nil)])

        viewModel.startTimer()
        #expect(manager.events.last?.snapshotStatus == .running)

        timerFactory.advance()
        #expect(manager.events.count == 2)

        viewModel.pauseTimer()
        #expect(manager.events.last?.snapshotStatus == .paused)

        viewModel.resetUpdateTimer()
        #expect(manager.events.last == .reset)
    }

    @Test("Timer completion without auto-start emits a completed Live Activity event")
    func liveActivityCompletionWithoutAutoStart() {
        let completionDate = Date(timeIntervalSince1970: 1_800_000_000)
        let manager = LiveActivityManagerMock()
        let (viewModel, timerFactory) = makeSUT(
            nowProvider: { completionDate },
            liveActivityManager: manager
        )

        viewModel.startTimer()
        timerFactory.advance(by: 6)

        #expect(
            manager.events.last
                == .phaseCompleted(completionDate: completionDate, nextSnapshot: nil)
        )
    }

    @Test("Foreground recovery emits completion when a timer expired in the background")
    func liveActivityCompletionAfterBackgroundExpiration() {
        let completionDate = Date(timeIntervalSince1970: 20)
        let timerModel = TimerModelSpy()
        timerModel.savedTimes = (2, Date(timeIntervalSince1970: 10))
        let manager = LiveActivityManagerMock()
        let (viewModel, timerFactory) = makeSUT(
            timerModel: timerModel,
            nowProvider: { completionDate },
            liveActivityManager: manager
        )

        viewModel.startTimer()
        timerFactory.advance()
        viewModel.moveAppToForeground()

        #expect(viewModel.timerState == .initial)
        #expect(
            manager.events.last
                == .phaseCompleted(completionDate: completionDate, nextSnapshot: nil)
        )
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
        // Cycle not yet complete — short break still needs to finish.
        #expect(timerViewModel.numberOfCompletedCycles == 0)
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
        // Cycle not yet complete — short break still needs to finish.
        #expect(timerViewModel.numberOfCompletedCycles == 0)

        // Short break end -> focused.
        timerViewModel.startTimer()
        timerFactory.advance(by: 3)

        #expect(timerViewModel.timerState == .initial)
        #expect(timerViewModel.counter == 5)
        #expect(timerViewModel.timerType == .focused)
        #expect(timerViewModel.numberOfCompletedCycles == 1)
    }

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
        // Cycle not yet complete — short break still needs to finish.
        #expect(timerViewModel.numberOfCompletedCycles == 0)

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

    @Test("moveAppToForeground uses injected now provider")
    func moveAppToForegroundUsesInjectedNowProvider() {
        let savedDate = Date(timeIntervalSince1970: 10)
        let nowDate = Date(timeIntervalSince1970: 14)

        struct TimeAwareTimerModelMock: TimerModelProtocol {
            let savedRemainingTime: Int
            let savedTimestamp: Date

            func getTime(for keyName: String) -> Int {
                TimerModelMock().getTime(for: keyName)
            }

            func saveMoveToBackgroundTime(
                remainingTime _: Int,
                timerType _: TimerType,
                numberOfCompletedCycles _: Int,
                previousPhaseWasFocus _: Bool
            ) {}

            func getSavedTimes() -> (Int?, Date?) {
                (savedRemainingTime, savedTimestamp)
            }

            func getSavedBackgroundTimerState() -> BackgroundTimerState? { nil }

            func clearSavedBackgroundState() {}

            func getNumberOfCycles(for keyName: String) -> String {
                TimerModelMock().getNumberOfCycles(for: keyName)
            }

            func getToggle(for keyName: String) -> Bool {
                TimerModelMock().getToggle(for: keyName)
            }

            func getStartingTimerType() -> TimerType {
                .focused
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

    @Test("moveAppToForeground transitions immediately when background time exceeds remaining")
    func moveAppToForegroundWhenBackgroundTimeExceedsRemainingTransitionsImmediately() {
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

        #expect(viewModel.timerType == .shortBreak)
        #expect(viewModel.counter == 2)   // shortBreakTime from TimerModelSpy
        #expect(viewModel.timerState == .initial)
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

    // MARK: - Computed Display Properties

    @Test("primaryButtonImageName returns play icon in initial state")
    func primaryButtonImageNameInInitialState() {
        let (viewModel, _) = makeSUT()

        #expect(viewModel.primaryButtonImageName == ImageNames.play)
    }

    @Test("primaryButtonImageName returns pause icon while running")
    func primaryButtonImageNameWhileRunning() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance()

        #expect(viewModel.primaryButtonImageName == ImageNames.pause)
    }

    @Test("primaryButtonImageName returns play icon while paused")
    func primaryButtonImageNameWhilePaused() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance()
        viewModel.pauseTimer()

        #expect(viewModel.primaryButtonImageName == ImageNames.play)
    }

    @Test("primaryButtonText localization key is playTimer in initial state")
    func primaryButtonTextKeyInInitialState() {
        let (viewModel, _) = makeSUT()

        #expect(viewModel.primaryButtonText.key == "playTimer")
    }

    @Test("primaryButtonText localization key is pauseTimer while running")
    func primaryButtonTextKeyWhileRunning() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance()

        #expect(viewModel.primaryButtonText.key == "pauseTimer")
    }

    @Test("primaryButtonText localization key is resumeTimer while paused")
    func primaryButtonTextKeyWhilePaused() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance()
        viewModel.pauseTimer()

        #expect(viewModel.primaryButtonText.key == "resumeTimer")
    }

    @Test("countTime formats counter as zero-padded MM:SS string")
    func countTimeFormatsCounterAsMinutesAndSeconds() {
        let (viewModel, timerFactory) = makeSUT()

        // TimerModelMock returns focusedTime = 5 seconds
        #expect(viewModel.countTime == "00:05")

        viewModel.startTimer()
        timerFactory.advance()

        // After one tick the counter decrements to 4
        #expect(viewModel.countTime == "00:04")
    }

    // MARK: - Observable Properties

    @Test("accentCircleColor matches focused theme initially")
    func accentCircleColorInitialState() {
        let (viewModel, _) = makeSUT()

        #expect(viewModel.accentCircleColor == TimerTheme.color(for: .focused))
    }

    @Test("accentCircleColor updates to shortBreak color after focused timer ends")
    func accentCircleColorUpdatesAfterFocusedTimerEnds() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance(by: 6) // 5 ticks to complete focused + 1 to transition

        #expect(viewModel.timerType == .shortBreak)
        #expect(viewModel.accentCircleColor == TimerTheme.color(for: .shortBreak))
    }

    @Test("accentCircleColor updates to longBreak color after second focused timer ends")
    func accentCircleColorUpdatesAfterLongBreakTransition() {
        let (viewModel, timerFactory) = makeSUT()

        // First focused cycle → short break
        viewModel.startTimer()
        timerFactory.advance(by: 6)
        #expect(viewModel.timerType == .shortBreak)

        // Short break → second focused cycle
        viewModel.startTimer()
        timerFactory.advance(by: 3)
        #expect(viewModel.timerType == .focused)

        // Second focused cycle → long break
        viewModel.startTimer()
        timerFactory.advance(by: 6)

        #expect(viewModel.timerType == .longBreak)
        #expect(viewModel.accentCircleColor == TimerTheme.color(for: .longBreak))
    }

    @Test("accentCircleColor resets to focused color after timer reset")
    func accentCircleColorResetsAfterTimerReset() {
        let (viewModel, timerFactory) = makeSUT()

        viewModel.startTimer()
        timerFactory.advance(by: 6)
        #expect(viewModel.timerType == .shortBreak)

        viewModel.resetUpdateTimer()

        #expect(viewModel.timerType == .focused)
        #expect(viewModel.accentCircleColor == TimerTheme.color(for: .focused))
    }

    // MARK: - Review Request

    @Test("shouldRequestReview becomes true after full Pomodoro set when review is enabled")
    func shouldRequestReviewBecomesTrueAfterFullSet() {
        let (viewModel, timerFactory) = makeSUT(isReviewEnabled: true)

        #expect(!viewModel.shouldRequestReview)

        // Drive through full set: focused(6) → short break(3) → focused(6) → long break(4)
        viewModel.startTimer(); timerFactory.advance(by: 6)  // focused → short break
        viewModel.startTimer(); timerFactory.advance(by: 3)  // short break → focused (cycle 1)
        viewModel.startTimer(); timerFactory.advance(by: 6)  // focused → long break (cycle 2)
        viewModel.startTimer(); timerFactory.advance(by: 4)  // long break expires → full set done

        #expect(viewModel.shouldRequestReview)
    }

    @Test("shouldRequestReview stays false when review is disabled")
    func shouldRequestReviewStaysFalseWhenDisabled() {
        let (viewModel, timerFactory) = makeSUT(isReviewEnabled: false)

        viewModel.startTimer(); timerFactory.advance(by: 6)
        viewModel.startTimer(); timerFactory.advance(by: 3)
        viewModel.startTimer(); timerFactory.advance(by: 6)
        viewModel.startTimer(); timerFactory.advance(by: 4)

        #expect(!viewModel.shouldRequestReview)
    }

    @Test("shouldRequestReview does not become true during intermediate transitions")
    func shouldRequestReviewDoesNotTriggerOnIntermediateTransitions() {
        let (viewModel, timerFactory) = makeSUT(isReviewEnabled: true)

        // Only complete focus → short break → focus (no long break yet)
        viewModel.startTimer(); timerFactory.advance(by: 6)
        viewModel.startTimer(); timerFactory.advance(by: 3)

        #expect(!viewModel.shouldRequestReview)
    }
}

private extension LiveActivityEvent {
    var snapshotStatus: TimerActivityStatus? {
        switch self {
        case .started(let snapshot), .paused(let snapshot):
            snapshot.status
        case .reconcile, .phaseCompleted, .reset, .preferenceChanged:
            nil
        }
    }
}
