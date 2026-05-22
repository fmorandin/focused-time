//
//  WidgetStateBridge.swift
//  Focused Timer
//
//  Darwin-notification bridge between the widget extension and the main app.
//  When the widget intent toggles state in a separate process, it cannot update the
//  main app's TimerViewModel directly. Posting a Darwin notification lets the app
//  observe the change in real time instead of waiting for the next foreground
//  transition. Compiled into BOTH targets — the main app posts (rarely) and observes,
//  the widget extension only posts.
//

import Foundation

enum WidgetStateBridge {

    /// Darwin notification name fired whenever a process writes a new WidgetTimerState.
    /// Must match the value used by the widget extension.
    static let notificationName = "br.com.felipemorandin.FocusedTimer.widgetState.didChange"

    /// Posts the Darwin notification. Safe to call from any process that has access
    /// to the App Groups suite — typically the widget extension's toggle intent.
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

/// Observes the `WidgetStateBridge` Darwin notification and dispatches `onChange` to
/// the main actor. The CFNotificationCenter callback fires on an arbitrary thread
/// without captured state, so the indirection via Unmanaged + Task is required.
///
/// Marked `@unchecked Sendable` because the only stored property (`onChange`) is set
/// once at init and never mutated; the Task dispatch hop guarantees all invocations
/// run on the main actor.
final class WidgetStateObserver: @unchecked Sendable {

    private let onChange: () -> Void

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        let observerPointer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observerPointer,
            { _, observerPointer, _, _, _ in
                guard let observerPointer else { return }
                let observerObject = Unmanaged<WidgetStateObserver>
                    .fromOpaque(observerPointer)
                    .takeUnretainedValue()
                Task { @MainActor in
                    observerObject.onChange()
                }
            },
            WidgetStateBridge.notificationName as CFString,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        let observerPointer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveEveryObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observerPointer
        )
    }
}
