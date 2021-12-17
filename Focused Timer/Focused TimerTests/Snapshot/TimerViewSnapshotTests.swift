//
//  TimerViewSnapshotTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 16/12/2021.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Focused_Timer

class TimerViewSnapshotTests: XCTestCase {

    // MARK: - Light Mode

    func testSnapshotTimerViewInitialState() {
        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotTimerViewRunningState() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotTimerViewShortBreakInitialState() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.changeTimerMode()
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotTimerViewShortBreakRunningState() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.changeTimerMode()
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotTimerViewLongBreakInitialState() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.numberOfCompletedCycles = 1
        timerViewModel.changeTimerMode()
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotTimerViewLongBreakRunningState() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.numberOfCompletedCycles = 1
        timerViewModel.changeTimerMode()
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    // MARK: - Dark Mode

    func testSnapshotTimerViewInitialStateDarkMode() {
        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

    func testSnapshotTimerViewRunningStateDarkMode() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

    func testSnapshotTimerViewShortBreakInitialStateDarkMode() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.changeTimerMode()
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

    func testSnapshotTimerViewShortBreakRunningStateDarkMode() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.changeTimerMode()
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

    func testSnapshotTimerViewLongBreakInitialStateDarkMode() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.numberOfCompletedCycles = 1
        timerViewModel.changeTimerMode()
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

    func testSnapshotTimerViewLongBreakRunningStateDarkMode() {

        // Test setup
        let timerModel = TimerModelMock()
        let timerViewModel = TimerViewModel(timerModel: timerModel)
        timerViewModel.numberOfCompletedCycles = 1
        timerViewModel.changeTimerMode()
        timerViewModel.timerState = .running
        let timerView = TimerView(viewModel: timerViewModel)
        let viewController: UIViewController = UIHostingController(rootView: timerView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(traits: traitDarkMode))
    }

}
