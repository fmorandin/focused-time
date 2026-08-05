//
//  InMemoryStorageRepository.swift
//  Focused TimerTests
//
//  Shared in-memory StorageRepository test double.
//

import Foundation
@testable import Focused_Timer

final class InMemoryStorageRepository: StorageRepository, @unchecked Sendable {

    private var storage: [String: Any] = [:]

    func save<Value: Sendable>(_ value: Value, for storageKey: String) {
        storage[storageKey] = value
    }

    func contains(_ storageKey: String) -> Bool {
        storage[storageKey] != nil
    }

    func integer(for storageKey: String) -> Int {
        storage[storageKey] as? Int ?? 0
    }

    func string(for storageKey: String) -> String {
        storage[storageKey] as? String ?? ""
    }

    func bool(for storageKey: String) -> Bool {
        storage[storageKey] as? Bool ?? false
    }

    func date(for storageKey: String) -> Date? {
        storage[storageKey] as? Date
    }
}
