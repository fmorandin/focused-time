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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(Router())
    }
}
