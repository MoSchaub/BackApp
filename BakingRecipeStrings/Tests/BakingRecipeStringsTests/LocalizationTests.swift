// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BakingRecipeStrings

/// The languages `Localizable.xcstrings` provides translations for.
private let shippedLanguages = ["en", "de"]

/// Loads the `<language>.lproj/Localizable.strings` table that the build compiles from
/// `Localizable.xcstrings` into the package's resource bundle.
/// Strings with plural variations are compiled into `Localizable.stringsdict` instead; they are
/// included with their format string (`NSStringLocalizedFormatKey`) as the value.
private func stringsTable(for language: String) throws -> [String: String] {
    let path = try #require(
        Bundle.module.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
        "No Localizable.strings for \(language)"
    )
    let data = try #require(FileManager.default.contents(atPath: path))
    let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    var table = try #require(plist as? [String: String], "Localizable.strings for \(language) is not a string table")

    if let dictPath = Bundle.module.path(forResource: "Localizable", ofType: "stringsdict", inDirectory: nil, forLocalization: language) {
        let dictData = try #require(FileManager.default.contents(atPath: dictPath))
        let dict = try #require(
            try PropertyListSerialization.propertyList(from: dictData, options: [], format: nil) as? [String: [String: Any]],
            "Localizable.stringsdict for \(language) is not a dictionary"
        )
        for (key, entry) in dict {
            table[key] = entry["NSStringLocalizedFormatKey"] as? String ?? ""
        }
    }
    return table
}

/// Formats a localized string of the package as it would read in `language`.
private func localized(_ key: String, in language: String, _ arguments: CVarArg...) throws -> String {
    let path = try #require(Bundle.module.path(forResource: language, ofType: "lproj"), "No \(language).lproj")
    let bundle = try #require(Bundle(path: path))
    let format = bundle.localizedString(forKey: key, value: nil, table: nil)
    return String(format: format, locale: Locale(identifier: language), arguments: arguments)
}

/// `Sources/BakingRecipeStrings` in the package, located relative to this file.
private let packageSourcesURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // BakingRecipeStringsTests
    .deletingLastPathComponent() // Tests
    .deletingLastPathComponent() // package root
    .appendingPathComponent("Sources/BakingRecipeStrings")

/// `Strings.swift` in the package sources.
private let stringsSourceURL = packageSourcesURL.appendingPathComponent("Strings.swift")

/// The String Catalog source, which still carries each translation's review state.
private let stringCatalogURL = packageSourcesURL.appendingPathComponent("Resources/Localizable.xcstrings")

/// The parts of the `.xcstrings` JSON format the tests look at.
private struct StringCatalog: Decodable {
    struct Entry: Decodable {
        var localizations: [String: Localization]?
    }
    struct Localization: Decodable {
        var stringUnit: StringUnit?
    }
    struct StringUnit: Decodable {
        var state: String
        var value: String
    }

    var sourceLanguage: String
    var strings: [String: Entry]
}

private func loadStringCatalog() throws -> StringCatalog {
    try JSONDecoder().decode(StringCatalog.self, from: Data(contentsOf: stringCatalogURL))
}

/// Whether the package sources are on this machine. Xcode Cloud runs tests on a separate
/// machine that only has the built test products, not the repository.
private let sourcesAreAvailable = FileManager.default.fileExists(atPath: stringsSourceURL.path)

