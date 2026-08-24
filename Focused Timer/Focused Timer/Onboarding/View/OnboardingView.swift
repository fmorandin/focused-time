//
//  OnboardingView.swift
//  Focused Timer
//

import SwiftUI
import os

struct OnboardingView: View {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: OnboardingView.self)
    )

    // MARK: - Environment

    @Environment(Router.self) private var router

    // MARK: - Properties

    let viewModel: OnboardingViewModel

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                VStack(spacing: 22) {
                    OnboardingFeatureRow(
                        imageName: ImageNames.onboardingFocus,
                        color: .accentColor,
                        title: "onboardingFocusTitle",
                        description: "onboardingFocusDescription"
                    )
                    OnboardingFeatureRow(
                        imageName: ImageNames.onboardingBreaks,
                        color: .shortBreakColor,
                        title: "onboardingBreaksTitle",
                        description: "onboardingBreaksDescription"
                    )
                    OnboardingFeatureRow(
                        imageName: ImageNames.onboardingCustomize,
                        color: .longBreakColor,
                        title: "onboardingCustomizeTitle",
                        description: "onboardingCustomizeDescription"
                    )
                }

                Text("onboardingHelpHint")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                getStartedButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.backgroundColor)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
        .onAppear {
            Self.logger.notice("👋 Onboarding View opened.")
        }
    }

    // MARK: - Private Views

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: ImageNames.onboardingWelcome)
                .font(.system(size: 48, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text("onboardingTitle")
                .font(.system(.largeTitle, design: .rounded).bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(Accessibility.Identifiers.lblOnboardingTitle)

            Text("onboardingSubtitle")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var getStartedButton: some View {
        Button(action: {
            HapticsConstants.impactLight.impactOccurred()
            viewModel.dismiss(router: router)
        }, label: {
            Text("onboardingGetStartedButton")
                .font(.system(.body, design: .rounded).bold())
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        })
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .accessibilityIdentifier(Accessibility.Identifiers.btnOnboardingGetStarted)
    }
}

private struct OnboardingFeatureRow: View {

    let imageName: String
    let color: Color
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: imageName)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .accessibilityAddTraits(.isHeader)

                Text(description)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
        .environment(Router())
}
