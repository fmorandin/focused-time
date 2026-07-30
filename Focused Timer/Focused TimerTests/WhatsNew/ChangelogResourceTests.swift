//
//  ChangelogResourceTests.swift
//  Focused TimerTests
//
//  Integration checks against the changelog files that actually ship. These
//  are the tests that fail when a release is added to one language but not
//  the other, or when release notes are written for a build nobody is running.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("Changelog Resource Tests", .serialized)
struct ChangelogResourceTests {

    // MARK: - Helpers

    /// Hosted unit tests run inside the app, so `.main` is the app bundle.
    private static func loadShippedChangelog(language: String) throws -> Changelog {
        let loader = BundleChangelogLoader()
        return try loader.loadChangelog(preferredLanguages: [language])
    }

    // MARK: - Tests

    @Test("Every supported language ships a changelog that decodes",
          arguments: BundleChangelogLoader.supportedLanguages)
    func shippedFileDecodes(language: String) throws {
        let changelog = try Self.loadShippedChangelog(language: language)

        #expect(changelog.language == language)
        #expect(!changelog.releases.isEmpty)
    }

    @Test("Every shipped release has a parsable version and non-empty entries",
          arguments: BundleChangelogLoader.supportedLanguages)
    func shippedReleasesAreWellFormed(language: String) throws {
        let changelog = try Self.loadShippedChangelog(language: language)

        for release in changelog.releases {
            #expect(
                AppVersion(versionString: release.version) != nil,
                "Version \"\(release.version)\" in \(language) is not a valid version"
            )
            #expect(!release.entries.isEmpty, "Release \(release.version) in \(language) has no entries")

            for entry in release.entries {
                #expect(
                    !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "Release \(release.version) in \(language) has an empty entry"
                )
            }
        }
    }

    @Test("No shipped changelog lists the same version twice",
          arguments: BundleChangelogLoader.supportedLanguages)
    func shippedVersionsAreUnique(language: String) throws {
        let changelog = try Self.loadShippedChangelog(language: language)
        let versions = changelog.releases.map(\.version)

        #expect(Set(versions).count == versions.count, "Duplicate versions in \(language)")
    }

    @Test("All languages describe the same set of releases")
    func shippedVersionsMatchAcrossLanguages() throws {
        var versionsByLanguage = [String: Set<String>]()

        for language in BundleChangelogLoader.supportedLanguages {
            let changelog = try Self.loadShippedChangelog(language: language)
            versionsByLanguage[language] = Set(changelog.releases.map(\.version))
        }

        let reference = try #require(versionsByLanguage[BundleChangelogLoader.fallbackLanguage])

        for (language, versions) in versionsByLanguage {
            #expect(
                versions == reference,
                """
                \(language) is missing \(reference.subtracting(versions)) \
                and has extra \(versions.subtracting(reference))
                """
            )
        }
    }

    @Test("Every entry is translated rather than copied from English")
    func shippedEntriesAreTranslated() throws {
        let english = try Self.loadShippedChangelog(language: "en")
        let translated = BundleChangelogLoader.supportedLanguages
            .filter { $0 != BundleChangelogLoader.fallbackLanguage }

        let englishTexts = Set(english.releases.flatMap { $0.entries.map(\.text) })

        for language in translated {
            let changelog = try Self.loadShippedChangelog(language: language)

            for release in changelog.releases {
                for entry in release.entries {
                    #expect(
                        !englishTexts.contains(entry.text),
                        "\(language) release \(release.version) still uses the English text: \(entry.text)"
                    )
                }
            }
        }
    }

    @Test("The newest release notes are not ahead of the shipping build")
    func newestReleaseIsNotAheadOfTheApp() throws {
        let changelog = try Self.loadShippedChangelog(language: "en")
        let latestRelease = try #require(changelog.latestRelease)
        let latestVersion = try #require(AppVersion(versionString: latestRelease.version))
        let appVersion = try #require(AppVersion(versionString: WhatsNewUseCase.bundleVersionString()))

        #expect(
            latestVersion <= appVersion,
            "The changelog announces \(latestVersion) but the app is \(appVersion)"
        )
    }

    @Test("Every entry kind used by the shipped files is one this app renders")
    func shippedEntryKindsAreKnown() throws {
        for language in BundleChangelogLoader.supportedLanguages {
            let changelog = try Self.loadShippedChangelog(language: language)

            for release in changelog.releases {
                for entry in release.entries {
                    #expect(
                        entry.kind != .other,
                        "Release \(release.version) in \(language) uses an unrecognised entry type"
                    )
                }
            }
        }
    }
}
