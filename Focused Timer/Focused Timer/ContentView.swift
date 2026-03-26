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
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Dependencies

    private let timerService: TimerServiceProtocol

    // MARK: - Initializer

    init(timerService: TimerServiceProtocol = TimerService.shared) {
        self.timerService = timerService
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
                NavigationStack {
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
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }

    // MARK: - Lifecycle

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            timerService.timerViewModel.moveAppToBackground()
        case .active:
            timerService.timerViewModel.moveAppToForeground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(Router())
    }
}
