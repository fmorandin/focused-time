//
//  ChangelogEntryRow.swift
//  Focused Timer
//
//  A single line of release notes, shared by the "What's New" modal and the
//  full changelog screen so both always read the same way.
//

import SwiftUI

struct ChangelogEntryRow: View {

    // MARK: - Properties

    let entry: ChangelogEntry

    // MARK: - View

    var body: some View {

        let style = ChangelogEntryStyle.style(for: entry.kind)

        HStack(alignment: .top, spacing: 12) {
            Image(systemName: style.symbolName)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(style.tintColor)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(style.title)
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(style.tintColor)
                    .textCase(.uppercase)

                Text(entry.text)
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 18) {
        ChangelogEntryRow(entry: ChangelogEntry(kind: .added, text: "A brand new thing you can do."))
        ChangelogEntryRow(entry: ChangelogEntry(kind: .improved, text: "Something familiar, now nicer."))
        ChangelogEntryRow(entry: ChangelogEntry(kind: .fixed, text: "A bug that will not bother you again."))
    }
    .padding()
}
