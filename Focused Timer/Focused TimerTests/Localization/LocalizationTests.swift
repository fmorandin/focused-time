import Testing
import Foundation

@Suite("Localization")
struct LocalizationTests {

    /// Add a new BCP 47 language code here when adding localization support.
    private static let supportedLanguages = ["en", "pt-BR"]

    // MARK: - Catalog models

    private struct StringUnit: Decodable {
        let state: String
        let value: String
    }

    private struct Localization: Decodable {
        let stringUnit: StringUnit?
    }

    private struct CatalogEntry: Decodable {
        let localizations: [String: Localization]?
    }

    private struct Catalog: Decodable {
        let strings: [String: CatalogEntry]
    }

    // MARK: - Helpers

    private static func loadEntries() throws -> [String: CatalogEntry] {
        let fileURL = URL(fileURLWithPath: #filePath)
        let catalogURL = fileURL
            .deletingLastPathComponent()  // LocalizationTests.swift → Localization/
            .deletingLastPathComponent()  // Localization/ → Focused TimerTests/
            .deletingLastPathComponent()  // Focused TimerTests/ → Focused Timer/ (project parent)
            .appendingPathComponent("Focused Timer/Shared/Constants/Localizable.xcstrings")
        let data = try Data(contentsOf: catalogURL)
        return try JSONDecoder().decode(Catalog.self, from: data).strings
    }

    // MARK: - Tests

    @Test("Catalog loads successfully")
    func catalogLoadsSuccessfully() throws {
        let entries = try Self.loadEntries()
        #expect(!entries.isEmpty)
    }

    @Test("All keys have translation", arguments: supportedLanguages)
    func allKeysHaveTranslation(language: String) throws {
        let entries = try Self.loadEntries()
        for (entryKey, entry) in entries {
            guard let localizations = entry.localizations else { continue }
            guard let localization = localizations[language] else {
                Issue.record("Key \"\(entryKey)\" has no entry for language \"\(language)\"")
                continue
            }
            guard let stringUnit = localization.stringUnit else { continue }
            #expect(
                !stringUnit.value.isEmpty,
                "Key \"\(entryKey)\" has an empty value for language \"\(language)\""
            )
        }
    }
}
