//
//  ShareService.swift
//  Focused Timer
//
//  Abstracts the UIKit share sheet behind a protocol so SettingsViewModel
//  has no UIKit dependency and is fully testable without a running UIKit hierarchy.
//

import UIKit

@MainActor
protocol ShareService {
    /// Presents the system share sheet for the app.
    func shareApp()
}

// MARK: - UIKit implementation

/// Concrete share service that drives UIActivityViewController.
/// Grabs the key window lazily at share time, so it works regardless of
/// when the service object is created.
@MainActor
struct UIKitShareService: ShareService {

    func shareApp() {
        let appStoreURL = URL(string: "https://apps.apple.com/us/app/focused-timer/id1563481123")!
        let shareMessage = NSString.localizedUserNotificationString(forKey: "shareAppMessage", arguments: nil)

        let activityViewController = UIActivityViewController(
            activityItems: [shareMessage, appStoreURL],
            applicationActivities: nil
        )

        keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - Private

    private var keyWindow: UIWindow? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: \.isKeyWindow)
    }
}
