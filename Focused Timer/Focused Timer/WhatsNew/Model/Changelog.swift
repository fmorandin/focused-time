//
//  Changelog.swift
//  Focused Timer
//
//  Value types mirroring the bundled `Changelog_<language>.json` files.
//  Pure Foundation — no SwiftUI, no colors — so the whole model layer is
//  unit-testable without a simulator.
//

import Foundation

// MARK: - ChangelogEntryKind

/// The kind of change described by a single changelog entry.
enum ChangelogEntryKind: String, Codable, Sendable, CaseIterable {

    case added
    case improved
    case fixed
    case other

    /// Decoding is lenient on purpose: an unrecognised `type` in the JSON
    /// degrades to `.other` instead of failing the whole file.
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawText = try container.decode(String.self)
        self = ChangelogEntryKind(rawValue: rawText) ?? .other
    }
}

// MARK: - ChangelogEntry

/// One line of release notes. `text` is already localized by the file it came from.
struct ChangelogEntry: Decodable, Equatable, Sendable, Identifiable {

    let kind: ChangelogEntryKind
    let text: String

    var id: String { "\(self.kind.rawValue)-\(self.text)" }

    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case text
    }
}

// MARK: - ChangelogRelease

/// Every change shipped in a single version.
struct ChangelogRelease: Decodable, Equatable, Sendable, Identifiable {

    let version: String
    let date: String?
    let title: String?
    let entries: [ChangelogEntry]

    var id: String { self.version }

    /// `nil` when the JSON carries a version string this app cannot parse.
    var appVersion: AppVersion? { AppVersion(versionString: self.version) }

    /// Parsed from the optional `yyyy-MM-dd` field.
    /// A malformed date degrades to "no date shown" rather than failing decoding.
    var releaseDate: Date? {

        guard let rawDate = self.date else { return nil }

        let components = rawDate.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let dayOfMonth = Int(components[2]) else { return nil }

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = dayOfMonth

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone

        return calendar.date(from: dateComponents)
    }
}

// MARK: - Changelog

/// The decoded contents of one `Changelog_<language>.json` file.
struct Changelog: Decodable, Equatable, Sendable {

    // MARK: - Constants

    /// Bumped only when the JSON layout changes in a backwards-incompatible way.
    static let supportedSchemaVersion = 1

    static let empty = Changelog(
        schemaVersion: Changelog.supportedSchemaVersion,
        language: "en",
        releases: []
    )

    // MARK: - Properties

    let schemaVersion: Int
    let language: String
    let releases: [ChangelogRelease]

    // MARK: - Computed Variables

    /// Releases ordered newest first. The order inside the JSON is never trusted,
    /// and releases with an unparsable version string are dropped.
    var releasesSortedDescending: [ChangelogRelease] {
        self.releases
            .compactMap { release in
                release.appVersion.map { (version: $0, release: release) }
            }
            .sorted { $0.version > $1.version }
            .map(\.release)
    }

    /// The highest semantic version present in the file.
    var latestRelease: ChangelogRelease? {
        self.releasesSortedDescending.first
    }
}
