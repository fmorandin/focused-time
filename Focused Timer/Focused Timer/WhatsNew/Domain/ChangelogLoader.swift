//
//  ChangelogLoader.swift
//  Focused Timer
//
//  Resolves and decodes the bundled changelog file for the language the rest
//  of the UI is running in. Resource access sits behind `ChangelogDataProviding`
//  so the resolution and decoding logic can be unit-tested without a bundle.
//

import Foundation
import os

// MARK: - Errors

enum ChangelogError: Error, Equatable {

    case resourceNotFound
    case decodingFailed
    case unsupportedSchema(Int)
}

// MARK: - Protocols

/// Abstracts reading a JSON resource so tests can serve payloads from memory.
protocol ChangelogDataProviding: Sendable {

    /// Returns the raw contents of `<resourceName>.json`, or `nil` when absent.
    func data(forResource resourceName: String) -> Data?
}

protocol ChangelogLoading: Sendable {

    /// Loads the changelog written in the first language we support out of
    /// `preferredLanguages`, falling back to English.
    func loadChangelog(preferredLanguages: [String]) throws -> Changelog
}

extension ChangelogLoading {

    /// Uses the same language list the string catalog resolves against, so the
    /// changelog is always written in the language the rest of the UI is using.
    func loadChangelog() throws -> Changelog {
        try self.loadChangelog(preferredLanguages: Bundle.main.preferredLocalizations)
    }
}

// MARK: - BundleChangelogDataProvider

/// Reads the changelog JSON files shipped inside the app bundle.
struct BundleChangelogDataProvider: ChangelogDataProviding, @unchecked Sendable {

    // MARK: - Private Variables

    private let bundle: Bundle

    // MARK: - Initializer

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    // MARK: - ChangelogDataProviding

    func data(forResource resourceName: String) -> Data? {
        guard let resourceURL = self.bundle.url(forResource: resourceName, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: resourceURL)
    }
}

// MARK: - BundleChangelogLoader

struct BundleChangelogLoader: ChangelogLoading {

    // MARK: - Constants

    /// Every language that ships a `Changelog_<language>.json` file.
    /// Keep this in sync with `LocalizationTests.supportedLanguages`.
    static let supportedLanguages = ["en", "pt-BR"]

    static let fallbackLanguage = "en"
    static let resourcePrefix = "Changelog_"

    // MARK: - Private Variables

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: BundleChangelogLoader.self)
    )

    private let dataProvider: any ChangelogDataProviding

    // MARK: - Initializer

    init(dataProvider: any ChangelogDataProviding = BundleChangelogDataProvider()) {
        self.dataProvider = dataProvider
    }

    // MARK: - Static Methods

    /// Picks the best supported language for `preferredLanguages`: an exact match
    /// first (`pt-BR`), then a match on the language subtag alone (`pt-PT` → `pt-BR`),
    /// then English.
    static func resourceName(for preferredLanguages: [String]) -> String {

        for language in preferredLanguages {

            if let exactMatch = Self.supportedLanguages.first(where: {
                $0.caseInsensitiveCompare(language) == .orderedSame
            }) {
                return Self.resourcePrefix + exactMatch
            }

            let subtag = Self.languageSubtag(of: language)
            if let subtagMatch = Self.supportedLanguages.first(where: {
                Self.languageSubtag(of: $0).caseInsensitiveCompare(subtag) == .orderedSame
            }) {
                return Self.resourcePrefix + subtagMatch
            }
        }

        return Self.resourcePrefix + Self.fallbackLanguage
    }

    private static func languageSubtag(of language: String) -> String {
        String(language.split(separator: "-").first ?? Substring(language))
    }

    // MARK: - ChangelogLoading

    func loadChangelog(preferredLanguages: [String]) throws -> Changelog {

        let resourceName = Self.resourceName(for: preferredLanguages)
        let fallbackName = Self.resourcePrefix + Self.fallbackLanguage

        guard let payload = self.dataProvider.data(forResource: resourceName)
                ?? self.dataProvider.data(forResource: fallbackName) else {
            Self.logger.error("📄 No changelog resource found for \(resourceName).")
            throw ChangelogError.resourceNotFound
        }

        let changelog: Changelog
        do {
            changelog = try JSONDecoder().decode(Changelog.self, from: payload)
        } catch {
            Self.logger.error("📄 Failed to decode \(resourceName): \(error.localizedDescription)")
            throw ChangelogError.decodingFailed
        }

        guard changelog.schemaVersion == Changelog.supportedSchemaVersion else {
            Self.logger.error("📄 Unsupported changelog schema \(changelog.schemaVersion).")
            throw ChangelogError.unsupportedSchema(changelog.schemaVersion)
        }

        return changelog
    }
}
