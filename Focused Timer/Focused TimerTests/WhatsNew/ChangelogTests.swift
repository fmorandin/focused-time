//
//  ChangelogTests.swift
//  Focused TimerTests
//
//  Decoding is deliberately forgiving about content authored by hand, so most
//  of these tests are about degrading instead of throwing.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("Changelog Tests", .serialized)
struct ChangelogTests {

    // MARK: - Helpers

    private static func decode(_ json: String) throws -> Changelog {
        try JSONDecoder().decode(Changelog.self, from: Data(json.utf8))
    }

    private static let validJSON = """
    {
      "schemaVersion": 1,
      "language": "en",
      "releases": [
        {
          "version": "2.1.0",
          "date": "2026-07-27",
          "title": "A headline",
          "entries": [
            { "type": "added", "text": "Something new." },
            { "type": "improved", "text": "Something better." },
            { "type": "fixed", "text": "Something repaired." }
          ]
        }
      ]
    }
    """

    // MARK: - Decoding

    @Test("Decodes a complete payload")
    func decodesValidPayload() throws {
        let changelog = try Self.decode(Self.validJSON)
        let release = try #require(changelog.releases.first)

        #expect(changelog.schemaVersion == 1)
        #expect(changelog.language == "en")
        #expect(release.version == "2.1.0")
        #expect(release.title == "A headline")
        #expect(release.entries.map(\.kind) == [.added, .improved, .fixed])
        #expect(release.entries.first?.text == "Something new.")
    }

    @Test("An unknown entry type decodes as .other instead of throwing")
    func decodesUnknownEntryKind() throws {
        let json = """
        {
          "schemaVersion": 1,
          "language": "en",
          "releases": [
            { "version": "1.0.0", "entries": [ { "type": "removed", "text": "Gone." } ] }
          ]
        }
        """

        let changelog = try Self.decode(json)

        #expect(changelog.releases.first?.entries.first?.kind == .other)
    }

    @Test("Optional date and title may be omitted")
    func decodesWithoutOptionalFields() throws {
        let json = """
        {
          "schemaVersion": 1,
          "language": "en",
          "releases": [
            { "version": "1.0.0", "entries": [ { "type": "added", "text": "First." } ] }
          ]
        }
        """

        let changelog = try Self.decode(json)
        let release = try #require(changelog.releases.first)

        #expect(release.date == nil)
        #expect(release.title == nil)
        #expect(release.releaseDate == nil)
    }

    @Test("An empty release list decodes to an empty changelog")
    func decodesEmptyReleases() throws {
        let json = """
        { "schemaVersion": 1, "language": "en", "releases": [] }
        """

        let changelog = try Self.decode(json)

        #expect(changelog.releases.isEmpty)
        #expect(changelog.latestRelease == nil)
    }

    @Test("Malformed JSON throws")
    func throwsOnMalformedJSON() {
        #expect(throws: (any Error).self) {
            try Self.decode("{ not json")
        }
    }

    @Test("A missing required field throws")
    func throwsOnMissingRequiredField() {
        let json = """
        { "schemaVersion": 1, "language": "en", "releases": [ { "entries": [] } ] }
        """

        #expect(throws: (any Error).self) {
            try Self.decode(json)
        }
    }

    // MARK: - Dates

    @Test("A valid date is parsed")
    func parsesReleaseDate() throws {
        let changelog = try Self.decode(Self.validJSON)
        let release = try #require(changelog.releases.first)
        let releaseDate = try #require(release.releaseDate)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let components = calendar.dateComponents([.year, .month, .day], from: releaseDate)

        #expect(components.year == 2026)
        #expect(components.month == 7)
        #expect(components.day == 27)
    }

    @Test("A malformed date degrades to nil rather than failing the file", arguments: [
        "not-a-date", "2026-07", "2026/07/27", "", "2026-xx-27"
    ])
    func degradesOnMalformedDate(rawDate: String) throws {
        let json = """
        {
          "schemaVersion": 1,
          "language": "en",
          "releases": [
            {
              "version": "1.0.0",
              "date": "\(rawDate)",
              "entries": [ { "type": "added", "text": "First." } ]
            }
          ]
        }
        """

        let changelog = try Self.decode(json)
        let release = try #require(changelog.releases.first)

        #expect(release.releaseDate == nil)
        #expect(release.version == "1.0.0")
    }

    // MARK: - Ordering

    @Test("Releases are sorted by version, not by their order in the file")
    func sortsReleasesDescending() {
        let changelog = ChangelogFixtures.changelog(versions: ["1.0.0", "2.10.0", "2.9.0", "2.1.0"])

        #expect(changelog.releasesSortedDescending.map(\.version) == ["2.10.0", "2.9.0", "2.1.0", "1.0.0"])
    }

    @Test("latestRelease returns the highest version even when the file is out of order")
    func returnsHighestRelease() {
        let changelog = ChangelogFixtures.changelog(versions: ["1.0.0", "2.9.0", "2.10.0"])

        #expect(changelog.latestRelease?.version == "2.10.0")
    }

    @Test("Releases with an unparsable version are dropped")
    func dropsUnparsableReleases() {
        let changelog = Changelog(
            schemaVersion: Changelog.supportedSchemaVersion,
            language: "en",
            releases: [
                ChangelogFixtures.release(version: "not-a-version"),
                ChangelogFixtures.release(version: "2.0.0")
            ]
        )

        #expect(changelog.releasesSortedDescending.map(\.version) == ["2.0.0"])
        #expect(changelog.latestRelease?.version == "2.0.0")
    }

    @Test("The empty changelog has no releases")
    func emptyChangelogHasNoReleases() {
        #expect(Changelog.empty.releases.isEmpty)
        #expect(Changelog.empty.latestRelease == nil)
    }
}
