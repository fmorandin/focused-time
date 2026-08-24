//
//  TimerService.swift
//  Focused Timer
//
//  Shared singleton that owns the canonical TimerViewModel instance.
//  Both the SwiftUI view hierarchy and App Intents access the timer through this service.
//

import Foundation
import Observation

@MainActor
protocol TimerServiceProtocol: AnyObject {
    var timerViewModel: TimerViewModel { get }
}

@Observable
@MainActor
final class TimerService: TimerServiceProtocol {

    static var shared: any TimerServiceProtocol = TimerService()

    let timerViewModel: TimerViewModel

    private init() {
        self.timerViewModel = TimerViewModel(timerModel: TimerModel())
    }

    /// Replaces the shared instance — intended for unit tests only.
    static func setSharedForTesting(_ service: any TimerServiceProtocol) {
        shared = service
    }
}
