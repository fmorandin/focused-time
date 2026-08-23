//
//  OnboardingTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@MainActor
@Suite("Onboarding Tests", .serialized)
struct OnboardingTests {

    // MARK: - Stub

    private final class OnboardingModelStub: OnboardingModelProtocol, @unchecked Sendable {

        var hasSeenOnboarding: Bool
        private(set) var markAsSeenCallCount = 0

        init(hasSeenOnboarding: Bool = false) {
            self.hasSeenOnboarding = hasSeenOnboarding
        }

        func markOnboardingAsSeen() {
            self.hasSeenOnboarding = true
            self.markAsSeenCallCount += 1
        }
    }

    // MARK: - Use Case

    @Test("A fresh installation presents onboarding once and records it immediately")
    func freshInstallationPresentsOnce() {
        let model = OnboardingModelStub()
        let useCase = OnboardingUseCase(model: model)

        #expect(useCase.resolveShouldPresent())
        #expect(!useCase.resolveShouldPresent())
        #expect(model.hasSeenOnboarding)
        #expect(model.markAsSeenCallCount == 1)
    }

    @Test("An installation that has seen onboarding does not present it")
    func seenInstallationDoesNotPresent() {
        let model = OnboardingModelStub(hasSeenOnboarding: true)

        #expect(!OnboardingUseCase(model: model).resolveShouldPresent())
        #expect(model.markAsSeenCallCount == 0)
    }

    // MARK: - Existing Installation Migration

    @Test("An existing installation with the legacy launch marker is silently migrated")
    func legacyInstallationIsMigrated() {
        let repository = InMemoryStorageRepository()
        repository.save(false, for: UserDefaultKeys.isNotification)
        let model = OnboardingModel(repository: repository)

        model.migrateExistingInstallationIfNeeded()

        #expect(model.hasSeenOnboarding)
    }

    @Test("An existing installation with a What's New watermark is silently migrated")
    func whatsNewInstallationIsMigrated() {
        let repository = InMemoryStorageRepository()
        repository.save("2.1.0", for: UserDefaultKeys.whatsNewLastSeenVersion)
        let model = OnboardingModel(repository: repository)

        model.migrateExistingInstallationIfNeeded()

        #expect(model.hasSeenOnboarding)
    }

    @Test("A fresh installation remains eligible for onboarding")
    func freshInstallationIsNotMigrated() {
        let repository = InMemoryStorageRepository()
        let model = OnboardingModel(repository: repository)

        model.migrateExistingInstallationIfNeeded()

        #expect(!repository.contains(UserDefaultKeys.onboardingHasBeenShown))
    }

    @Test("Migration preserves an explicit onboarding value")
    func migrationPreservesExistingValue() {
        let repository = InMemoryStorageRepository()
        repository.save(false, for: UserDefaultKeys.onboardingHasBeenShown)
        repository.save(false, for: UserDefaultKeys.isNotification)
        let model = OnboardingModel(repository: repository)

        model.migrateExistingInstallationIfNeeded()

        #expect(!model.hasSeenOnboarding)
    }

    // MARK: - View Model

    @Test("The view model presents onboarding for an unseen installation")
    func viewModelPresentsOnboarding() {
        let router = Router()
        let viewModel = OnboardingViewModel(model: OnboardingModelStub())

        let didPresent = viewModel.presentIfNeeded(router: router)

        #expect(didPresent)
        #expect(router.launchPresentation == .onboarding)
    }

    @Test("The view model leaves the launch slot free for a returning user")
    func viewModelLeavesLaunchSlotFree() {
        let router = Router()
        let viewModel = OnboardingViewModel(model: OnboardingModelStub(hasSeenOnboarding: true))

        let didPresent = viewModel.presentIfNeeded(router: router)

        #expect(!didPresent)
        #expect(router.launchPresentation == nil)
    }

    @Test("Onboarding keeps ownership of the launch after it is dismissed")
    func onboardingRetainsLaunchOwnership() {
        let router = Router()
        let viewModel = OnboardingViewModel(model: OnboardingModelStub())

        #expect(viewModel.presentIfNeeded(router: router))
        viewModel.dismiss(router: router)

        #expect(viewModel.presentIfNeeded(router: router))
        #expect(router.launchPresentation == nil)
    }
}
