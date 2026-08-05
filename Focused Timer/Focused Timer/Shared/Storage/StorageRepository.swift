//
//  StorageRepository.swift
//  Focused Timer
//

import Foundation

/// Abstraction over any persistent key-value store.
/// Concrete implementations: `UserDefaultsRepository` (current), future `CloudKitRepository`.
/// All models and use-cases depend on this protocol, never on a specific backend.
protocol StorageRepository: Sendable {

    /// Persists a value for the given key.
    func save<T: Sendable>(_ value: T, for storageKey: String)

    /// Returns whether a value has been persisted for the given key.
    func contains(_ storageKey: String) -> Bool

    /// Returns the stored integer, or 0 if absent.
    func integer(for storageKey: String) -> Int

    /// Returns the stored string, or an empty string if absent.
    func string(for storageKey: String) -> String

    /// Returns the stored boolean, or false if absent.
    func bool(for storageKey: String) -> Bool

    /// Returns the stored date, or nil if absent.
    func date(for storageKey: String) -> Date?
}
