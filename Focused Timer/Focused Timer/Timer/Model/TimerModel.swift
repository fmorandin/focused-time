//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation

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
}

struct TimerModel: TimerModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Public Methods
    func getTime(for keyName: String) -> Int {
        let totalTime = defaults.integer(forKey: keyName)

        if totalTime != 0 {
            return totalTime
        } else {
            switch keyName {
            case UserDefaultKeys.focusedTime:
                return 1500
            case UserDefaultKeys.restTime:
                return 300
            case UserDefaultKeys.longBreak:
                return 1800
            default:
                return 0
            }
        }
    }

    /// Function that handles what needs to be saved on UserDefaults in order to provide the
    /// necessary information to keep the timer updated
    /// - Parameter remainingTime: how many seconds are remaining in order to the timer finishs
    func saveMoveToBackgroundTime(remainingTime: Int) {
        defaults.setValue(remainingTime, forKey: UserDefaultKeys.remainingTime)
        defaults.setValue(Date(), forKey: UserDefaultKeys.timestampAppMovedBackground)
    }

    /// Function that will return the times that are necessary
    /// in order to recalculate the remaining time when the app is sent back to the foreground
    /// - Returns: a tuple with the remaining time when the user moved the app to the background and a
    ///            timestamp that indicates when that action happened
    func getSavedTimes() -> (Int?, Date?) {
        if let remainingTime = defaults.value(forKey: UserDefaultKeys.remainingTime) as? Int,
           let savedTimestamp = defaults.value(forKey: UserDefaultKeys.timestampAppMovedBackground) as? Date {
            return (remainingTime, savedTimestamp)
        }

        return (nil, nil)
    }

    func getNumberOfCycles(for keyName: String) -> String {
        defaults.string(forKey: keyName) ?? "4"
    }

    func getToggle(for keyName: String) -> Bool {
        defaults.bool(forKey: keyName)
    }
}
