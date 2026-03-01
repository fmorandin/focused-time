//
//  UserDefaultsRepository.swift
//  Focused Timer
//

import Foundation
import os

/// Concrete `StorageRepository` backed by `UserDefaults`.
/// Replaces the old `NetworkManager` struct.
/// `UserDefaults` is documented as thread-safe, so `@unchecked Sendable` is safe here.
struct UserDefaultsRepository: StorageRepository, @unchecked Sendable {

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UserDefaultsRepository.self)
    )

    private let defaults: UserDefaults

    // MARK: - Initializer

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - StorageRepository

    func save<T: Sendable>(_ value: T, for storageKey: String) {
        Self.logger.notice("💾 Saving value \(String(describing: value)) for key \(storageKey).")
        defaults.set(value, forKey: storageKey)
    }

    func integer(for storageKey: String) -> Int {
        let value = defaults.integer(forKey: storageKey)
        Self.logger.notice("📤 Getting integer \(value) for key \(storageKey).")
        return value
    }

    func string(for storageKey: String) -> String {
        let value = defaults.string(forKey: storageKey) ?? ""
        Self.logger.notice("📤 Getting string \(value) for key \(storageKey).")
        return value
    }

    func bool(for storageKey: String) -> Bool {
        let value = defaults.bool(forKey: storageKey)
        Self.logger.notice("📤 Getting bool \(value) for key \(storageKey).")
        return value
    }

    func date(for storageKey: String) -> Date? {
        let value = defaults.value(forKey: storageKey) as? Date
        Self.logger.notice("📤 Getting date \(String(describing: value)) for key \(storageKey).")
        return value
    }
}
