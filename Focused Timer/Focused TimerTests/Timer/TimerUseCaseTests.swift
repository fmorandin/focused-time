//
//  TimerUseCaseTests.swift
//  Focused TimerTests
//
//  Tests for TimerUseCase — the Pomodoro domain layer.
//  All business logic is tested here directly, without going through TimerViewModel,
//  so these tests remain valid whether the use case is called from a ViewModel,
//  an App Intent, or a Widget extension.
//

// swiftlint:disable file_length
import AudioToolbox
import Testing
@testable import Focused_Timer

// MARK: - Test Doubles

private final class TestRepeatingTimer: RepeatingTimerProtocol {
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

private final class TestRepeatingTimerFactory: RepeatingTimerFactoryProtocol {
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

    /// Fires all non-invalidated timers the given number of times.
    func advance(by ticks: Int = 1) {
        guard ticks > 0 else { return }
        for _ in 0..<ticks {
            createdTimers.filter { !$0.isInvalidated }.forEach { $0.tick() }
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

private final class SoundPlayerSpy: SystemSoundPlaying {
    private(set) var playedSoundIDs: [SystemSoundID] = []

    func playSystemSound(_ identifier: SystemSoundID) {
        playedSoundIDs.append(identifier)
    }
}

private final class NotificationFlagStoreSpy: NotificationFlagStoring {
    var value = false
    private(set) var setCalls: [(Bool, String)] = []

    func bool(forKey _: String) -> Bool { value }

    func set(_ value: Bool, forKey keyName: String) {
        self.value = value
        setCalls.append((value, keyName))
    }
}

/// A configurable spy that implements TimerModelProtocol.
/// Captures `saveMoveToBackgroundTime` calls for assertion.
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
    var savedTimes: (Int?, Date?) = (0, Date())
    var startingTimerType: TimerType = .focused
    private(set) var savedRemainingTimesFromBackground: [Int] = []

    func getTime(for keyName: String) -> Int { times[keyName] ?? 0 }
    func saveMoveToBackgroundTime(remainingTime: Int) { savedRemainingTimesFromBackground.append(remainingTime) }
    func getSavedTimes() -> (Int?, Date?) { savedTimes }
    func getNumberOfCycles(for _: String) -> String { numberOfCycles }
    func getToggle(for keyName: String) -> Bool { toggles[keyName] ?? false }
    func getStartingTimerType() -> TimerType { startingTimerType }
}

// MARK: - SUT Factory

private func makeSUT(
    timerModel: TimerModelProtocol = TimerModelMock(),
    nowProvider: @escaping () -> Date = Date.init,
    notificationManager: LocalNotificationManaging = NotificationManagerSpy(),
    soundPlayer: SystemSoundPlaying = SoundPlayerSpy(),
    notificationFlagStore: NotificationFlagStoring = NotificationFlagStoreSpy()
) -> (useCase: TimerUseCase, timerFactory: TestRepeatingTimerFactory) {
    let timerFactory = TestRepeatingTimerFactory()
    let useCase = TimerUseCase(
        timerModel: timerModel,
        timerFactory: timerFactory,
        nowProvider: nowProvider,
        localNotificationManager: notificationManager,
        soundPlayer: soundPlayer,
        notificationFlagStore: notificationFlagStore
    )
    return (useCase, timerFactory)
}

// MARK: - Tests

@Suite("TimerUseCase Tests", .serialized)
// swiftlint:disable:next type_body_length
struct TimerUseCaseTests {

    // MARK: Initialization

    @Test("Initial state reflects model's focused-time defaults")
    func initialState() {
        let (useCase, _) = makeSUT()

        #expect(useCase.timerState == .initial)
        #expect(useCase.timerType == .focused)
        #expect(useCase.counter == 5)        // TimerModelMock.focusedTime
        #expect(useCase.totalTime == 5)
        #expect(useCase.timerTo == 1.0)
        #expect(useCase.numberOfCompletedCycles == 0)
        #expect(useCase.totalNumberOfCycles == 2) // TimerModelMock returns "2"
    }

    // MARK: Timer Mechanics

    @Test("First tick transitions to running and decrements counter")
    func firstTickSetsRunningState() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        timerFactory.advance()

        #expect(useCase.timerState == .running)
        #expect(useCase.counter == 4)
        #expect(useCase.timerTo == CGFloat(4) / CGFloat(5))
    }

    @Test("Starting the timer twice keeps only a single active timer")
    func startTimerTwiceHasSingleActiveTimer() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        useCase.startTimer()
        timerFactory.advance()

        // Only one active timer should fire, decrementing counter by exactly 1.
        #expect(useCase.counter == 4)
    }

