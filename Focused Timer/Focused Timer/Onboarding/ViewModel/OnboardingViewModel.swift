//
//  OnboardingViewModel.swift
//  Focused Timer
//

import Foundation
import Observation
import os

@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: OnboardingViewModel.self)
    )

    private let model: any OnboardingModelProtocol

    // MARK: - Observable Variables

    private(set) var hasEvaluated = false
    private(set) var didPresentOnboarding = false

    // MARK: - Initializer

    init(model: any OnboardingModelProtocol = OnboardingModel()) {
        self.model = model
    }

    // MARK: - Methods

    /// Returns whether onboarding owns this launch's presentation slot. Once it
    /// does, What's New remains skipped for the rest of the app session.
    func presentIfNeeded(router: Router) -> Bool {
        guard !self.hasEvaluated else { return self.didPresentOnboarding }
        self.hasEvaluated = true

        let useCase = OnboardingUseCase(model: self.model)
        guard useCase.resolveShouldPresent() else { return false }

        Self.logger.notice("👋 Presenting onboarding.")
        self.didPresentOnboarding = true
        router.presentOnboarding()
        return true
    }

    func dismiss(router: Router) {
        Self.logger.notice("👋 Onboarding dismissed.")
        router.dismissOnboarding()
    }
}
