//
//  ProjectSecurityConfigurationTests.swift
//  Focused TimerTests
//

import Foundation
import Testing

@Suite("Project Security Configuration")
struct ProjectSecurityConfigurationTests {

    private var projectDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test("Privacy manifest declares the app-only UserDefaults reason")
    func privacyManifestDeclaresUserDefaultsReason() throws {
        let manifestURL = projectDirectory
            .appendingPathComponent("Focused Timer")
            .appendingPathComponent("PrivacyInfo.xcprivacy")
        let data = try Data(contentsOf: manifestURL)
        let propertyList = try #require(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )

        #expect(propertyList["NSPrivacyTracking"] as? Bool == false)
        #expect((propertyList["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)

        let accessedAPITypes = try #require(
            propertyList["NSPrivacyAccessedAPITypes"] as? [[String: Any]]
        )
        let userDefaultsEntry = try #require(accessedAPITypes.first { entry in
            entry["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults"
        })
        let reasons = try #require(userDefaultsEntry["NSPrivacyAccessedAPITypeReasons"] as? [String])
        #expect(reasons == ["CA92.1"])
    }

    @Test("SwiftLint build phase is sandboxed and dependency-aware")
    func swiftLintBuildPhaseIsHardened() throws {
        let projectFile = projectDirectory
            .appendingPathComponent("Focused Timer.xcodeproj")
            .appendingPathComponent("project.pbxproj")
        let contents = try String(contentsOf: projectFile, encoding: .utf8)

        #expect(!contents.contains("ENABLE_USER_SCRIPT_SANDBOXING = NO;"))
        #expect(contents.contains("ENABLE_USER_SCRIPT_SANDBOXING = YES;"))
        #expect(!contents.contains("alwaysOutOfDate = 1;"))
        #expect(contents.contains("$(DERIVED_FILE_DIR)/swiftlint.log"))
        #expect(contents.contains("$(SRCROOT)/.swiftlint.yml"))
        #expect(!contents.contains("command -v swiftlint"))
    }

    @Test("Xcode Cloud installs a checksum-verified SwiftLint version")
    func xcodeCloudPinsSwiftLint() throws {
        let scriptURL = projectDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("ci_scripts")
            .appendingPathComponent("ci_post_clone.sh")
        let contents = try String(contentsOf: scriptURL, encoding: .utf8)

        #expect(contents.contains("SWIFTLINT_VERSION=\"0.65.0\""))
        #expect(contents.contains("d6cb0aa7a2f5f1ef306fc9e37bcb54dc9a26facc8f7784ac0c3dd3eccf5c6ba6"))
        #expect(contents.contains("portable_swiftlint.zip"))
        #expect(!contents.contains("brew install swiftlint"))
    }
}
