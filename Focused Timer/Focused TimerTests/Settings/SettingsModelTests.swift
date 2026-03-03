//
//  SettingsModelTests.swift
//  Focused TimerTests
//
//  Tests for SettingsModel — validates that minute→second conversion is applied
//  correctly on save, that default values are returned for unknown/unset keys,
//  and that all get/save round-trips work.
//

import Foundation
import Testing
@testable import Focused_Timer

// MARK: - Test Double

private final class InMemoryStorageRepository: StorageRepository, @unchecked Sendable {

    private var storage: [String: Any] = [:]

    func save<Value: Sendable>(_ value: Value, for storageKey: String) {
        storage[storageKey] = value
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

// MARK: - Tests

@Suite("SettingsModel Tests", .serialized)
struct SettingsModelTests {

    // MARK: - saveTime / getTime round-trip

    @Test("saveTime converts minutes to seconds before persisting")
    func saveTimeConvertsToSeconds() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveTime(time: 25, for: UserDefaultKeys.focusedTime)

        // 25 minutes → 1500 seconds
        #expect(repo.integer(for: UserDefaultKeys.focusedTime) == 1500)
    }

    @Test("getTime returns the stored seconds value directly when non-zero")
    func getTimeReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save(1800, for: UserDefaultKeys.focusedTime)
        let model = SettingsModel(repository: repo)

        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == 1800)
    }

    // MARK: - getTime defaults

    @Test("getTime returns default focused time when nothing is stored")
    func getTimeDefaultFocused() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultFocusedTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.focusedTime) == expected)
    }

    @Test("getTime returns default short break time when nothing is stored")
    func getTimeDefaultShortBreak() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultShortBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.shortBreakTime) == expected)
    }

    @Test("getTime returns default long break time when nothing is stored")
    func getTimeDefaultLongBreak() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = DefaultValuesConstants.defaultLongBreakTime.inSeconds()
        #expect(model.getTime(for: UserDefaultKeys.longBreakTime) == expected)
    }

    @Test("getTime returns zero for an unrecognised key with no stored value")
    func getTimeUnknownKeyReturnsZero() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        #expect(model.getTime(for: "unknownTimeKey") == 0)
    }

    // MARK: - saveNumberOfCycles / getNumberOfCycles

    @Test("saveNumberOfCycles persists the raw integer value")
    func saveNumberOfCyclesPersistsValue() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveNumberOfCycles(numberOfCycles: 6, for: UserDefaultKeys.numberOfCycles)

        #expect(repo.integer(for: UserDefaultKeys.numberOfCycles) == 6)
    }

    @Test("getNumberOfCycles returns stored string when non-empty")
    func getNumberOfCyclesReturnsStoredValue() {
        let repo = InMemoryStorageRepository()
        repo.save("3", for: UserDefaultKeys.numberOfCycles)
        let model = SettingsModel(repository: repo)

        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == "3")
    }

    @Test("getNumberOfCycles returns default string when nothing is stored")
    func getNumberOfCyclesReturnsDefault() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        let expected = "\(DefaultValuesConstants.defaultNumberOfCycles.rawValue)"
        #expect(model.getNumberOfCycles(for: UserDefaultKeys.numberOfCycles) == expected)
    }

    // MARK: - saveToggle / getToggle

    @Test("saveToggle persists true value")
    func saveTogglePersistsTrue() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: true, for: UserDefaultKeys.autoStartToggle)

        #expect(repo.bool(for: UserDefaultKeys.autoStartToggle) == true)
    }

    @Test("saveToggle persists false value")
    func saveTogglePersistsFalse() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: false, for: UserDefaultKeys.autoStartToggle)

        #expect(repo.bool(for: UserDefaultKeys.autoStartToggle) == false)
    }

    @Test("getToggle returns false when nothing is stored")
    func getToggleDefaultsFalse() {
        let model = SettingsModel(repository: InMemoryStorageRepository())
        #expect(model.getToggle(for: UserDefaultKeys.keepScreenOn) == false)
    }

    @Test("getToggle round-trips with saveToggle")
    func getToggleRoundTrip() {
        let repo = InMemoryStorageRepository()
        let model = SettingsModel(repository: repo)
        model.saveToggle(value: true, for: UserDefaultKeys.keepScreenOn)
        #expect(model.getToggle(for: UserDefaultKeys.keepScreenOn) == true)
    }
}
