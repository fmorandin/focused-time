//
//  WhatsNewView.swift
//  Focused Timer
//
//  The alert-like card shown once, on the first launch after an update.
//  Colors come from the asset catalog, which already carries explicit dark
//  variants, so light and dark mode both work without any extra branching.
//

import SwiftUI
import os

struct WhatsNewView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WhatsNewView.self)
    )

    // MARK: - Environment

    @Environment(Router.self) private var router

    // MARK: - Properties

    let viewModel: WhatsNewViewModel
    let release: ChangelogRelease

    // MARK: - Computed Variables

    private var versionText: String {
        String(format: String(localized: "whatsNewVersionLabel"), release.version)
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header

                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(release.entries) { entry in
                            ChangelogEntryRow(entry: entry)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 20)
            }

            footer
        }
        .background(Color.backgroundColor)
        .presentationDetents([.fraction(0.7), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .onAppear {
            Self.logger.notice("✨ What's New View opened.")
        }
    }

    // MARK: - Private Views

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: ImageNames.whatsNew)
                .font(.system(size: 34, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text("whatsNewModalTitle")
                .font(.system(.largeTitle, design: .rounded).bold())
                .accessibilityIdentifier(Accessibility.Identifiers.lblWhatsNewTitle)

            Text(versionText)
                .font(.system(.footnote, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .glassEffect(in: Capsule())
                .accessibilityIdentifier(Accessibility.Identifiers.lblWhatsNewVersion)

            if let releaseTitle = release.title {
                Text(releaseTitle)
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Button(action: {
                HapticsConstants().impactLight.impactOccurred()
                viewModel.dismiss(router: router)
            }, label: {
                Text("whatsNewDismissButton")
                    .font(.system(.body, design: .rounded).bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            })
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .accessibilityIdentifier(Accessibility.Identifiers.btnWhatsNewDismiss)
            .accessibilityLabel(Text("accLabelWhatsNewDismissButton"))

            Button(action: {
                viewModel.showFullChangelog(router: router)
            }, label: {
                Text("whatsNewSeeAllChanges")
                    .font(.system(.footnote, design: .rounded))
            })
            .buttonStyle(.borderless)
            .accessibilityIdentifier(Accessibility.Identifiers.btnWhatsNewSeeAll)
            .accessibilityLabel(Text("accLabelWhatsNewSeeAllButton"))
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    WhatsNewView(
        viewModel: WhatsNewViewModel(),
        release: ChangelogRelease(
            version: "2.1.0",
            date: "2026-07-27",
            title: "See what changed after every update.",
            entries: [
                ChangelogEntry(kind: .added, text: "A What's New screen after each update."),
                ChangelogEntry(kind: .added, text: "The full changelog now lives in Settings."),
                ChangelogEntry(kind: .improved, text: "Release notes are translated into every supported language.")
            ]
        )
    )
    .environment(Router())
}