    @Test("Pausing stops the counter and sets state to paused")
    func pauseStopsCounterAndSetsPausedState() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        timerFactory.advance()
        useCase.pauseTimer()

        #expect(useCase.timerState == .paused)
        let pausedCounter = useCase.counter

        timerFactory.advance(by: 3)
        #expect(useCase.counter == pausedCounter)
    }

    // MARK: Phase Transitions

    @Test("Focused phase ends and transitions to short break")
    func focusedPhaseTransitionsToShortBreak() {
        let (useCase, timerFactory) = makeSUT()

        // 5 decrements + 1 mode-change tick = 6
        useCase.startTimer()
        timerFactory.advance(by: 6)

        #expect(useCase.timerState == .initial)
        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.counter == 2)    // shortBreakTime from model
        #expect(useCase.totalTime == 2)
        #expect(useCase.timerTo == 1.0)
        #expect(useCase.numberOfCompletedCycles == 1)
    }

    @Test("Short break ends and transitions back to focused")
    func shortBreakTransitionsBackToFocused() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        timerFactory.advance(by: 6) // focused → short break

        useCase.startTimer()
        timerFactory.advance(by: 3) // 2 decrements + 1 mode-change

        #expect(useCase.timerType == .focused)
        #expect(useCase.counter == 5)
        #expect(useCase.numberOfCompletedCycles == 1)
    }

    @Test("Completing all cycles triggers long break")
    func completingAllCyclesTriggersLongBreak() {
        let (useCase, timerFactory) = makeSUT()

        // 1st focused → short break
        useCase.startTimer()
        timerFactory.advance(by: 6)
        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.numberOfCompletedCycles == 1)

        // short break → focused
        useCase.startTimer()
        timerFactory.advance(by: 3)
        #expect(useCase.timerType == .focused)

        // 2nd focused → long break (cycles == totalCycles == 2)
        useCase.startTimer()
        timerFactory.advance(by: 6)

        #expect(useCase.timerType == .longBreak)
        #expect(useCase.counter == 3)  // longBreakTime from model
        #expect(useCase.numberOfCompletedCycles == 2)
    }

    @Test("Long break ends, resets cycle count, and returns to focused")
    func longBreakResetsAndReturnToFocused() {
        let (useCase, timerFactory) = makeSUT()

        // Drive through both focused sessions and their short break.
        useCase.startTimer(); timerFactory.advance(by: 6) // focused → short break
        useCase.startTimer(); timerFactory.advance(by: 3) // short break → focused
        useCase.startTimer(); timerFactory.advance(by: 6) // focused → long break

        // 3 decrements + 1 mode-change for long break
        useCase.startTimer()
        timerFactory.advance(by: 4)

        #expect(useCase.timerType == .focused)
        #expect(useCase.counter == 5)
        #expect(useCase.timerTo == 1.0)
        #expect(useCase.numberOfCompletedCycles == 0)
    }

    // MARK: Reset

    @Test("resetUpdateTimer restores initial focused state")
    func resetRestoresInitialState() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        timerFactory.advance(by: 3)

        useCase.resetUpdateTimer()

        #expect(useCase.timerState == .initial)
        #expect(useCase.timerType == .focused)
        #expect(useCase.timerTo == 1.0)
        #expect(useCase.counter == 5)
        #expect(useCase.totalTime == 5)
        #expect(useCase.numberOfCompletedCycles == 0)
    }

    @Test("resetUpdateTimer reloads latest focused time from model")
    func resetReloadsLatestSettingsFromModel() {
        let model = TimerModelSpy()
        model.times[UserDefaultKeys.focusedTime] = 10
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance(by: 2)

        // Simulate settings change by updating the model.
        model.times[UserDefaultKeys.focusedTime] = 20
        useCase.resetUpdateTimer()

        #expect(useCase.counter == 20)
        #expect(useCase.totalTime == 20)
    }

    // MARK: Background / Foreground

    @Test("moveAppToBackground when running saves time and schedules notification")
    func backgroundWhenRunningSavesAndSchedules() {
        let model = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            notificationManager: notificationManager
        )

        useCase.startTimer()
        timerFactory.advance()             // counter → 4, state → .running
        useCase.moveAppToBackground()

        #expect(model.savedRemainingTimesFromBackground == [4])
        #expect(notificationManager.scheduledRemainingTimes == [4.0])
    }

    @Test("moveAppToBackground when not running does nothing")
    func backgroundWhenNotRunningDoesNothing() {
        let model = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (useCase, _) = makeSUT(timerModel: model, notificationManager: notificationManager)

        useCase.moveAppToBackground()

        #expect(model.savedRemainingTimesFromBackground.isEmpty)
        #expect(notificationManager.scheduledRemainingTimes.isEmpty)
    }

    @Test("moveAppToForeground always clears scheduled notifications")
    func foregroundAlwaysClearsNotifications() {
        let notificationManager = NotificationManagerSpy()
        let (useCase, _) = makeSUT(notificationManager: notificationManager)

        useCase.moveAppToForeground()

        #expect(notificationManager.clearCalls == 1)
    }

    @Test("moveAppToForeground recalculates counter using injected now provider")
    func foregroundRecalculatesCounterCorrectly() {
        let savedTimestamp = Date(timeIntervalSince1970: 10)
        let nowDate = Date(timeIntervalSince1970: 14)

        let model = TimerModelSpy()
        model.savedTimes = (20, savedTimestamp) // 20 seconds remaining when backgrounded

        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            nowProvider: { nowDate }
        )

        useCase.startTimer()
        timerFactory.advance()             // state → .running
        useCase.moveAppToForeground()

        // 20 saved - 4 seconds in background = 16 remaining
        #expect(useCase.counter == 16)
    }

    @Test("moveAppToForeground with nil saved times leaves counter unchanged")
    func foregroundWithNilSavedTimesKeepsCounter() {
        let model = TimerModelSpy()
        model.savedTimes = (nil, nil)
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance()
        let counterBeforeForeground = useCase.counter

        useCase.moveAppToForeground()

        #expect(useCase.counter == counterBeforeForeground)
    }

    @Test("moveAppToForeground clamps counter to zero when background duration exceeds remaining")
    func foregroundClampsCounterToZeroOnOverrun() {
        let model = TimerModelSpy()
        model.savedTimes = (2, Date(timeIntervalSince1970: 10))
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            nowProvider: { Date(timeIntervalSince1970: 20) }
        )

        useCase.startTimer()
        timerFactory.advance()
        useCase.moveAppToForeground()

        #expect(useCase.counter == 0)
    }

    @Test("moveAppToForeground when not running does not recalculate counter")
    func foregroundWhenNotRunningIgnoresSavedTimes() {
        let model = TimerModelSpy()
        model.savedTimes = (1, Date(timeIntervalSince1970: 0))
        let (useCase, _) = makeSUT(
            timerModel: model,
            nowProvider: { Date(timeIntervalSince1970: 100) }
        )

        let initialCounter = useCase.counter
        useCase.moveAppToForeground()

        #expect(useCase.counter == initialCounter)
    }

    // MARK: onStateChange Callback

    @Test("onStateChange fires on each tick while the timer runs")
    func stateChangeCallbackFiresOnEveryTick() {
        let (useCase, timerFactory) = makeSUT()
        var callCount = 0
        useCase.onStateChange = { callCount += 1 }

        useCase.startTimer()
        timerFactory.advance(by: 3)

        #expect(callCount == 3)
    }

    @Test("onStateChange fires on mode change (when counter reaches zero)")
    func stateChangeCallbackFiresOnModeChange() {
        let (useCase, timerFactory) = makeSUT()
        var callCount = 0
        useCase.onStateChange = { callCount += 1 }

        useCase.startTimer()
        timerFactory.advance(by: 6) // 5 ticks + 1 mode-change tick

        // 5 tick callbacks + 1 mode-change callback
        #expect(callCount == 6)
    }

    @Test("onStateChange fires when timer is paused")
    func stateChangeCallbackFiresOnPause() {
        let (useCase, timerFactory) = makeSUT()
        var callCount = 0

        useCase.startTimer()
        timerFactory.advance()
        useCase.onStateChange = { callCount += 1 }
        useCase.pauseTimer()

        #expect(callCount == 1)
    }

    @Test("onStateChange fires when timer is reset")
    func stateChangeCallbackFiresOnReset() {
        let (useCase, _) = makeSUT()
        var wasCalled = false
        useCase.onStateChange = { wasCalled = true }

        useCase.resetUpdateTimer()

        #expect(wasCalled)
    }

    @Test("onStateChange fires when app returns to foreground with a running timer")
    func stateChangeCallbackFiresOnForeground() {
        let model = TimerModelSpy()
        model.savedTimes = (10, Date(timeIntervalSince1970: 0))
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            nowProvider: { Date(timeIntervalSince1970: 2) }
        )

        useCase.startTimer()
        timerFactory.advance()

        var wasCalled = false
        useCase.onStateChange = { wasCalled = true }
        useCase.moveAppToForeground()

        #expect(wasCalled)
    }

    // MARK: Sound Behaviour

    @Test("Sound plays when enabled and timer is not triggered from a notification")
    func soundPlaysWhenEnabledAndNotFromNotification() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerSpy()
        let flagStore = NotificationFlagStoreSpy()
        flagStore.value = false

        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            soundPlayer: soundPlayer,
            notificationFlagStore: flagStore
        )

        useCase.counter = 0
        useCase.startTimer()
        timerFactory.advance()

        #expect(soundPlayer.playedSoundIDs.count == 1)
    }

    @Test("Sound does not play when timer completion comes from a notification")
    func soundSkippedWhenTriggeredFromNotification() throws {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.playTimerSounds] = true
        let soundPlayer = SoundPlayerSpy()
        let flagStore = NotificationFlagStoreSpy()
        flagStore.value = true  // notification flag set

        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            soundPlayer: soundPlayer,
            notificationFlagStore: flagStore
        )

        useCase.counter = 0
        useCase.startTimer()
        timerFactory.advance()

        #expect(soundPlayer.playedSoundIDs.isEmpty)

        // Flag must be reset to false so subsequent completions play sound again.
        #expect(flagStore.setCalls.count == 1)
        let resetCall = try #require(flagStore.setCalls.first)
        #expect(resetCall.0 == false)
        #expect(resetCall.1 == UserDefaultKeys.isNotification)
    }

    @Test("Sound does not play when the play-sound preference is disabled")
    func soundSkippedWhenPreferenceIsDisabled() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.playTimerSounds] = false
        let soundPlayer = SoundPlayerSpy()

        let (useCase, timerFactory) = makeSUT(timerModel: model, soundPlayer: soundPlayer)

        useCase.counter = 0
        useCase.startTimer()
        timerFactory.advance()

        #expect(soundPlayer.playedSoundIDs.isEmpty)
    }

    // MARK: Settings Queries

    @Test("isKeepScreenOnEnabled reads the keepScreenOn toggle from the model")
    func isKeepScreenOnEnabledReadsModel() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.keepScreenOn] = true
        let (useCase, _) = makeSUT(timerModel: model)

        #expect(useCase.isKeepScreenOnEnabled)

        model.toggles[UserDefaultKeys.keepScreenOn] = false
        #expect(!useCase.isKeepScreenOnEnabled)
    }

    // MARK: Progress Tracking

    @Test("timerTo reflects progress as counter decrements")
    func timerToTracksProgress() {
        let (useCase, timerFactory) = makeSUT()

        #expect(useCase.timerTo == 1.0)

        useCase.startTimer()
        timerFactory.advance()

        // counter = 4, totalTime = 5 → timerTo = 0.8
        #expect(useCase.timerTo == CGFloat(4) / CGFloat(5))
    }

    @Test("timerTo resets to 1.0 after a phase transition")
    func timerToResetsAfterPhaseChange() {
        let (useCase, timerFactory) = makeSUT()

        useCase.startTimer()
        timerFactory.advance(by: 6)

        #expect(useCase.timerTo == 1.0)
    }

    // MARK: Auto-Start

    @Test("Auto-start enabled restarts timer automatically after phase change")
    func autoStartRestartTimer() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.autoStartToggle] = true
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance(by: 6) // focused → short break, then auto-restart

        // After auto-restart the short-break timer should be ticking.
        timerFactory.advance()
        #expect(useCase.timerState == .running)
        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.counter == 1) // shortBreakTime=2, one tick consumed
    }

    @Test("Auto-start disabled does not restart timer after phase change")
    func autoStartDisabledDoesNotRestartTimer() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.autoStartToggle] = false
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance(by: 6)

        // Timer should be in .initial state — no auto-restart.
        #expect(useCase.timerState == .initial)
    }

    // MARK: - Background in Non-Focused Phases

    @Test("moveAppToBackground in short-break phase saves time and schedules notification")
    func backgroundWhenInShortBreakPhaseSchedulesCorrectly() {
        let model = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (useCase, timerFactory) = makeSUT(timerModel: model, notificationManager: notificationManager)

        // Advance to short break
        useCase.startTimer()
        timerFactory.advance(by: 6) // focused (5 decrements) + mode-change (1) → counter = 2

        useCase.startTimer()
        timerFactory.advance()      // counter 2 → 1, state = .running
        useCase.moveAppToBackground()

        #expect(model.savedRemainingTimesFromBackground == [1])
        #expect(notificationManager.scheduledRemainingTimes == [1.0])
    }

    @Test("moveAppToBackground in long-break phase saves time and schedules notification")
    func backgroundWhenInLongBreakPhaseSchedulesCorrectly() {
        let model = TimerModelSpy()
        let notificationManager = NotificationManagerSpy()
        let (useCase, timerFactory) = makeSUT(timerModel: model, notificationManager: notificationManager)

        // Drive to long break: focused → short break → focused → long break
        useCase.startTimer(); timerFactory.advance(by: 6) // focused → short break
        useCase.startTimer(); timerFactory.advance(by: 3) // short break → focused
        useCase.startTimer(); timerFactory.advance(by: 6) // focused → long break, counter = 3

        useCase.startTimer()
        timerFactory.advance()      // counter 3 → 2, state = .running
        useCase.moveAppToBackground()

        #expect(model.savedRemainingTimesFromBackground == [2])
        #expect(notificationManager.scheduledRemainingTimes == [2.0])
    }

    @Test("timer expired in background: counter clamps to zero, next tick advances phase")
    func foregroundClampsCounterToZeroAndNextTickAdvancesPhase() {
        let model = TimerModelSpy()
        model.savedTimes = (2, Date(timeIntervalSince1970: 10))
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            nowProvider: { Date(timeIntervalSince1970: 20) } // 10 s elapsed > 2 s remaining → clamps to 0
        )

        useCase.startTimer()
        timerFactory.advance()              // state → .running, counter → 4
        useCase.moveAppToForeground()       // counter clamped to 0 (timer still active)

        #expect(useCase.counter == 0)
        #expect(useCase.timerState == .running)

        timerFactory.advance()              // counter == 0 → changeTimerMode → short break

        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.numberOfCompletedCycles == 1)
        #expect(useCase.counter == 2)       // shortBreakTime from model
    }

    // MARK: Notification Gating

    @Test("moveAppToBackground schedules notification when notifications are enabled")
    func moveAppToBackgroundSchedulesNotificationWhenEnabled() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.enableNotifications] = true
        let notificationManager = NotificationManagerSpy()
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            notificationManager: notificationManager
        )

        useCase.startTimer()
        timerFactory.advance()
        useCase.moveAppToBackground()

        #expect(notificationManager.scheduledRemainingTimes.count == 1)
    }

    @Test("moveAppToBackground skips notification scheduling when notifications are disabled")
    func moveAppToBackgroundSkipsNotificationWhenDisabled() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.enableNotifications] = false
        let notificationManager = NotificationManagerSpy()
        let (useCase, timerFactory) = makeSUT(
            timerModel: model,
            notificationManager: notificationManager
        )

        useCase.startTimer()
        timerFactory.advance()
        useCase.moveAppToBackground()

        #expect(notificationManager.scheduledRemainingTimes.isEmpty)
    }

    @Test("moveAppToBackground saves remaining time even when notifications are disabled")
    func moveAppToBackgroundSavesTimeWhenNotificationsDisabled() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.enableNotifications] = false
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance()
        useCase.moveAppToBackground()

        #expect(model.savedRemainingTimesFromBackground.isEmpty == false)
    }

    @Test("auto-start drives full short-break cycle and returns to focused")
    func autoStartCompletesShortBreakAndReturnsToFocused() {
        let model = TimerModelSpy()
        model.toggles[UserDefaultKeys.autoStartToggle] = true
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        // 6 ticks: focused (5 decrements + 1 mode-change) → short break with auto-restart
        // 3 ticks: short break (2 decrements + 1 mode-change) → focused with auto-restart
        timerFactory.advance(by: 9)

        #expect(useCase.timerType == .focused)
        #expect(useCase.timerState == .initial)  // set by changeTimerMode before auto-restart fires
        #expect(useCase.counter == 5)            // focusedTime from model
        #expect(useCase.numberOfCompletedCycles == 1) // only focused→shortBreak increments count
    }

    // MARK: - Starting Timer Type

    @Test("init with startingTimerType shortBreak seeds counter and type from short break duration")
    func initWithShortBreakStartingType() {
        let model = TimerModelSpy()
        model.startingTimerType = .shortBreak
        let (useCase, _) = makeSUT(timerModel: model)

        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.counter == 2)     // shortBreakTime from model
        #expect(useCase.totalTime == 2)
        #expect(useCase.timerState == .initial)
    }

    @Test("init with startingTimerType longBreak seeds counter and type from long break duration")
    func initWithLongBreakStartingType() {
        let model = TimerModelSpy()
        model.startingTimerType = .longBreak
        let (useCase, _) = makeSUT(timerModel: model)

        #expect(useCase.timerType == .longBreak)
        #expect(useCase.counter == 3)     // longBreakTime from model
        #expect(useCase.totalTime == 3)
    }

    @Test("resetUpdateTimer resets to configured starting type, not always focused")
    func resetUsesConfiguredStartingType() {
        let model = TimerModelSpy()
        model.startingTimerType = .shortBreak
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        useCase.startTimer()
        timerFactory.advance(by: 2)

        useCase.resetUpdateTimer()

        #expect(useCase.timerType == .shortBreak)
        #expect(useCase.counter == 2)
        #expect(useCase.totalTime == 2)
        #expect(useCase.timerState == .initial)
        #expect(useCase.numberOfCompletedCycles == 0)
    }

    @Test("starting from short break: phase transition goes short break then focused")
    func startingFromShortBreakTransitionsToFocused() {
        let model = TimerModelSpy()
        model.startingTimerType = .shortBreak
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        // 2 decrements + 1 mode-change tick
        useCase.startTimer()
        timerFactory.advance(by: 3)

        #expect(useCase.timerType == .focused)
        #expect(useCase.counter == 5)    // focusedTime from model
        #expect(useCase.numberOfCompletedCycles == 0) // only focused→break increments cycles
    }

    @Test("starting from long break: phase transition goes long break then focused")
    func startingFromLongBreakTransitionsToFocused() {
        let model = TimerModelSpy()
        model.startingTimerType = .longBreak
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        // 3 decrements + 1 mode-change tick
        useCase.startTimer()
        timerFactory.advance(by: 4)

        #expect(useCase.timerType == .focused)
        #expect(useCase.counter == 5)    // focusedTime from model
        #expect(useCase.numberOfCompletedCycles == 0)
    }

    @Test("starting from short break: full cycle completes correctly")
    func startingFromShortBreakFullCycle() {
        let model = TimerModelSpy()
        model.startingTimerType = .shortBreak
        let (useCase, timerFactory) = makeSUT(timerModel: model)

        // SB(3) → F(6) → SB(3) → F(6) → LB (cycles == 2 == totalCycles)
        useCase.startTimer(); timerFactory.advance(by: 3)  // short break → focused
        useCase.startTimer(); timerFactory.advance(by: 6)  // focused → short break (cycle 1)
        useCase.startTimer(); timerFactory.advance(by: 3)  // short break → focused
        useCase.startTimer(); timerFactory.advance(by: 6)  // focused → long break (cycle 2)

        #expect(useCase.timerType == .longBreak)
        #expect(useCase.counter == 3)   // longBreakTime from model
        #expect(useCase.numberOfCompletedCycles == 2)
    }
}
