//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation

protocol TimerModelProtocol {
    func getFocusedTime() -> Int
}

struct TimerModel: TimerModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Public Methods
    func getFocusedTime() -> Int {
        let totalTime = defaults.integer(forKey: UserDefaultKeys.focusedTime)
        return totalTime != 0 ? totalTime : 60
    }
}
