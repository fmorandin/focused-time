//
//  ContentView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 28/09/20.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Environment

    @Environment(Router.self) private var router

    // MARK: - State

    @State private var onboardingViewModel: OnboardingViewModel
    @State private var whatsNewViewModel: WhatsNewViewModel

    // MARK: - Initializer

    init(
        onboardingViewModel: OnboardingViewModel = OnboardingViewModel(),
        whatsNewViewModel: WhatsNewViewModel = WhatsNewViewModel()
    ) {
        _onboardingViewModel = State(wrappedValue: onboardingViewModel)
        _whatsNewViewModel = State(wrappedValue: whatsNewViewModel)
    }

    // MARK: - View

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            Tab("tabLabelTimer", systemImage: "timer", value: Router.AppTab.timer) {
                TimerView()
            }
            .accessibilityIdentifier(Accessibility.Identifiers.tabTimer)

            Tab("tabLabelSettings", systemImage: "gear", value: Router.AppTab.settings) {
                NavigationStack(path: $router.settingsPath) {
                    SettingsView(displayWarning: router.settingsDisplaysWarning)
                }
            }
            .accessibilityIdentifier(Accessibility.Identifiers.tabSettings)

            Tab("tabLabelHelp", systemImage: "questionmark.circle", value: Router.AppTab.help) {
                NavigationStack {
                    HelpView()
                }
            }
            .accessibilityIdentifier(Accessibility.Identifiers.tabHelp)
        }
        .sheet(item: $router.launchPresentation) { presentation in
            switch presentation {
            case .onboarding:
                OnboardingView(viewModel: onboardingViewModel)
            case .whatsNew:
                if let release = whatsNewViewModel.releaseToPresent {
                    WhatsNewView(viewModel: whatsNewViewModel, release: release)
                }
            }
        }
        .task {
            guard !onboardingViewModel.presentIfNeeded(router: router) else { return }
            whatsNewViewModel.presentIfNeeded(router: router)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(Router())
    }
}
