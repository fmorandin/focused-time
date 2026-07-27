//
//  ChangelogFixtures.swift
//  Focused TimerTests
//
//  Frozen changelog content for tests, kept separate from the shipped JSON so
//  authoring real release notes never breaks a test.
//

import Foundation
@testable import Focused_Timer

enum ChangelogFixtures {

    static func entry(kind: ChangelogEntryKind = .added, text: String = "Something new.") -> ChangelogEntry {
        ChangelogEntry(kind: kind, text: text)
    }

    static func release(
        version: String,
        date: String? = nil,
        title: String? = nil,
        entries: [ChangelogEntry] = [ChangelogFixtures.entry()]
    ) -> ChangelogRelease {
        ChangelogRelease(version: version, date: date, title: title, entries: entries)
    }

    /// A changelog containing one release per version string, in the order given.
    static func changelog(versions: [String], language: String = "en") -> Changelog {
        Changelog(
            schemaVersion: Changelog.supportedSchemaVersion,
            language: language,
            releases: versions.map { ChangelogFixtures.release(version: $0) }
        )
    }
}
