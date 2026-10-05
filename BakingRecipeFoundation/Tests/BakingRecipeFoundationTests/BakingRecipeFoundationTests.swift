// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest
@testable import BakingRecipeFoundation
@testable import GRDB
@testable import BakingRecipeStrings

final class BakingRecipeFoundationTests: XCTestCase {

    // Helper to run assertions under a specific locale/language and restore afterwards
    private func withLocale(_ localeIdentifier: String, languageCode: String, _ body: () -> Void) {
        let defaults = UserDefaults.standard
        MeasurementFormatting.localeOverride = Locale(identifier: localeIdentifier)
        let previousLanguages = defaults.array(forKey: "AppleLanguages")
        let previousLocale = defaults.string(forKey: "AppleLocale")
        defaults.set([languageCode], forKey: "AppleLanguages")
        defaults.set(localeIdentifier, forKey: "AppleLocale")
        defaults.synchronize()
        defer {
            MeasurementFormatting.localeOverride = nil
            if let previousLanguages = previousLanguages {
                defaults.set(previousLanguages, forKey: "AppleLanguages")
            } else {
                defaults.removeObject(forKey: "AppleLanguages")
            }
            if let previousLocale = previousLocale {
                defaults.set(previousLocale, forKey: "AppleLocale")
            } else {
                defaults.removeObject(forKey: "AppleLocale")
            }
            defaults.synchronize()
        }
        body()
    }

    func test_TempMeasurementFormatter() {
        // Test both en_US (Fahrenheit) and de_DE (Celsius) formatting/values
        withLocale("en_US", languageCode: "en") {
            var measurement = Measurement(value: 20434.16746454, unit: UnitTemperature.celsius)
            XCTAssertEqual(measurement.formatted, "36813.5°F")
            XCTAssertEqual(measurement.localizedValue, "36813.5")

            measurement = Measurement(value: 20.0, unit: UnitTemperature.celsius)
            XCTAssertEqual(measurement.formatted, "68°F")
            XCTAssertEqual(measurement.localizedValue, "68")
        }

        withLocale("de_DE", languageCode: "de") {
            var measurement = Measurement(value: 20434.16746454, unit: UnitTemperature.celsius)
            XCTAssertEqual(measurement.formatted, "20434,2 °C")
            XCTAssertEqual(measurement.localizedValue, "20434,2")

            measurement = Measurement(value: 20.0, unit: UnitTemperature.celsius)
            XCTAssertEqual(measurement.formatted, "20 °C")
            XCTAssertEqual(measurement.localizedValue, "20")
        }
    }

    func test_formattedEndTemp() {
        let recipeExample = Recipe.example
        var step = recipeExample.stepIngredients.first!.step

        // When end temp is disabled, it mirrors formattedTemp(roomTemp:) and the stored property is nil
        withLocale("en_US", languageCode: "en") {
            step.endTempEnabled = false
            XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), step.formattedTemp(roomTemp: 21))
            XCTAssertEqual(step.formattedEndTemp, nil)

