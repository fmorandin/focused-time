//
//  StubChangelogLoader.swift
//  Focused TimerTests
//
//  Shared ChangelogLoading test double: serves a fixed changelog (or a fixed
//  error) and records how it was called.
//

import Foundation
@testable import Focused_Timer

final class StubChangelogLoader: ChangelogLoading, @unchecked Sendable {

    // MARK: - Private Variables

    private let result: Result<Changelog, ChangelogError>

    // MARK: - Recorded Calls

    private(set) var loadCallCount = 0
    private(set) var lastPreferredLanguages: [String] = []

    // MARK: - Initializers

    init(changelog: Changelog) {
        result = .success(changelog)
    }

    init(error: ChangelogError) {
        result = .failure(error)
    }

    // MARK: - ChangelogLoading

    func loadChangelog(preferredLanguages: [String]) throws -> Changelog {
        loadCallCount += 1
        lastPreferredLanguages = preferredLanguages
        return try result.get()
    }
}
