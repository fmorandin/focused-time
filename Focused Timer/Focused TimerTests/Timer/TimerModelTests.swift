//
//  TimerModelTests.swift
//  Focused TimerTests
//
//  Tests for TimerModel — the thin adapter between the timer domain layer
//  and the StorageRepository. Key concern is that default values are returned
//  when the repository has no stored value (0 sentinel).
//

import Foundation
import Testing
@testable import Focused_Timer

// MARK: - Tests

@Suite("TimerModel Tests", .serialized)
struct TimerModelTests {

    // MARK: - getTime — stored value

    @Test("getTime returns the stored value when non-zero")
    func getTimeReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save(3000, for: UserDefaultKeys.focusedTime)
        let model = TimerModel(repository: repo)

        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == 3000)
    }

    // MARK: - getTime — default fallbacks

    @Test("getTime returns default focused time when nothing is stored")
    func getTimeDefaultFocused() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultFocusedTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == expected)
    }

    @Test("getTime returns default short break time when nothing is stored")
    func getTimeDefaultShortBreak() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultShortBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.shortBreakTime) == expected)
    }

    @Test("getTime returns default long break time when nothing is stored")
    func getTimeDefaultLongBreak() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultLongBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.longBreakTime) == expected)
    }

    @Test("getTime returns zero for an unrecognised key with no stored value")
    func getTimeUnknownKeyReturnsZero() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        #expect(model.getTime(for: "unknownKey") == 0)
    }

    // MARK: - saveMoveToBackgroundTime

    @Test("saveMoveToBackgroundTime persists remaining time")
    func saveBackgroundPersistsRemainingTime() {
        let repo = InMemoryStorageRepository()
        let model = TimerModel(repository: repo)
        model.saveMoveToBackgroundTime(
            remainingTime: 900, timerType: .focused, numberOfCompletedCycles: 0, previousPhaseWasFocus: false
        )
        #expect(repo.integer(for: UserDefaultKeys.remainingTime) == 900)
    }

    @Test("saveMoveToBackgroundTime persists a timestamp")
    func saveBackgroundPersistsTimestamp() {
        let repo = InMemoryStorageRepository()
        let model = TimerModel(repository: repo)
        model.saveMoveToBackgroundTime(
            remainingTime: 300, timerType: .focused, numberOfCompletedCycles: 0, previousPhaseWasFocus: false
        )
        #expect(repo.date(for: UserDefaultKeys.timestampAppMovedBackground) != nil)
    }

    @Test("saveMoveToBackgroundTime persists timer phase state")
    func saveBackgroundPersistsTimerPhaseState() {
        let repo = InMemoryStorageRepository()
        let model = TimerModel(repository: repo)
        model.saveMoveToBackgroundTime(
            remainingTime: 60, timerType: .shortBreak, numberOfCompletedCycles: 2, previousPhaseWasFocus: true
        )
        #expect(repo.string(for: UserDefaultKeys.timerTypeBackground) == TimerType.shortBreak.rawValue)
        #expect(repo.integer(for: UserDefaultKeys.completedCyclesBackground) == 2)
        #expect(repo.bool(for: UserDefaultKeys.previousPhaseWasFocusBackground) == true)
    }

    @Test("getSavedBackgroundTimerState returns nil when nothing was saved")
    func getSavedBackgroundTimerStateReturnsNilWhenEmpty() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        #expect(model.getSavedBackgroundTimerState() == nil)
    }

    @Test("getSavedBackgroundTimerState returns saved phase state")
    func getSavedBackgroundTimerStateReturnsSavedState() {
        let repo = InMemoryStorageRepository()
        let model = TimerModel(repository: repo)
        model.saveMoveToBackgroundTime(
            remainingTime: 30, timerType: .longBreak, numberOfCompletedCycles: 3, previousPhaseWasFocus: false
        )
        let state = model.getSavedBackgroundTimerState()
        #expect(state?.timerType == .longBreak)
        #expect(state?.numberOfCompletedCycles == 3)
        #expect(state?.previousPhaseWasFocus == false)
    }

    @Test("clearSavedBackgroundState causes getSavedBackgroundTimerState to return nil")
    func clearSavedBackgroundStateMakesStateNil() {
        let repo = InMemoryStorageRepository()
        let model = TimerModel(repository: repo)
        model.saveMoveToBackgroundTime(
            remainingTime: 30, timerType: .focused, numberOfCompletedCycles: 0, previousPhaseWasFocus: false
        )
        model.clearSavedBackgroundState()
        #expect(model.getSavedBackgroundTimerState() == nil)
    }

    // MARK: - getSavedTimes

    @Test("getSavedTimes returns nil tuple when no timestamp was saved")
    func getSavedTimesReturnsNilWhenNoTimestamp() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        let (remainingTime, timestamp) = model.getSavedTimes()
        #expect(remainingTime == nil)
        #expect(timestamp == nil)
    }

    @Test("getSavedTimes returns stored values when timestamp exists")
    func getSavedTimesReturnsStoredValues() {
        let repo = InMemoryStorageRepository()
        let savedDate = Date()
        repo.save(1200, for: UserDefaultKeys.remainingTime)
        repo.save(savedDate, for: UserDefaultKeys.timestampAppMovedBackground)
        let model = TimerModel(repository: repo)

        let (remainingTime, timestamp) = model.getSavedTimes()
        #expect(remainingTime == 1200)
        #expect(timestamp != nil)
    }

    // MARK: - getNumberOfCycles

    @Test("getNumberOfCycles returns stored string when non-empty")
    func getNumberOfCyclesReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save("6", for: UserDefaultKeys.numberOfCycles)
        let model = TimerModel(repository: repo)

        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == "6")
    }

    @Test("getNumberOfCycles returns default when nothing is stored")
    func getNumberOfCyclesReturnsDefault() {
        let model = TimerModel(repository: InMemoryStorageRepository())
        let expected = "\(DefaultValuesConstants.defaultNumberOfCycles.rawValue)"
        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == expected)
    }
}
