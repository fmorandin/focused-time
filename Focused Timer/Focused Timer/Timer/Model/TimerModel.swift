//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation
import os

protocol TimerModelProtocol {

    /// Function that returns an Int that is saved on UserDefaults based on a key
    /// - Parameter keyName: the key to be searched
    func getTime(for keyName: String) -> Int

    /// Function that handles what is necessary to do when the app is moved to background
    /// - Parameter remainingTime: the remaining timer for the timer that was running
    func saveMoveToBackgroundTime(remainingTime: Int)

    /// Function that will get the necessary times that were saved
    /// when the app was moved to background
    func getSavedTimes() -> (Int?, Date?)

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

    private let repository: StorageRepository

    // MARK: - Initializer

    init(repository: StorageRepository = UserDefaultsRepository()) {
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

    /// Function that handles what needs to be saved on UserDefaults in order to provide the
    /// necessary information to keep the timer updated
    /// - Parameter remainingTime: how many seconds are remaining in order to the timer finishs
    func saveMoveToBackgroundTime(remainingTime: Int) {

        Self.logger.notice("💾 Saving the remaing time and the timestamp.")

        repository.save(remainingTime, for: UserDefaultKeys.remainingTime)
        repository.save(Date(), for: UserDefaultKeys.timestampAppMovedBackground)
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
