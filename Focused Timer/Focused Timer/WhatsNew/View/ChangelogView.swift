//
//  ChangelogView.swift
//  Focused Timer
//
//  The full release history, pushed from the Settings tab. Follows the same
//  inset-grouped list shape as `HelpView`.
//

import SwiftUI
import os

struct ChangelogView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ChangelogView.self)
    )

    // MARK: - State

    @State private var viewModel: WhatsNewViewModel

    // MARK: - Initializer

    init(viewModel: WhatsNewViewModel = WhatsNewViewModel()) {
        Self.logger.notice("🛠 Initializing Changelog View.")
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - View

    var body: some View {
        List {
            if viewModel.allReleases.isEmpty {
                Section {
                    Text("changelogEmptyMessage")
                        .helpSectionText()
                        .accessibilityIdentifier(Accessibility.Identifiers.lblChangelogEmpty)
                }
            } else {
                ForEach(viewModel.allReleases) { release in
                    Section {
                        ForEach(release.entries) { entry in
                            ChangelogEntryRow(entry: entry)
                                .padding(.vertical, 6)
                        }
                    } header: {
                        releaseHeader(for: release)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(12)
        .contentMargins(.top, 24, for: .scrollContent)
        .navigationTitle("changelogNavigationTitle")
        .onAppear {
            Self.logger.notice("📄 Changelog View opened.")
        }
    }

    // MARK: - Private Views

    private func releaseHeader(for release: ChangelogRelease) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(release.version)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.accentColor)

            Spacer()

            if let releaseDate = release.releaseDate {
                Text(releaseDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .textCase(nil)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(Accessibility.Identifiers.lblChangelogRelease)
    }
}

#Preview {
    NavigationStack {
        ChangelogView()
    }
}
