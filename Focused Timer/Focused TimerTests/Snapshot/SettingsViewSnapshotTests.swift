//
//  SettingsViewSnapshotTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 17/12/2021.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Focused_Timer

class SettingsViewSnapshotTests: XCTestCase {

    // MARK: - Light Mode

    func testSnapshotSettingsViewTogglesOffWithoutWarning() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: false)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotSettingsViewTogglesOnWithoutWarning() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.keepScreenOn = true
        settingsViewModel.isAutoStartEnabled = true
        settingsViewModel.isPlaySoundEnabled = true
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: false)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotSettingsViewTogglesOffWithWarning() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: true)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    func testSnapshotSettingsViewTogglesOnWithWarning() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.keepScreenOn = true
        settingsViewModel.isAutoStartEnabled = true
        settingsViewModel.isPlaySoundEnabled = true
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: true)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    // MARK: - Dark Mode

    func testSnapshotSettingsViewTogglesOffWithoutWarningDarkMode() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: false)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, traits: traitDarkMode))
    }

    func testSnapshotSettingsViewTogglesOnWithoutWarningDarkMode() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.keepScreenOn = true
        settingsViewModel.isAutoStartEnabled = true
        settingsViewModel.isPlaySoundEnabled = true
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: false)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, traits: traitDarkMode))
    }

    func testSnapshotSettingsViewTogglesOffWithWarningDarkMode() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: true)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, traits: traitDarkMode))
    }

    func testSnapshotSettingsViewTogglesOnWithWarningDarkMode() {

        // Test setup
        let settingsModel = SettingsModelMock()
        let settingsViewModel = SettingsViewModel(settingsModel: settingsModel)
        settingsViewModel.keepScreenOn = true
        settingsViewModel.isAutoStartEnabled = true
        settingsViewModel.isPlaySoundEnabled = true
        let settingsView = SettingsView(viewModel: settingsViewModel, displayWarning: true)
        let viewController: UIViewController = UIHostingController(rootView: settingsView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, traits: traitDarkMode))
    }
}
