//
//  TimerSnapshotTests.swift
//  Focused TimerTests
//

import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import Focused_Timer

@MainActor
final class TimerSnapshotTests: XCTestCase, @unchecked Sendable {

    // MARK: - TimerTypePillView

    func test_timerTypePillView_focused() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .focused
        let controller = UIHostingController(rootView: TimerTypePillView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_timerTypePillView_shortBreak() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .shortBreak
        let controller = UIHostingController(rootView: TimerTypePillView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_timerTypePillView_longBreak() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .longBreak
        let controller = UIHostingController(rootView: TimerTypePillView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - CircleView

    func test_circleView_fullProgress_focused() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .focused
        viewModel.timerTo = 1.0
        viewModel.countTime = "25:00"
        viewModel.accentCircleColor = TimerTheme.color(for: .focused)
        let controller = UIHostingController(rootView: CircleView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_circleView_halfProgress_shortBreak() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .shortBreak
        viewModel.timerTo = 0.5
        viewModel.countTime = "02:30"
        viewModel.accentCircleColor = TimerTheme.color(for: .shortBreak)
        let controller = UIHostingController(rootView: CircleView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_circleView_nearlyDone_longBreak() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerType = .longBreak
        viewModel.timerTo = 0.1
        viewModel.countTime = "03:00"
        viewModel.accentCircleColor = TimerTheme.color(for: .longBreak)
        let controller = UIHostingController(rootView: CircleView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_circleView_accessibilityExtraExtraExtraLarge() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.countTime = "25:00"
        let view = CircleView(viewModel: viewModel)
            .environment(\.dynamicTypeSize, .accessibility3)
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - ButtonsView

    func test_buttonsView_initialState() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerState = .initial
        viewModel.timerType = .focused
        viewModel.accentCircleColor = TimerTheme.color(for: .focused)
        let controller = UIHostingController(rootView: ButtonsView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_buttonsView_runningState() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerState = .running
        viewModel.timerType = .focused
        viewModel.accentCircleColor = TimerTheme.color(for: .focused)
        let controller = UIHostingController(rootView: ButtonsView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_buttonsView_pausedState() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerState = .paused
        viewModel.timerType = .focused
        viewModel.accentCircleColor = TimerTheme.color(for: .focused)
        let controller = UIHostingController(rootView: ButtonsView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_buttonsView_shortBreakColors() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerState = .initial
        viewModel.timerType = .shortBreak
        viewModel.accentCircleColor = TimerTheme.color(for: .shortBreak)
        let controller = UIHostingController(rootView: ButtonsView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_buttonsView_longBreakColors() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.timerState = .initial
        viewModel.timerType = .longBreak
        viewModel.accentCircleColor = TimerTheme.color(for: .longBreak)
        let controller = UIHostingController(rootView: ButtonsView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    // MARK: - FlowCounterView

    func test_flowCounterView_noCyclesCompleted() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.totalNumberOfCycles = 4
        viewModel.numberOfCompletedCycles = 0
        let controller = UIHostingController(rootView: FlowCounterView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_flowCounterView_halfCyclesCompleted() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.totalNumberOfCycles = 4
        viewModel.numberOfCompletedCycles = 2
        let controller = UIHostingController(rootView: FlowCounterView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_flowCounterView_allCyclesCompleted() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.totalNumberOfCycles = 4
        viewModel.numberOfCompletedCycles = 4
        let controller = UIHostingController(rootView: FlowCounterView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }

    func test_flowCounterView_sixCycles_threeCompleted() {
        let viewModel = TimerViewModel(timerModel: TimerModelMock())
        viewModel.totalNumberOfCycles = 6
        viewModel.numberOfCompletedCycles = 3
        let controller = UIHostingController(rootView: FlowCounterView(viewModel: viewModel))
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }
}
