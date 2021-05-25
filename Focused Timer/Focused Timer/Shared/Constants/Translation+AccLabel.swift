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

        static let accLabelSettingsFocusDurationTxtFld =
            LocalizedStringKey("accLabelSettingsFocusDurationTxtFld")

        static let accLabelSettingsShortBreakDurationTxtFld =
            LocalizedStringKey("accLabelSettingsShortBreakDurationTxtFld")

        static let accLabelSettingsLongBreakDurationTxtFld =
            LocalizedStringKey("accLabelSettingsLongBreakDurationTxtFld")

        static let accLabelSettingsNbrOfCyclesTotalTxtFld =
            LocalizedStringKey("accLabelSettingsNbrOfCyclesTotalTxtFld")

        static let accLabelSettingsAutoStartToggle = LocalizedStringKey("accLabelSettingsAutoStartToggle")
        static let accLabelSettingsPlaySoundsToggle = LocalizedStringKey("accLabelSettingsPlaySoundsToggle")

        // MARK: - Timer Screen

        static let accLabelTimerTypeName = LocalizedStringKey("accLabelTimerTypeName")
        static let accLabelCounterTypeName = LocalizedStringKey("accLabelCounterTypeName")
        static let accLabelCompletedCycleCounter = LocalizedStringKey("accLabelCompletedCycleCounter")
    }

}
