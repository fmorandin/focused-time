//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation
import os

struct BackgroundTimerState {
    let timerType: TimerType
    let numberOfCompletedCycles: Int
    let previousPhaseWasFocus: Bool
}

protocol TimerModelProtocol {

    /// Function that returns an Int that is saved on UserDefaults based on a key
    /// - Parameter keyName: the key to be searched
    func getTime(for keyName: String) -> Int

    /// Function that handles what is necessary to do when the app is moved to background
    func saveMoveToBackgroundTime(
        remainingTime: Int,
        timerType: TimerType,
        numberOfCompletedCycles: Int,
        previousPhaseWasFocus: Bool
    )

    /// Function that will get the necessary times that were saved
    /// when the app was moved to background
    func getSavedTimes() -> (Int?, Date?)

    /// Returns the timer phase state saved when the app went to background, or nil if none.
    func getSavedBackgroundTimerState() -> BackgroundTimerState?

    /// Clears all persisted background state so stale data cannot be reapplied on a future cold launch.
    func clearSavedBackgroundState()

    /// Return the number of cycles that user is aiming to complete before the long break
    /// - Parameter keyName: the key to be searched
    func getNumberOfCycles(for keyName: String) -> String

    /// Function that gets the saved value for a toggle
    /// - Parameter keyName: the key to be searched
    func getToggle(for keyName: String) -> Bool

    /// Returns the timer type the user has chosen as the starting point
    func getStartingTimerType() -> TimerType
}

struct TimerModel: TimerModelProtocol {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TimerModel.self)
    )

    private let repository: any StorageRepository

    // MARK: - Initializer

    init(repository: any StorageRepository = UserDefaultsRepository()) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func getTime(for keyName: String) -> Int {

        let totalTime: Int = repository.integer(for: keyName)

        if totalTime != 0 {
            return totalTime
        } else {
            switch keyName {
            case UserDefaultKeys.focusedTime:
                return DefaultValuesConstants.defaultFocusedTime.inSeconds()
            case UserDefaultKeys.shortBreakTime:
                return DefaultValuesConstants.defaultShortBreakTime.inSeconds()
            case UserDefaultKeys.longBreakTime:
                return DefaultValuesConstants.defaultLongBreakTime.inSeconds()
            default:
                return 0
            }
        }
    }

    func saveMoveToBackgroundTime(
        remainingTime: Int,
        timerType: TimerType,
        numberOfCompletedCycles: Int,
        previousPhaseWasFocus: Bool
    ) {
        Self.logger.notice("💾 Saving the remaining time, timestamp, and timer phase.")
        repository.save(remainingTime, for: UserDefaultKeys.remainingTime)
        repository.save(Date(), for: UserDefaultKeys.timestampAppMovedBackground)
        repository.save(timerType.rawValue, for: UserDefaultKeys.timerTypeBackground)
        repository.save(numberOfCompletedCycles, for: UserDefaultKeys.completedCyclesBackground)
        repository.save(previousPhaseWasFocus, for: UserDefaultKeys.previousPhaseWasFocusBackground)
    }

    func getSavedBackgroundTimerState() -> BackgroundTimerState? {
        let rawTimerType: String = repository.string(for: UserDefaultKeys.timerTypeBackground)
        guard !rawTimerType.isEmpty, let timerType = TimerType(rawValue: rawTimerType) else { return nil }
        return BackgroundTimerState(
            timerType: timerType,
            numberOfCompletedCycles: repository.integer(for: UserDefaultKeys.completedCyclesBackground),
            previousPhaseWasFocus: repository.bool(for: UserDefaultKeys.previousPhaseWasFocusBackground)
        )
    }

    func clearSavedBackgroundState() {
        Self.logger.notice("🗑 Clearing saved background state.")
        repository.save("", for: UserDefaultKeys.timerTypeBackground)
    }

    /// Function that will return the times that are necessary
    /// in order to recalculate the remaining time when the app is sent back to the foreground
    /// - Returns: a tuple with the remaining time when the user moved the app to the background and a
    ///            timestamp that indicates when that action happened
    func getSavedTimes() -> (Int?, Date?) {

        let remainingTime: Int = repository.integer(for: UserDefaultKeys.remainingTime)
        guard
            let savedTimestamp = repository.date(for: UserDefaultKeys.timestampAppMovedBackground)
        else {
            return (nil, nil)
        }

        Self.logger.notice("📤 Getting the saved remaining time and the timestamp.")

        return (remainingTime, savedTimestamp)
    }

    /// Function to return the number of cycles
    /// - Parameter keyName: the name of the key
    /// - Returns: the string with the number of cycle
    func getNumberOfCycles(for keyName: String) -> String {

        let numberOfCycles: String = repository.string(for: keyName)
        return numberOfCycles == ""
            ? "\(DefaultValuesConstants.defaultNumberOfCycles.rawValue)"
            : numberOfCycles
    }

    /// Return the value for the toggle
    /// - Parameter keyName: the keyname of the toggle
    /// - Returns: the value for the toggle
    func getToggle(for keyName: String) -> Bool {

        repository.bool(for: keyName)
    }

    /// Returns the timer type the user has chosen as the starting point, defaulting to focused
    func getStartingTimerType() -> TimerType {

        let rawValue: String = repository.string(for: UserDefaultKeys.startingTimerType)
        return TimerType(rawValue: rawValue) ?? .focused
    }
}
