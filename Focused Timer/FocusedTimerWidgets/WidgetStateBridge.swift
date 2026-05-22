//
//  WidgetStateBridge.swift
//  FocusedTimerWidgets
//
//  Widget-extension copy of WidgetStateBridge — keep in sync with the main app file
//  at `Focused Timer/Shared/Widget/WidgetStateBridge.swift`. Compiled into the widget
//  extension so the toggle intent can post the Darwin notification without depending
//  on the main app's module.
//

import Foundation

enum WidgetStateBridge {

    static let notificationName = "br.com.felipemorandin.FocusedTimer.widgetState.didChange"

    static func postChange() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil,
            nil,
            true
        )
    }
}
