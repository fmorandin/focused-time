//
//  AppearanceMode.swift
//  Focused Timer
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var localizedName: LocalizedStringResource {
        switch self {
        case .system: return LocalizedStringResource("appearanceModeSystem", table: "Localizable")
        case .light: return LocalizedStringResource("appearanceModeLight", table: "Localizable")
        case .dark: return LocalizedStringResource("appearanceModeDark", table: "Localizable")
        }
    }
}