            step.endTempEnabled = true
            XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), "68°F")
            XCTAssertEqual(step.formattedEndTemp, "68°F")
        }

        withLocale("de_DE", languageCode: "de") {
            step.endTempEnabled = false
            XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), step.formattedTemp(roomTemp: 21))
            XCTAssertEqual(step.formattedEndTemp, nil)

            step.endTempEnabled = true
            XCTAssertEqual(step.formattedEndTemp(roomTemp: 21), "20 °C")
            XCTAssertEqual(step.formattedEndTemp, "20 °C")
        }
    }

    func test_formattedTemp() {
        let recipeExample = Recipe.example
        var step = recipeExample.stepIngredients.first!.step

        withLocale("en_US", languageCode: "en") {
            step.temperature = nil
            XCTAssertEqual(step.formattedTemp(roomTemp: 21), "69.8°F")

            step.temperature = 20
            XCTAssertEqual(step.formattedTemp(roomTemp: 21), "68°F")
        }

        withLocale("de_DE", languageCode: "de") {
            step.temperature = nil
            XCTAssertEqual(step.formattedTemp(roomTemp: 21), "21 °C")

            step.temperature = 20
            XCTAssertEqual(step.formattedTemp(roomTemp: 21), "20 °C")
        }
    }

    func test_RecipeFormattedName() {
        var recipe = Recipe(name: "", number: 0)

        let test = "test"
        recipe.name = test
        XCTAssertEqual(recipe.formattedName, test)

        recipe.name = "     " + test + " \n"
        XCTAssertEqual(recipe.formattedName, test)

        recipe.name = ""
        XCTAssertEqual(recipe.formattedName, Strings.unnamedRecipe)
    }

    func test_StepFormattedName() {
        var step = Step(recipeId: 0, number: 0)

        let test = "test"
        step.name = test
        XCTAssertEqual(step.formattedName, test)

        step.name = test + " \n"
        XCTAssertEqual(step.formattedName, test)

        step.name = ""
        XCTAssertEqual(step.formattedName, Strings.unnamedStep)
    }

    func test_IngredientFormattedName() {
        var ingredient = Ingredient(stepId: 0, number: 0)

        let test = "test"
        ingredient.name = test
        XCTAssertEqual(ingredient.formattedName, test)

        ingredient.name = "   " + test + "  \n"
        XCTAssertEqual(ingredient.formattedName, test)

        ingredient.name = ""
        XCTAssertEqual(ingredient.formattedName, Strings.unnamedIngredient)
    }

    //test formatted duration
    func test_StepFormattedDuration() {
        var step = Step(recipeId: 0, number: 0)

        XCTAssertEqual(step.formattedDuration, Strings.one + " " + Strings.minute)

        step.duration = 3600
        XCTAssertEqual(step.formattedDuration, Strings.one + " " + Strings.hour )

        step.duration = 3660
        XCTAssertEqual(step.formattedDuration, Strings.one + " " + Strings.hour + " " + Strings.one + " " + Strings.minute)

        step.duration = 4000
        XCTAssertEqual(step.formattedDuration, Strings.one + " " + Strings.hour + " " + "6 " + Strings.minutes)

        step.duration = 7560
        XCTAssertEqual(step.formattedDuration, "2 " + Strings.hours + " " + "6 " + Strings.minutes)

        step.duration = 60
        XCTAssertEqual(step.formattedDuration, Strings.one + " " + Strings.minute)

        step.duration = 41
        XCTAssertEqual(step.formattedDuration, "0 " + Strings.minutes)

        step.duration = 130
        XCTAssertEqual(step.formattedDuration, "2 \(Strings.minutes)")
    }
    
    func testFormattedDuration() {
        var duration = 1
        XCTAssertEqual(duration.formattedDuration,Strings.one + " " + Strings.minute)

        duration = 60
        XCTAssertEqual(duration.formattedDuration, Strings.one + " " + Strings.hour )

        duration = 61
        XCTAssertEqual(duration.formattedDuration, Strings.one + " " + Strings.hour + " " + Strings.one + " " + Strings.minute)

        duration = 66
        XCTAssertEqual(duration.formattedDuration, Strings.one + " " + Strings.hour + " " + "6 " + Strings.minutes)

        duration = 126
        XCTAssertEqual(duration.formattedDuration, "2 " + Strings.hours + " " + "6 " + Strings.minutes)

        duration = 1
        XCTAssertEqual(duration.formattedDuration, Strings.one + " " + Strings.minute)

        duration = 0
        XCTAssertEqual(duration.formattedDuration, "0 " + Strings.minutes)

        duration = 2
        XCTAssertEqual(duration.formattedDuration, "2 \(Strings.minutes)")
    }
    
    func testCompactFormattedDuration() {
        var duration = 1
        XCTAssertEqual(duration.compactForamttedDuration,Strings.one + " " + Strings.minute)

        duration = 60
        XCTAssertEqual(duration.compactForamttedDuration, Strings.one + " " + Strings.hour )

        duration = 61
        XCTAssertEqual(duration.compactForamttedDuration, "1.02 " + Strings.hours)

        duration = 66
        XCTAssertEqual(duration.compactForamttedDuration, "1.1 " + Strings.hours)

        duration = 126
        XCTAssertEqual(duration.compactForamttedDuration, "2.1 " + Strings.hours)

        duration = 1
        XCTAssertEqual(duration.compactForamttedDuration, Strings.one + " " + Strings.minute)

        duration = 0
        XCTAssertEqual(duration.compactForamttedDuration, "0 " + Strings.minutes)

        duration = 2
        XCTAssertEqual(duration.compactForamttedDuration, "2 \(Strings.minutes)")
    }

    static var allTests = [
        ("test_TempMeasurementFormatter", test_TempMeasurementFormatter)
    ]
}

