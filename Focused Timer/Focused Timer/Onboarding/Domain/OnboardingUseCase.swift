//
//  OnboardingUseCase.swift
//  Focused Timer
//

import Foundation

struct OnboardingUseCase {

    // MARK: - Private Variables

    private let model: any OnboardingModelProtocol

    // MARK: - Initializer

    init(model: any OnboardingModelProtocol = OnboardingModel()) {
        self.model = model
    }

    // MARK: - Methods

    /// Resolves the first-launch decision and records presentation immediately.
    /// This keeps the guide limited to the first opening even if the app is
    /// terminated while it is visible.
    func resolveShouldPresent() -> Bool {
        guard !self.model.hasSeenOnboarding else { return false }

        self.model.markOnboardingAsSeen()
        return true
    }
}
