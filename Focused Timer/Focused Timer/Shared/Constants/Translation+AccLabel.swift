//
//  Translation+AccLabel.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 20/05/21.
//

import SwiftUI

extension Translation {

    // Translations used on the accessibility labels
    enum AccLabel {

        // MARK: - Settings Screen

        nonisolated(unsafe) static let accLabelSettingsFocusDurationTxtFld =
            LocalizedStringKey("accLabelSettingsFocusDurationTxtFld")

        nonisolated(unsafe) static let accLabelSettingsShortBreakDurationTxtFld =
            LocalizedStringKey("accLabelSettingsShortBreakDurationTxtFld")

        nonisolated(unsafe) static let accLabelSettingsLongBreakDurationTxtFld =
            LocalizedStringKey("accLabelSettingsLongBreakDurationTxtFld")

        nonisolated(unsafe) static let accLabelSettingsNbrOfCyclesTotalTxtFld =
            LocalizedStringKey("accLabelSettingsNbrOfCyclesTotalTxtFld")

        nonisolated(unsafe) static let accLabelSettingsAutoStartToggle =
            LocalizedStringKey("accLabelSettingsAutoStartToggle")
        nonisolated(unsafe) static let accLabelSettingsPlaySoundsToggle =
            LocalizedStringKey("accLabelSettingsPlaySoundsToggle")
        nonisolated(unsafe) static let accLabelSettingsKeepScreenOnToggle =
            LocalizedStringKey("accLabelSettingsKeepScreenOnToggle")

        // MARK: - Timer Screen

        nonisolated(unsafe) static let accLabelTimerTypeName = LocalizedStringKey("accLabelTimerTypeName")
        nonisolated(unsafe) static let accLabelCounterTypeName = LocalizedStringKey("accLabelCounterTypeName")
        nonisolated(unsafe) static let accLabelCompletedCycleCounter =
            LocalizedStringKey("accLabelCompletedCycleCounter")
    }

}
