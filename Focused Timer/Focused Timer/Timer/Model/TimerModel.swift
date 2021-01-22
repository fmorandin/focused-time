//
//  TimerModel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 21/01/21.
//

import Foundation

struct TimerModel {

    // MARK: - Private Variables
    private let defaults = UserDefaults.standard

    // MARK: - Public Methods
    func getTotalTime() -> Int {
        defaults.integer(forKey: "totalTime")
    }
}
