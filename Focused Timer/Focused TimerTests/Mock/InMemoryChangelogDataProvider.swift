//
//  InMemoryChangelogDataProvider.swift
//  Focused TimerTests
//
//  Serves changelog payloads from a dictionary so language resolution and
//  decoding can be tested without touching a bundle.
//

import Foundation
@testable import Focused_Timer

final class InMemoryChangelogDataProvider: ChangelogDataProviding, @unchecked Sendable {

    // MARK: - Private Variables

    private let payloads: [String: Data]

    // MARK: - Recorded Calls

    private(set) var requestedResources: [String] = []

    // MARK: - Initializers

    init(payloads: [String: Data]) {
        self.payloads = payloads
    }

    convenience init(jsonByResource: [String: String]) {
        self.init(payloads: jsonByResource.mapValues { Data($0.utf8) })
    }

    // MARK: - ChangelogDataProviding

    func data(forResource resourceName: String) -> Data? {
        requestedResources.append(resourceName)
        return payloads[resourceName]
    }
}
