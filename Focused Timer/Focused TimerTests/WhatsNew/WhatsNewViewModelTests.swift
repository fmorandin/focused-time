//
//  WhatsNewViewModelTests.swift
//  Focused TimerTests
//

import Testing
@testable import Focused_Timer

@MainActor
@Suite("WhatsNewViewModel Tests", .serialized)
struct WhatsNewViewModelTests {

    // MARK: - Stub

    private final class WhatsNewModelStub: WhatsNewModelProtocol, @unchecked Sendable {

        var lastSeenVersion: String
        var isWhatsNewSuppressed: Bool

        init(lastSeenVersion: String = "", isWhatsNewSuppressed: Bool = false) {
            self.lastSeenVersion = lastSeenVersion
            self.isWhatsNewSuppressed = isWhatsNewSuppressed
        }

        func saveLastSeenVersion(_ version: String) {
            lastSeenVersion = version
        }
    }

    // MARK: - Loading

    @Test("Exposes every release from the loaded changelog, newest first")
    func exposesAllReleases() {
        let changelog = ChangelogFixtures.changelog(versions: ["1.0.0", "2.1.0", "2.0.0"])
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: changelog),
            model: WhatsNewModelStub()
        )

        #expect(viewModel.allReleases.map(\.version) == ["2.1.0", "2.0.0", "1.0.0"])
        #expect(viewModel.latestRelease?.version == "2.1.0")
    }

    @Test("A throwing loader degrades to an empty changelog instead of crashing")
    func throwingLoaderDegradesGracefully() {
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(error: .resourceNotFound),
            model: WhatsNewModelStub()
        )

        #expect(viewModel.allReleases.isEmpty)
        #expect(viewModel.latestRelease == nil)
    }

    // MARK: - presentIfNeeded

    @Test("presentIfNeeded presents the router when an upgrade is detected")
    func presentIfNeededPresentsOnUpgrade() {
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: changelog),
            model: WhatsNewModelStub(lastSeenVersion: "2.0.0"),
            currentVersionString: "2.1.0"
        )
        let router = Router()

        viewModel.presentIfNeeded(router: router)

        #expect(router.isWhatsNewPresented == true)
        #expect(viewModel.releaseToPresent?.version == "2.1.0")
    }

    @Test("presentIfNeeded leaves the router untouched when suppressed")
    func presentIfNeededRespectsSuppression() {
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: changelog),
            model: WhatsNewModelStub(lastSeenVersion: "2.0.0", isWhatsNewSuppressed: true),
            currentVersionString: "2.1.0"
        )
        let router = Router()

        viewModel.presentIfNeeded(router: router)

        #expect(router.isWhatsNewPresented == false)
    }

    @Test("presentIfNeeded only takes effect once")
    func presentIfNeededRunsOnce() {
        let changelog = ChangelogFixtures.changelog(versions: ["2.1.0"])
        let model = WhatsNewModelStub(lastSeenVersion: "2.0.0")
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: changelog),
            model: model,
            currentVersionString: "2.1.0"
        )
        let router = Router()

        viewModel.presentIfNeeded(router: router)
        router.dismissWhatsNew()
        viewModel.presentIfNeeded(router: router)

        #expect(router.isWhatsNewPresented == false)
    }

    // MARK: - dismiss

    @Test("dismiss clears the router's presented flag")
    func dismissClearsPresentedFlag() {
        let router = Router()
        router.presentWhatsNew()
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: .empty),
            model: WhatsNewModelStub()
        )

        viewModel.dismiss(router: router)

        #expect(router.isWhatsNewPresented == false)
    }

    // MARK: - showFullChangelog

    @Test("showFullChangelog dismisses the modal and pushes the changelog route")
    func showFullChangelogNavigatesToSettings() {
        let router = Router()
        router.presentWhatsNew()
        let viewModel = WhatsNewViewModel(
            loader: StubChangelogLoader(changelog: .empty),
            model: WhatsNewModelStub()
        )

        viewModel.showFullChangelog(router: router)

        #expect(router.isWhatsNewPresented == false)
        #expect(router.selectedTab == .settings)
        #expect(router.settingsPath == [.changelog])
    }
}
