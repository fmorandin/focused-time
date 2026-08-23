//
//  OnboardingSnapshotTests.swift
//  Focused TimerTests
//

import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import Focused_Timer

@MainActor
final class OnboardingSnapshotTests: XCTestCase, @unchecked Sendable {

    func test_onboardingView() {
        let view = OnboardingView(viewModel: OnboardingViewModel())
            .environment(Router())
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light
        assertSnapshot(of: controller, as: .image(on: .iPhoneX))
    }
}
