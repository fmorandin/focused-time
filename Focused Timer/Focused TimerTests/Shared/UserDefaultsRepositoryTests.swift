//
//  UserDefaultsRepositoryTests.swift
//  Focused TimerTests
//
//  Tests for UserDefaultsRepository — validates all read/write round-trips
//  and that missing-key reads return the correct zero-value defaults.
//  Each test uses an isolated UserDefaults suite so .standard is never polluted.
//

import Foundation
import Testing
@testable import Focused_Timer

@Suite("UserDefaultsRepository Tests", .serialized)
struct UserDefaultsRepositoryTests {

    // MARK: - Helpers

    /// Returns a fresh UserDefaults instance backed by a unique suite name,
    /// and removes the suite on teardown via the `defer` pattern at the call site.
    private func makeSuitedDefaults() -> UserDefaults {
        let suiteName = "com.focused-timer.tests.\(UUID().uuidString)"
        // UserDefaults(suiteName:) always succeeds for new suite names
        return UserDefaults(suiteName: suiteName)! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Integer round-trip

    @Test("save and integer round-trip preserves value")
    func integerRoundTrip() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save(42, for: "testInt")
        #expect(repo.integer(for: "testInt") == 42)
    }

    @Test("integer returns zero for missing key")
    func integerMissingKeyReturnsZero() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        #expect(repo.integer(for: "missingIntKey") == 0)
    }

    // MARK: - String round-trip

    @Test("save and string round-trip preserves value")
    func stringRoundTrip() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save("hello", for: "testString")
        #expect(repo.string(for: "testString") == "hello")
    }

    @Test("string returns empty string for missing key")
    func stringMissingKeyReturnsEmpty() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        #expect(repo.string(for: "missingStringKey") == "")
    }

    // MARK: - Key existence

    @Test("contains distinguishes stored false from a missing key")
    func containsStoredFalse() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save(false, for: "storedFalse")

        #expect(repo.contains("storedFalse"))
        #expect(!repo.contains("missingKey"))
    }

    // MARK: - Bool round-trip

    @Test("save and bool round-trip preserves true")
    func boolRoundTripTrue() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save(true, for: "testBool")
        #expect(repo.bool(for: "testBool") == true)
    }

    @Test("save and bool round-trip preserves false")
    func boolRoundTripFalse() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save(false, for: "testBool")
        #expect(repo.bool(for: "testBool") == false)
    }

    @Test("bool returns false for missing key")
    func boolMissingKeyReturnsFalse() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        #expect(repo.bool(for: "missingBoolKey") == false)
    }

    // MARK: - Date round-trip

    @Test("save and date round-trip preserves value")
    func dateRoundTrip() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        repo.save(referenceDate, for: "testDate")
        let retrieved = repo.date(for: "testDate")
        #expect(retrieved != nil)
        // UserDefaults archives Date with second-level precision via NSDate
        #expect(abs((retrieved?.timeIntervalSince1970 ?? 0) - referenceDate.timeIntervalSince1970) < 1.0)
    }

    @Test("date returns nil for missing key")
    func dateMissingKeyReturnsNil() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        #expect(repo.date(for: "missingDateKey") == nil)
    }

    // MARK: - Overwrite

    @Test("save overwrites a previously stored integer")
    func integerOverwrite() {
        let defaults = makeSuitedDefaults()
        let repo = UserDefaultsRepository(defaults: defaults)
        repo.save(100, for: "overwriteKey")
        repo.save(200, for: "overwriteKey")
        #expect(repo.integer(for: "overwriteKey") == 200)
    }
}
