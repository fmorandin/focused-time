//
//  HelpSnapshotTests.swift
//  Focused TimerTests
//

import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import Focused_Timer

@MainActor
final class HelpSnapshotTests: XCTestCase, @unchecked Sendable {

    // MARK: - HelpView

    func test_helpView_allSections() {
        let controller = UIHostingController(rootView: NavigationStack { HelpView() })
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }
}
