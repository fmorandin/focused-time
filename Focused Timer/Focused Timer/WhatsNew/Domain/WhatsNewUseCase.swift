//
//  WhatsNewUseCase.swift
//  Focused Timer
//
//  Decides whether the "What's New" screen should be shown on this launch.
//  Pure logic with every input injected — no UI, no `Bundle` access at call
//  time — so all of the edge cases below are covered by plain unit tests.
//

import Foundation

// MARK: - WhatsNewDecision

enum WhatsNewDecision: Equatable {

    /// Show the release notes for this release.
    case present(ChangelogRelease)

    /// Record this version silently. Used on a fresh install, where there is
    /// nothing "new" to announce yet.
    case seed(String)

    case doNothing
}

// MARK: - WhatsNewUseCase

struct WhatsNewUseCase {

    // MARK: - Private Variables

    private let model: any WhatsNewModelProtocol
    private let changelog: Changelog
    private let currentVersion: AppVersion?

    // MARK: - Initializer

    init(
        model: any WhatsNewModelProtocol = WhatsNewModel(),
        changelog: Changelog,
        currentVersionString: String = WhatsNewUseCase.bundleVersionString()
    ) {
        self.model = model
        self.changelog = changelog
        self.currentVersion = AppVersion(versionString: currentVersionString)
    }

    // MARK: - Static Methods

    static func bundleVersionString() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Methods

    /// The decision only — makes no changes.
    ///
    /// The comparison is against the newest release *in the changelog*, not the
    /// app's own version. Shipping a patch without adding a changelog entry
    /// therefore shows nothing, which is what a silent release should do.
    func decide() -> WhatsNewDecision {

        guard !self.model.isWhatsNewSuppressed else { return .doNothing }

        guard let currentVersion = self.currentVersion else { return .doNothing }

        guard let latestRelease = self.changelog.latestRelease,
              let latestVersion = latestRelease.appVersion else { return .doNothing }

        // Never advertise notes for a build the user is not running yet.
        guard latestVersion <= currentVersion else { return .doNothing }

        // No usable stored version means a fresh install (or a corrupted value).
        guard let lastSeenVersion = AppVersion(versionString: self.model.lastSeenVersion) else {
            return .seed(latestVersion.description)
        }

        guard latestVersion > lastSeenVersion else { return .doNothing }

        return .present(latestRelease)
    }

    /// Applies `decide()`, persisting the outcome, and returns the release to show.
    ///
    /// The release is marked as seen at presentation time rather than on dismiss:
    /// `onDismiss` never fires if the process is killed while the sheet is open,
    /// which would show the same notes again on the next launch. The full
    /// changelog stays available from Settings, so nothing is lost either way.
    func resolveReleaseToPresent() -> ChangelogRelease? {

        switch self.decide() {

        case .doNothing:
            return nil

        case .seed(let version):
            self.model.saveLastSeenVersion(version)
            return nil

        case .present(let release):
            if let version = release.appVersion {
                self.model.saveLastSeenVersion(version.description)
            }
            return release
        }
    }
}
