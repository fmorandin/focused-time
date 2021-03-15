//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation

protocol TimerModelProtocol {
    func getTime(for keyName: String) -> Int
    func saveMoveToBackgroundTime(remainingTime: Int)
    func getSavedTimes() -> (Int?, Date?)
}

struct TimerModel: TimerModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Public Methods
    func getTime(for keyName: String) -> Int {
        let totalTime = defaults.integer(forKey: keyName)
        return totalTime != 0 ? totalTime : 60
    }

    /// Function that handles what needs to be saved on UserDefaults in order to provide the
    /// necessary information to keep the timer updated
    /// - Parameter remainingTime: how many seconds are remaining in order to the timer finishs
    func saveMoveToBackgroundTime(remainingTime: Int) {
        defaults.setValue(remainingTime, forKey: UserDefaultKeys.remainingTime)
        defaults.setValue(Date(), forKey: UserDefaultKeys.timestampAppMovedBackground)
    }

    func getSavedTimes() -> (Int?, Date?) {
        if let remainingTime = defaults.value(forKey: UserDefaultKeys.remainingTime) as? Int,
           let savedTimestamp = defaults.value(forKey: UserDefaultKeys.timestampAppMovedBackground) as? Date {
            return (remainingTime, savedTimestamp)
        }

        return (nil, nil)
    }
}
