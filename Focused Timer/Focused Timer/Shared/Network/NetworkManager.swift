//
//  NetworkManager.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 27/07/2021.
//

import Foundation
import os

/// Despite it is called network, at this point, the app has no network calls.
/// This is used, for now, only for UserDefault but its ideia is to be an abstraction
/// preparing for a usage of CloudKit or Firebase
struct NetworkManager {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: NetworkManager.self)
    )

    private let defaults = UserDefaults.standard

    // MARK: - Methods

    func save<T>(value: T, for keyName: String) {

        Self.logger.notice("💾 Saving value \(String(describing: value)) for the key \(keyName).")

        defaults.set(value, forKey: keyName)
    }

    func getValue(for keyName: String) -> Int {

        let savedValue = defaults.integer(forKey: keyName)

        Self.logger.notice("📤 Getting value \(savedValue) for the key \(keyName).")

        return savedValue
    }

    func getValue(for keyName: String) -> String {

        let savedValue = defaults.string(forKey: keyName) ?? ""

        Self.logger.notice("📤 Getting value \(savedValue) for the key \(keyName).")

        return savedValue
    }

    func getValue(for keyName: String) -> Bool {

        let savedValue = defaults.bool(forKey: keyName)

        Self.logger.notice("📤 Getting value \(savedValue) for the key \(keyName).")

        return savedValue
    }

    func getValue(for keyName: String) -> Date? {

        let savedValue = defaults.value(forKey: keyName) as? Date

        Self.logger.notice("📤 Getting value \(String(describing: savedValue)) for the key \(keyName).")

        return savedValue
    }
}
