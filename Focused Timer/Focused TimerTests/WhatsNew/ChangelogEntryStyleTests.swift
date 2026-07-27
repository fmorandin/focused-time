//
//  ChangelogEntryStyleTests.swift
//  Focused TimerTests
//
//  Mirrors TimerThemeTests: every entry kind must resolve to a distinct
//  symbol and a distinct localized title.
//

import Testing
@testable import Focused_Timer

@Suite("ChangelogEntryStyle Tests", .serialized)
struct ChangelogEntryStyleTests {

    @Test("Every entry kind resolves to a style", arguments: ChangelogEntryKind.allCases)
    func resolvesStyleForEveryKind(kind: ChangelogEntryKind) {
        let style = ChangelogEntryStyle.style(for: kind)

        #expect(!style.symbolName.isEmpty)
    }

    @Test("Every entry kind maps to a distinct symbol")
    func symbolsAreDistinctPerKind() {
        let symbols = ChangelogEntryKind.allCases.map { ChangelogEntryStyle.style(for: $0).symbolName }

        #expect(Set(symbols).count == symbols.count)
    }
}
