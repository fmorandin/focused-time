//
//  TimerState.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 01/10/20.
//

import Foundation

/// Enum to handle the possible timer's state
enum TimerState {

    case running
    case paused
    case initial
}

extension TimerState {

    var widgetStateString: String {
        switch self {
        case .running: return "running"
        case .paused: return "paused"
        case .initial: return "initial"
        }
    }
}
