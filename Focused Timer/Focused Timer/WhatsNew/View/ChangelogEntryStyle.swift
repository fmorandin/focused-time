//
//  ChangelogEntryStyle.swift
//  Focused Timer
//
//  Maps a changelog entry kind to its symbol, tint and localized label.
//  Isolating this here keeps `Color` out of the model layer and means a
//  restyle only touches one file — the same reasoning as `TimerTheme`.
//

import SwiftUI

struct ChangelogEntryStyle {

    // MARK: - Properties

    let symbolName: String
    let tintColor: Color
    let title: LocalizedStringResource

    // MARK: - Static Methods

    static func style(for kind: ChangelogEntryKind) -> ChangelogEntryStyle {

        switch kind {

        case .added:
            return ChangelogEntryStyle(
                symbolName: ImageNames.changeAdded,
                tintColor: .accentColor,
                title: LocalizedStringResource("whatsNewEntryKindAdded", table: "Localizable")
            )

        case .improved:
            return ChangelogEntryStyle(
                symbolName: ImageNames.changeImproved,
                tintColor: .shortBreakColor,
                title: LocalizedStringResource("whatsNewEntryKindImproved", table: "Localizable")
            )

        case .fixed:
            return ChangelogEntryStyle(
                symbolName: ImageNames.changeFixed,
                tintColor: .longBreakColor,
                title: LocalizedStringResource("whatsNewEntryKindFixed", table: "Localizable")
            )

        case .other:
            return ChangelogEntryStyle(
                symbolName: ImageNames.changeOther,
                tintColor: .secondary,
                title: LocalizedStringResource("whatsNewEntryKindOther", table: "Localizable")
            )
        }
    }
}
