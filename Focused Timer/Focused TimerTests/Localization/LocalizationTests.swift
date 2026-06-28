import Testing
import Foundation

private final class LocalizationTestsAnchor {}

@Suite("Localization")
struct LocalizationTests {

    /// Add a new BCP 47 language code here when adding localization support.
    private static let supportedLanguages = ["en", "pt-BR"]

    // MARK: - Helpers

    private static func loadStrings(for language: String) throws -> [String: String] {
        let bundle = Bundle(for: LocalizationTestsAnchor.self)
        let lprojDirectory = "\(language).lproj"
        guard let stringsPath = bundle.path(
            forResource: "Localizable",
            ofType: "strings",
            inDirectory: lprojDirectory
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }
        guard let dict = NSDictionary(contentsOfFile: stringsPath) as? [String: String] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return dict
    }

    // MARK: - Tests

    @Test("Catalog loads successfully")
    func catalogLoadsSuccessfully() throws {
        let strings = try Self.loadStrings(for: "en")
        #expect(!strings.isEmpty)
    }

    @Test("All keys have translation", arguments: supportedLanguages)
    func allKeysHaveTranslation(language: String) throws {
        let strings = try Self.loadStrings(for: language)
        for (entryKey, value) in strings {
            #expect(
                !value.isEmpty,
                "Key \"\(entryKey)\" has an empty value for language \"\(language)\""
            )
        }
    }
}
