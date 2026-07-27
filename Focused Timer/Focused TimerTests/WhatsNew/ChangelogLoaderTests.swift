//
//  ChangelogLoaderTests.swift
//  Focused TimerTests
//
//  Covers language resolution and the failure modes of loading the bundled
//  changelog, without touching a real bundle.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("ChangelogLoader Tests", .serialized)
struct ChangelogLoaderTests {

    // MARK: - Helpers

    private static func payload(language: String, version: String = "2.1.0") -> String {
        """
        {
          "schemaVersion": 1,
          "language": "\(language)",
          "releases": [
            {
              "version": "\(version)",
              "entries": [ { "type": "added", "text": "Something new." } ]
            }
          ]
        }
        """
    }

    private static func makeLoader(
        resources: [String: String] = [
            "Changelog_en": ChangelogLoaderTests.payload(language: "en"),
            "Changelog_pt-BR": ChangelogLoaderTests.payload(language: "pt-BR")
        ]
    ) -> (BundleChangelogLoader, InMemoryChangelogDataProvider) {
        let dataProvider = InMemoryChangelogDataProvider(jsonByResource: resources)
        return (BundleChangelogLoader(dataProvider: dataProvider), dataProvider)
    }

    // MARK: - Resource naming

    @Test("An exact language match wins")
    func resolvesExactMatch() {
        #expect(BundleChangelogLoader.resourceName(for: ["pt-BR"]) == "Changelog_pt-BR")
        #expect(BundleChangelogLoader.resourceName(for: ["en"]) == "Changelog_en")
    }

    @Test("A regional variant falls back to the same language", arguments: ["pt", "pt-PT", "pt-AO"])
    func resolvesBySubtag(language: String) {
        #expect(BundleChangelogLoader.resourceName(for: [language]) == "Changelog_pt-BR")
    }

    @Test("An unsupported language falls back to English")
    func resolvesFallback() {
        #expect(BundleChangelogLoader.resourceName(for: ["fr"]) == "Changelog_en")
        #expect(BundleChangelogLoader.resourceName(for: []) == "Changelog_en")
    }

    @Test("A later preference is used when the first is unsupported")
    func resolvesSecondPreference() {
        #expect(BundleChangelogLoader.resourceName(for: ["fr", "pt-BR"]) == "Changelog_pt-BR")
    }

    @Test("Language matching is case insensitive")
    func resolvesCaseInsensitively() {
        #expect(BundleChangelogLoader.resourceName(for: ["PT-br"]) == "Changelog_pt-BR")
    }

    // MARK: - Loading

    @Test("Loads the Portuguese file for a Portuguese device")
    func loadsPortuguese() throws {
        let (loader, _) = Self.makeLoader()

        let changelog = try loader.loadChangelog(preferredLanguages: ["pt-BR"])

        #expect(changelog.language == "pt-BR")
    }

    @Test("Loads the English file for an unsupported language")
    func loadsEnglishFallback() throws {
        let (loader, _) = Self.makeLoader()

        let changelog = try loader.loadChangelog(preferredLanguages: ["fr"])

        #expect(changelog.language == "en")
    }

    @Test("Falls back to English when the resolved file is missing from the bundle")
    func loadsEnglishWhenResolvedFileIsMissing() throws {
        let (loader, dataProvider) = Self.makeLoader(
            resources: ["Changelog_en": Self.payload(language: "en")]
        )

        let changelog = try loader.loadChangelog(preferredLanguages: ["pt-BR"])

        #expect(changelog.language == "en")
        #expect(dataProvider.requestedResources == ["Changelog_pt-BR", "Changelog_en"])
    }

    // MARK: - Failures

    @Test("Throws when no changelog resource exists at all")
    func throwsWhenResourceMissing() {
        let (loader, _) = Self.makeLoader(resources: [:])

        #expect(throws: ChangelogError.resourceNotFound) {
            try loader.loadChangelog(preferredLanguages: ["en"])
        }
    }

    @Test("Throws when the payload cannot be decoded")
    func throwsOnUndecodablePayload() {
        let (loader, _) = Self.makeLoader(resources: ["Changelog_en": "{ not json"])

        #expect(throws: ChangelogError.decodingFailed) {
            try loader.loadChangelog(preferredLanguages: ["en"])
        }
    }

    @Test("Throws when the schema version is not the one this app understands")
    func throwsOnUnsupportedSchema() {
        let json = """
        { "schemaVersion": 99, "language": "en", "releases": [] }
        """
        let (loader, _) = Self.makeLoader(resources: ["Changelog_en": json])

        #expect(throws: ChangelogError.unsupportedSchema(99)) {
            try loader.loadChangelog(preferredLanguages: ["en"])
        }
    }
}
