// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BakingRecipeStrings

/// The languages the package ships a `Localizable.strings` table for.
private let shippedLanguages = ["en", "de"]

/// Loads `<language>.lproj/Localizable.strings` from the package's resource bundle.
private func stringsTable(for language: String) throws -> [String: String] {
    let path = try #require(
        Bundle.module.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
        "No Localizable.strings for \(language)"
    )
    let data = try #require(FileManager.default.contents(atPath: path))
    let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    return try #require(plist as? [String: String], "Localizable.strings for \(language) is not a string table")
}

/// `Strings.swift` in the package sources, located relative to this file.
private let stringsSourceURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // BakingRecipeStringsTests
    .deletingLastPathComponent() // Tests
    .deletingLastPathComponent() // package root
    .appendingPathComponent("Sources/BakingRecipeStrings/Strings.swift")

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
private func formatSpecifiers(in string: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: #"%%|%(\d+\$)?[@dDuUxXoOfeEgGcCsSpaAF]"#)
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
                formatSpecifiers(in: germanValue) == formatSpecifiers(in: englishValue),
                "Format specifiers differ for \(key)"
            )
        }
    }

    @Test("Localized constants resolve to a translation, not to their key")
    func constantsResolve() {
        // NSLocalizedString falls back to the key itself when it is missing from the table.
        #expect(Strings.donate_text != "donateText")
        #expect(Strings.donate_text != "donate_text")
        #expect(Strings.unnamedRecipe != "unnamedRecipe")
        #expect(Strings.EditButton_Done != "EditButton_Done")
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
