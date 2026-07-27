//
//  WhatsNewViewModel.swift
//  Focused Timer
//
//  Owns the decoded changelog and drives both the "What's New" modal and the
//  full changelog screen. All collaborators are constructor-injected so the
//  whole class can be exercised without a bundle or a simulator.
//

import Foundation
import Observation
import os

@MainActor
@Observable
final class WhatsNewViewModel {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WhatsNewViewModel.self)
    )

    private let model: any WhatsNewModelProtocol
    private let currentVersionString: String

    // MARK: - Observable Variables

    private(set) var changelog: Changelog = .empty

    /// The release shown by the modal. `nil` until `presentIfNeeded(router:)`
    /// decides there is something to announce.
    private(set) var releaseToPresent: ChangelogRelease?

    /// Guards against the launch check running again when tabs change.
    private(set) var hasEvaluated = false

    // MARK: - Computed Variables

    /// Every release, newest first. Backs the full changelog screen.
    var allReleases: [ChangelogRelease] {
        self.changelog.releasesSortedDescending
    }

    var latestRelease: ChangelogRelease? {
        self.changelog.latestRelease
    }

    // MARK: - Initializer

    init(
        loader: any ChangelogLoading = BundleChangelogLoader(),
        model: any WhatsNewModelProtocol = WhatsNewModel(),
        currentVersionString: String = WhatsNewUseCase.bundleVersionString(),
        preferredLanguages: [String] = Bundle.main.preferredLocalizations
    ) {
        Self.logger.notice("🛠 Initializing What's New View Model.")

        self.model = model
        self.currentVersionString = currentVersionString

        // A missing or malformed changelog must never take the app down: the
        // feature simply goes quiet.
        do {
            self.changelog = try loader.loadChangelog(preferredLanguages: preferredLanguages)
        } catch {
            Self.logger.error("📄 Could not load the changelog: \(String(describing: error))")
            self.changelog = .empty
        }
    }

    // MARK: - Methods

    /// Runs the once-per-update check and asks the router to show the modal.
    /// Safe to call repeatedly — only the first call has any effect.
    func presentIfNeeded(router: Router) {

        guard !self.hasEvaluated else { return }
        self.hasEvaluated = true

        let useCase = WhatsNewUseCase(
            model: self.model,
            changelog: self.changelog,
            currentVersionString: self.currentVersionString
        )

        guard let release = useCase.resolveReleaseToPresent() else { return }

        Self.logger.notice("✨ Presenting What's New for version \(release.version).")
        self.releaseToPresent = release
        router.presentWhatsNew()
    }

    func dismiss(router: Router) {
        Self.logger.notice("✨ What's New dismissed.")
        router.dismissWhatsNew()
    }

    func showFullChangelog(router: Router) {
        Self.logger.notice("✨ Opening the full changelog from What's New.")
        router.showChangelog()
    }
}
