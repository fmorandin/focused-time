//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation

protocol TimerModelProtocol {
    func getTime(for key: String) -> Int
}

struct TimerModel: TimerModelProtocol {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Public Methods
    func getTime(for key: String) -> Int {
        let totalTime = defaults.integer(forKey: key)
        return totalTime != 0 ? totalTime : 60
    }
}
