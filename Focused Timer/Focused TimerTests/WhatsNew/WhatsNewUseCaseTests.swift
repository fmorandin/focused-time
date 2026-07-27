//
//  WhatsNewUseCaseTests.swift
//  Focused TimerTests
//
//  Covers the once-per-update presentation decision: fresh installs, upgrades,
//  skipped versions, downgrades, patch-only releases and suppression.
//

import Testing
@testable import Focused_Timer

@Suite("WhatsNewUseCase Tests", .serialized)
struct WhatsNewUseCaseTests {

    // MARK: - Stub

    private final class WhatsNewModelStub: WhatsNewModelProtocol, @unchecked Sendable {

        var lastSeenVersion: String
        var isWhatsNewSuppressed: Bool
        private(set) var savedVersions: [String] = []

        init(lastSeenVersion: String = "", isWhatsNewSuppressed: Bool = false) {
            self.lastSeenVersion = lastSeenVersion
            self.isWhatsNewSuppressed = isWhatsNewSuppressed
        }

        func saveLastSeenVersion(_ version: String) {
            lastSeenVersion = version
            savedVersions.append(version)
        }
    }

    // MARK: - Fresh Install

    @Test("A fresh install seeds the latest version and presents nothing")
    func freshInstallSeedsSilently() {
        let model = WhatsNewModelStub(lastSeenVersion: "")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0", "2.0.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
        #expect(model.lastSeenVersion == "2.1.0")
    }

    @Test("A corrupted stored value is treated as a fresh install")
    func corruptedStoredValueSeedsSilently() {
        let model = WhatsNewModelStub(lastSeenVersion: "garbage")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
        #expect(model.lastSeenVersion == "2.1.0")
    }

    // MARK: - Upgrades

    @Test("An upgrade presents the newer release")
    func upgradePresentsNewRelease() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0", "2.0.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release?.version == "2.1.0")
        #expect(model.lastSeenVersion == "2.1.0")
    }

    @Test("Skipping several versions still presents only the newest release")
    func skippedVersionsPresentNewestOnly() {
        let model = WhatsNewModelStub(lastSeenVersion: "1.0.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0", "2.0.0", "1.0.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release?.version == "2.1.0")
    }

    @Test("An unchanged version presents nothing")
    func unchangedVersionPresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.1.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
        #expect(model.savedVersions.isEmpty)
    }

    // MARK: - Downgrades

    @Test("A downgrade presents nothing and does not move the stored watermark backwards")
    func downgradePresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.1.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.0.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.0.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
        #expect(model.lastSeenVersion == "2.1.0")
    }

    // MARK: - Silent releases

    @Test("A patch bump with no matching changelog entry presents nothing")
    func patchWithoutChangelogEntryPresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.1.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.1")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
    }

    @Test("Release notes ahead of the running build present nothing")
    func futureReleasePresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let changelog = ChangelogFixtures.changelog(versions: ["3.0.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let release = useCase.resolveReleaseToPresent()

        #expect(release == nil)
    }

    // MARK: - Empty changelog

    @Test("An empty changelog presents nothing and does not crash")
    func emptyChangelogPresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let useCase = WhatsNewUseCase(model: model, changelog: .empty, currentVersionString: "2.1.0")

        #expect(useCase.resolveReleaseToPresent() == nil)
    }

    // MARK: - Suppression

    @Test("Suppression prevents presentation even with a newer release available")
    func suppressionPreventsPresentation() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0", isWhatsNewSuppressed: true)
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        #expect(useCase.resolveReleaseToPresent() == nil)
        #expect(model.savedVersions.isEmpty)
    }

    // MARK: - Malformed running version

    @Test("An unparsable running app version presents nothing")
    func unparsableRunningVersionPresentsNothing() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "not-a-version")

        #expect(useCase.resolveReleaseToPresent() == nil)
    }

    // MARK: - Idempotency

    @Test("Calling resolveReleaseToPresent twice presents only once")
    func secondCallDoesNotRepresent() {
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let useCase = WhatsNewUseCase(model: model, changelog: changelog, currentVersionString: "2.1.0")

        let firstRelease = useCase.resolveReleaseToPresent()
        let secondRelease = useCase.resolveReleaseToPresent()

        #expect(firstRelease?.version == "2.1.0")
        #expect(secondRelease == nil)
    }
}
