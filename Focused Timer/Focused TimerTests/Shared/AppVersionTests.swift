//
//  AppVersionTests.swift
//  Focused TimerTests
//
//  The reason this type exists is that "2.10.0" < "2.9.0" as a string but not
//  as a version, so ordering is what most of these tests are about.
//

import Testing
@testable import Focused_Timer

@Suite("AppVersion Tests", .serialized)
struct AppVersionTests {

    // MARK: - Parsing

    @Test("Parses a full major.minor.patch string")
    func parsesFullVersion() throws {
        let version = try #require(AppVersion(versionString: "2.1.3"))

        #expect(version.major == 2)
        #expect(version.minor == 1)
        #expect(version.patch == 3)
    }

    @Test("A major-only string defaults minor and patch to zero")
    func parsesMajorOnlyVersion() throws {
        let version = try #require(AppVersion(versionString: "2"))
        #expect(version == AppVersion(major: 2, minor: 0, patch: 0))
    }

    @Test("A major.minor string defaults patch to zero")
    func parsesMajorMinorVersion() throws {
        let version = try #require(AppVersion(versionString: "2.1"))
        #expect(version == AppVersion(major: 2, minor: 1, patch: 0))
    }

    @Test("Surrounding whitespace is ignored")
    func parsesPaddedVersion() throws {
        let version = try #require(AppVersion(versionString: "  2.1.0 "))
        #expect(version == AppVersion(major: 2, minor: 1, patch: 0))
    }

    @Test("Rejects strings that are not versions", arguments: [
        "", "   ", "abc", "2.x.0", "2.0.0.1", "-1.0.0", "2..0", "2.", "v2.1.0", "2.1.0-beta"
    ])
    func rejectsInvalidVersions(text: String) {
        #expect(AppVersion(versionString: text) == nil)
    }

    // MARK: - Comparison

    @Test("Compares minor components numerically, not lexicographically")
    func comparesMinorNumerically() throws {
        let higher = try #require(AppVersion(versionString: "2.10.0"))
        let lower = try #require(AppVersion(versionString: "2.9.0"))

        #expect(higher > lower)
    }

    @Test("Compares patch components numerically, not lexicographically")
    func comparesPatchNumerically() throws {
        let higher = try #require(AppVersion(versionString: "2.0.10"))
        let lower = try #require(AppVersion(versionString: "2.0.9"))

        #expect(higher > lower)
    }

    @Test("Major version wins over minor and patch")
    func comparesMajorFirst() throws {
        let higher = try #require(AppVersion(versionString: "2.0.0"))
        let lower = try #require(AppVersion(versionString: "1.9.9"))

        #expect(higher > lower)
    }

    @Test("Equal versions compare equal and hash equally")
    func comparesEqualVersions() throws {
        let left = try #require(AppVersion(versionString: "2.1"))
        let right = try #require(AppVersion(versionString: "2.1.0"))

        #expect(left == right)
        #expect(left.hashValue == right.hashValue)
    }

    @Test("Sorting produces semantic order")
    func sortsSemantically() {
        let versions = ["2.9.0", "10.0.0", "2.10.0", "1.0.0", "2.1.0"]
            .compactMap { AppVersion(versionString: $0) }
            .sorted()

        #expect(versions.map(\.description) == ["1.0.0", "2.1.0", "2.9.0", "2.10.0", "10.0.0"])
    }

    // MARK: - Description

    @Test("Description round-trips through the parser")
    func descriptionRoundTrips() throws {
        let original = try #require(AppVersion(versionString: "2.1"))
        let reparsed = try #require(AppVersion(versionString: original.description))

        #expect(original.description == "2.1.0")
        #expect(reparsed == original)
    }
}