/// Every key `Strings.swift` passes to `NSLocalizedString`, read from the source file itself
/// so newly added strings are covered automatically.
private func keysUsedByStrings() throws -> Set<String> {
    let text = try String(contentsOf: stringsSourceURL, encoding: .utf8)
    let regex = try NSRegularExpression(pattern: #"NSLocalizedString\("([^"]+)""#)
    let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
    return Set(matches.compactMap { Range($0.range(at: 1), in: text).map { String(text[$0]) } })
}

/// Format specifiers such as `%@`, `%d` or `%1$@`, in order of appearance.
/// `%%` is a literal percent sign and is skipped.
private func formatSpecifiers(in string: String) throws -> [String] {
    let regex = try NSRegularExpression(pattern: #"%%|%(\d+\$)?[@dDuUxXoOfeEgGcCsSpaAF]"#)
    return regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        .compactMap { Range($0.range, in: string).map { String(string[$0]) } }
        .filter { $0 != "%%" }
}

@Suite("Localization tables")
struct LocalizationTests {

    @Test(
        "Every key used by Strings exists in the table",
        .enabled(if: sourcesAreAvailable, "Needs the package sources, which Xcode Cloud test runners lack"),
        arguments: shippedLanguages
    )
    func everyKeyIsTranslated(language: String) throws {
        let table = try stringsTable(for: language)
        let usedKeys = try keysUsedByStrings()
        try #require(usedKeys.isEmpty == false, "Could not read any keys from Strings.swift")

        let missing = usedKeys.subtracting(table.keys).sorted()
        #expect(missing.isEmpty, "Keys missing from \(language): \(missing)")
    }

    @Test("All tables define the same keys")
    func tablesHaveTheSameKeys() throws {
        let english = try stringsTable(for: "en")
        let german = try stringsTable(for: "de")

        let onlyEnglish = Set(english.keys).subtracting(german.keys).sorted()
        let onlyGerman = Set(german.keys).subtracting(english.keys).sorted()
        #expect(onlyEnglish.isEmpty, "Keys only in en: \(onlyEnglish)")
        #expect(onlyGerman.isEmpty, "Keys only in de: \(onlyGerman)")
    }

    @Test("No translation is empty", arguments: shippedLanguages)
    func noEmptyValues(language: String) throws {
        let table = try stringsTable(for: language)
        let empty = table.filter { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.keys.sorted()
        #expect(empty.isEmpty, "Empty values in \(language): \(empty)")
    }

    @Test("Translations keep the format specifiers of the English string")
    func formatSpecifiersMatch() throws {
        let english = try stringsTable(for: "en")
        let german = try stringsTable(for: "de")

        for (key, englishValue) in english {
            guard let germanValue = german[key] else { continue } // reported by tablesHaveTheSameKeys
            #expect(
                try formatSpecifiers(in: germanValue) == formatSpecifiers(in: englishValue),
                "Format specifiers differ for \(key)"
            )
        }
    }

    @Test(
        "Every catalog entry is translated and reviewed",
        .enabled(if: sourcesAreAvailable, "Needs the package sources, which Xcode Cloud test runners lack"),
        arguments: shippedLanguages
    )
    func catalogIsFullyTranslated(language: String) throws {
        let catalog = try loadStringCatalog()
        try #require(catalog.sourceLanguage == "en")
        try #require(catalog.strings.isEmpty == false, "Localizable.xcstrings contains no strings")

        // Xcode marks new or changed source strings as "new" / "needs_review"; only "translated" is done.
        let unfinished = catalog.strings
            .filter { $0.value.localizations?[language]?.stringUnit?.state != "translated" }
            .keys.sorted()
        #expect(unfinished.isEmpty, "Strings not translated for \(language): \(unfinished)")
    }

    @Test("Localized constants resolve to a translation, not to their key")
    func constantsResolve() {
        // NSLocalizedString falls back to the key itself when it is missing from the table.
        #expect(Strings.noRecipeSelectedHint != "noRecipeSelectedHint")
        #expect(Strings.minutesCount(2) != "minutesCount")
        #expect(Strings.unnamedRecipe != "unnamedRecipe")
        #expect(Strings.EditButton_Done != "EditButton_Done")
    }
}

@Suite("Plural forms")
struct PluralTests {

    @Test("Counted strings pick the plural form of the language", arguments: [
        ("minutesCount", "en", 1, "one minute"),
        ("minutesCount", "en", 0, "0 minutes"),
        ("hoursCount", "de", 1, "eine Stunde"),
        ("hoursCount", "de", 2, "2 Stunden"),
        ("hoursCount", "fr", 0, "0 heure"),
        ("hoursCount", "fr", 2, "2 heures"),
        ("stepsCount", "en", 1, "1 step"),
        ("stepsCount", "fr", 12, "12 étapes"),
    ])
    func integerPlurals(key: String, language: String, count: Int, expected: String) throws {
        #expect(try localized(key, in: language, count) == expected)
    }

    @Test("Decimal counts pick the plural form from the value", arguments: [
        ("en", 1.0, "1", "1 piece"),
        ("en", 1.5, "1.5", "1.5 pieces"),
        ("fr", 1.5, "1,5", "1,5 pièce"),
        ("fr", 2.0, "2", "2 pièces"),
        ("de", 1.0, "1", "1 Stück"),
    ])
    func decimalPlurals(language: String, value: Double, formatted: String, expected: String) throws {
        #expect(try localized("piecesCount", in: language, value, formatted) == expected)
    }
}

@Suite("Static constants")
struct StaticConstantTests {

    @Test("Web links use HTTPS", arguments: [Strings.websiteURL, Strings.privacyPolicyURL, Strings.donateURL])
    func urlsAreSecure(url: URL) {
        #expect(url.scheme == "https")
        #expect(url.host == "heimbaecker.de")
    }

    @Test("Cell reuse identifiers are unique")
    func cellIdentifiersAreUnique() {
        let identifiers = [
            Strings.recipeCell, Strings.detailCell, Strings.plainCell, Strings.tempPickerCell,
            Strings.nameCell, Strings.notesCell, Strings.durationCell, Strings.tempCell,
            Strings.ingredientCell, Strings.addIngredientCell, Strings.substepCell, Strings.amountCell,
            Strings.IngredientTypeCell, Strings.toggleCell, Strings.pickerCell, Strings.timePickerCell,
            Strings.imageCell, Strings.stepCell, Strings.infoStripCell, Strings.infoCell,
            Strings.textFieldCell, Strings.scheduleCell, Strings.switchCell, Strings.kneadingHeatingCell,
            Strings.apperanceCell, Strings.languageCell, Strings.textCell, Strings.kneadingStepCell,
            Strings.endTempCell, Strings.timesCell,
        ]
        #expect(Set(identifiers).count == identifiers.count)
    }
}
