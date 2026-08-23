//
//  OnboardingModel.swift
//  Focused Timer
//

import Foundation

// MARK: - Protocols

protocol OnboardingModelProtocol: Sendable {

    /// Whether the first-launch guide has already been presented.
    var hasSeenOnboarding: Bool { get }

    /// Records the guide as presented so it never interrupts a later launch.
    func markOnboardingAsSeen()
}

// MARK: - OnboardingModel

struct OnboardingModel: OnboardingModelProtocol {

    // MARK: - Private Variables

    private let repository: any StorageRepository

    // MARK: - Initializer

    init(repository: any StorageRepository = UserDefaultsRepository()) {
        self.repository = repository
    }

    // MARK: - OnboardingModelProtocol

    var hasSeenOnboarding: Bool {
        self.repository.bool(for: UserDefaultKeys.onboardingHasBeenShown)
    }

    func markOnboardingAsSeen() {
        self.repository.save(true, for: UserDefaultKeys.onboardingHasBeenShown)
    }

    /// Prevents an onboarding feature added in an update from appearing to
    /// people who have already used the app. This runs before AppDelegate
    /// writes the current launch marker, preserving the fresh-install signal.
    func migrateExistingInstallationIfNeeded() {
        guard !self.repository.contains(UserDefaultKeys.onboardingHasBeenShown) else { return }

        let hasLegacyLaunchMarker = self.repository.contains(UserDefaultKeys.isNotification)
        let hasWhatsNewWatermark = self.repository.contains(UserDefaultKeys.whatsNewLastSeenVersion)
        guard hasLegacyLaunchMarker || hasWhatsNewWatermark else { return }

        self.markOnboardingAsSeen()
    }
}
