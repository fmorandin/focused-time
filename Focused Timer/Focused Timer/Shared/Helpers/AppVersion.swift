//
//  AppVersion.swift
//  Focused Timer
//
//  A semantic `major.minor.patch` version used to decide whether the
//  "What's New" screen should be presented after an app update.
//

import Foundation

/// Comparison is numeric per component, so `2.10.0` is correctly greater than
/// `2.9.0` — something a plain string comparison gets wrong.
struct AppVersion: Comparable, Hashable, Sendable, CustomStringConvertible {

    // MARK: - Properties

    let major: Int
    let minor: Int
    let patch: Int

    // MARK: - Computed Variables

    var description: String {
        "\(self.major).\(self.minor).\(self.patch)"
    }

    // MARK: - Initializers

    init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Parses `"2"`, `"2.1"` and `"2.1.0"`.
    /// Returns `nil` for empty, non-numeric, negative or over-long strings.
    init?(versionString: String) {

        let trimmed = versionString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let components = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...3).contains(components.count) else { return nil }

        var numbers = [Int]()
        for component in components {
            // `Int("+1")` succeeds, so reject anything that is not plain digits.
            guard component.allSatisfy({ $0.isNumber }), let number = Int(component) else { return nil }
            numbers.append(number)
        }

        self.init(
            major: numbers[0],
            minor: numbers.count > 1 ? numbers[1] : 0,
            patch: numbers.count > 2 ? numbers[2] : 0
        )
    }

    // MARK: - Comparable

    static func < (leftHand: AppVersion, rightHand: AppVersion) -> Bool {
        (leftHand.major, leftHand.minor, leftHand.patch) < (rightHand.major, rightHand.minor, rightHand.patch)
    }
}
