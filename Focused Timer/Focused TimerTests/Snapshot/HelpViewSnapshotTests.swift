//
//  HelpViewSnapshotTests.swift
//  Focused TimerTests
//
//  Created by Felipe Morandin on 17/12/2021.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Focused_Timer

class HelpViewSnapshotTests: XCTestCase {

    // MARK: - Light Mode

    func testSnapshotHelpView() {
        // Test setup
        let helpView = HelpView()
        let viewController: UIViewController = UIHostingController(rootView: helpView)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax))
    }

    // MARK: - Dark Mode

    func testSnapshotHelpViewDarkMode() {
        // Test setup
        let helpView = HelpView()
        let viewController: UIViewController = UIHostingController(rootView: helpView)

        // Set the dark mode
        let traitDarkMode = UITraitCollection(userInterfaceStyle: .dark)

        // Assert
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, traits: traitDarkMode))
    }
}
