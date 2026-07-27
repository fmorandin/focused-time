import Testing
import Foundation
@testable import Focused_Timer

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

    // MARK: - What's New

    private static let whatsNewKeys = [
        "whatsNewModalTitle",
        "whatsNewVersionLabel",
        "whatsNewDismissButton",
        "whatsNewSeeAllChanges",
        "whatsNewEntryKindAdded",
        "whatsNewEntryKindImproved",
        "whatsNewEntryKindFixed",
        "whatsNewEntryKindOther",
        "changelogSettingsRow",
        "changelogNavigationTitle",
        "changelogEmptyMessage",
        "accLabelWhatsNewDismissButton",
        "accLabelWhatsNewSeeAllButton",
        "accLabelChangelogSettingsRow"
    ]

    @Test("What's New keys exist and are translated", arguments: supportedLanguages)
    func whatsNewKeysAreTranslated(language: String) throws {
        let strings = try Self.loadStrings(for: language)
        for key in Self.whatsNewKeys {
            let value = try #require(strings[key], "Key \"\(key)\" is missing for language \"\(language)\"")
            #expect(!value.isEmpty, "Key \"\(key)\" has an empty value for language \"\(language)\"")
        }
    }

    /// `BundleChangelogLoader.supportedLanguages` must keep listing every language here,
    /// and vice versa — adding a language means adding a `Changelog_<language>.json`
    /// file *and* a case in this list.
    @Test("Every supported language has a changelog resource")
    func supportedLanguagesMatchChangelogLoader() {
        #expect(Set(Self.supportedLanguages) == Set(BundleChangelogLoader.supportedLanguages))
    }
}
