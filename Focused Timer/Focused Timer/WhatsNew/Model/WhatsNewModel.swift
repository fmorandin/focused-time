//
//  WhatsNewModel.swift
//  Focused Timer
//
//  Thin wrapper over `StorageRepository` for the two flags that drive the
//  "What's New" screen, mirroring `SettingsModel` and `TimerModel`.
//

import Foundation

// MARK: - Protocols

protocol WhatsNewModelProtocol: Sendable {

    /// The highest release the user has already been shown, as a version string.
    /// Empty when the app has never recorded one — that is, on a fresh install.
    var lastSeenVersion: String { get }

    /// Set while UI testing so the modal never interrupts an automated run.
    var isWhatsNewSuppressed: Bool { get }

    /// Records a release as seen so it is never presented again.
    func saveLastSeenVersion(_ version: String)
}

// MARK: - WhatsNewModel

struct WhatsNewModel: WhatsNewModelProtocol {

    // MARK: - Private Variables

    private let repository: any StorageRepository

    // MARK: - Initializer

    init(repository: any StorageRepository = UserDefaultsRepository()) {
        self.repository = repository
    }

    // MARK: - WhatsNewModelProtocol

    var lastSeenVersion: String {
        self.repository.string(for: UserDefaultKeys.whatsNewLastSeenVersion)
    }

    var isWhatsNewSuppressed: Bool {
        self.repository.bool(for: UserDefaultKeys.whatsNewSuppressed)
    }

    func saveLastSeenVersion(_ version: String) {
        self.repository.save(version, for: UserDefaultKeys.whatsNewLastSeenVersion)
    }
}
