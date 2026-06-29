//
//  StubRepeatingTimerFactory.swift
//  Focused TimerTests
//
//  A minimal RepeatingTimerFactoryProtocol whose timers only fire when
//  explicitly advanced. Use when you need a TimerViewModel but want
//  manual control over tick behavior.
//

import Foundation
@testable import Focused_Timer

final class StubRepeatingTimerFactory: RepeatingTimerFactoryProtocol {

    private(set) var createdTimers: [StubRepeatingTimer] = []

    func scheduledTimer(
        withTimeInterval _: TimeInterval,
        repeats _: Bool,
        block: @escaping (any RepeatingTimerProtocol) -> Void
    ) -> any RepeatingTimerProtocol {
        let timer = StubRepeatingTimer(block: block)
        createdTimers.append(timer)
        return timer
    }

    /// Fires all non-invalidated timers the given number of times.
    func advance(by ticks: Int = 1) {
        for _ in 0..<ticks {
            createdTimers.filter { !$0.isInvalidated }.forEach { $0.tick() }
        }
    }
}

final class StubRepeatingTimer: RepeatingTimerProtocol {

    private(set) var isInvalidated = false
    private let block: (any RepeatingTimerProtocol) -> Void

    init(block: @escaping (any RepeatingTimerProtocol) -> Void) {
        self.block = block
    }

    func tick() {
        guard !isInvalidated else { return }
        block(self)
    }

    func invalidate() {
        isInvalidated = true
    }
}
