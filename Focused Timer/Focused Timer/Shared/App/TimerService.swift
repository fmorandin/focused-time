//
//  TimerService.swift
//  Focused Timer
//
//  Shared singleton that owns the canonical TimerViewModel instance.
//  Both the SwiftUI view hierarchy and App Intents access the timer through this service.
//

import Foundation
import Observation

protocol TimerServiceProtocol: AnyObject, Sendable {
    var timerViewModel: TimerViewModel { get }
}

@Observable
final class TimerService: TimerServiceProtocol, @unchecked Sendable {

    nonisolated(unsafe) static var shared: TimerServiceProtocol = TimerService()

    let timerViewModel: TimerViewModel

    private init() {
        self.timerViewModel = TimerViewModel(
            timerModel: TimerModel(),
            widgetStateReader: AppGroupWidgetStateReader()
        )
    }

    /// Replaces the shared instance — intended for unit tests only.
    static func setSharedForTesting(_ service: TimerServiceProtocol) {
        shared = service
    }
}
