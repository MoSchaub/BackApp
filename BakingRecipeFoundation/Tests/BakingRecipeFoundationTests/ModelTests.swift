// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BakingRecipeFoundation
import BakingRecipeStrings

@Suite("Recipe")
struct RecipeModelTests {

    @Test("A new recipe starts with sensible defaults")
    func defaults() {
        let recipe = Recipe(name: "Brot", number: 3)
        #expect(recipe.id == nil)
        #expect(recipe.name == "Brot")
        #expect(recipe.info.isEmpty)
        #expect(recipe.isFavorite == false)
        #expect(recipe.difficulty == .easy)
        #expect(recipe.inverted == false)
        #expect(recipe.times == 1)
        #expect(recipe.imageData == nil)
        #expect(recipe.number == 3)
    }

    @Test("formattedName trims whitespace and falls back to a placeholder", arguments: [
        ("test", "test"),
        ("     test \n", "test"),
        ("", Strings.unnamedRecipe),
        ("   ", Strings.unnamedRecipe),
        (" \n\t", Strings.unnamedRecipe),
    ])
    func formattedName(name: String, expected: String) {
        let recipe = Recipe(name: name, number: 0)
        #expect(recipe.formattedName == expected)
    }

    @Test("timesText uses the singular only for exactly one piece", arguments: [
        (Decimal(1), "1 \(Strings.piece)"),
        (Decimal(2), "2 \(Strings.pieces)"),
        (Decimal(12), "12 \(Strings.pieces)"),
    ])
    func timesText(times: Decimal, expected: String) {
        var recipe = Recipe(number: 0)
        recipe.times = times
        #expect(recipe.timesText == expected)
    }

    @Test("timesText without a value reads as one piece")
    func timesTextWithoutValue() {
        var recipe = Recipe(number: 0)
        recipe.times = nil
        #expect(recipe.timesText == "1 \(Strings.piece)")
    }

    @Test("Setting timesText parses whole numbers and clears anything else", arguments: [
        ("4", Decimal?.some(4)),
        ("0", Decimal?.some(0)),
        ("abc", nil),
        ("", nil),
        ("2.5", nil),
    ])
    func settingTimesText(text: String, expected: Decimal?) {
        var recipe = Recipe(number: 0)
        recipe.timesText = text
        #expect(recipe.times == expected)
    }

    @Test(
        "timesTextWithIndivialMass divides the mass by the number of pieces",
        .enabled(if: mainBundleLanguage == "en", "Output depends on the main bundle's language")
    )
    func timesTextWithIndividualMass() {
        var recipe = Recipe(number: 0)
        recipe.times = 4
        #expect(recipe.timesTextWithIndivialMass(with: 1000) == "4 \(Strings.pieces), 250.0 g each")
    }

    @Test("neutralizedForExport clears personal state and keeps the content")
    func neutralizedForExport() {
        var recipe = Recipe(name: "Brot", number: 2)
        recipe.isFavorite = true
        recipe.inverted = true
        recipe.info = "info"
        recipe.difficulty = .hard

        let neutralized = recipe.neutralizedForExport()
        #expect(neutralized.isFavorite == false)
        #expect(neutralized.inverted == false)
        #expect(neutralized.name == recipe.name)
        #expect(neutralized.info == recipe.info)
        #expect(neutralized.difficulty == recipe.difficulty)
        #expect(neutralized.number == recipe.number)
    }

    @Test("Recipes survive a JSON round trip")
    func codableRoundTrip() throws {
        var recipe = Recipe(name: "Brot", number: 1)
        recipe.id = 7
        recipe.info = "info"
        recipe.isFavorite = true
        recipe.difficulty = .medium
        recipe.times = 3
        recipe.date = Date(timeIntervalSince1970: 1_700_000_000)
        recipe.imageData = Data([0x01, 0x02])

        let decoded = try JSONDecoder().decode(Recipe.self, from: JSONEncoder().encode(recipe))
        #expect(decoded == recipe)
    }

    @Test("The bundled examples are internally consistent")
    func examples() {
        let example = Recipe.example
        #expect(example.recipe.name == "Sauerteigcracker")
        #expect(example.stepIngredients.map(\.step.name) == ["Mischen", "Backen"])
        #expect(example.stepIngredients[0].ingredients.map(\.mass).reduce(0, +) == 245)
        #expect(example.stepIngredients[1].ingredients.isEmpty)

        let complex = Recipe.complexExample(number: 4)
        #expect(complex.recipe.number == 4)
        #expect(complex.stepIngredients.allSatisfy { $0.step.recipeId == 4 })
        #expect(complex.stepIngredients[1].step.superStepId == 1)

        let multilayer = Recipe.multilayerSubstepExample(number: 2)
        #expect(multilayer.stepIngredients.count == 7)
        #expect(multilayer.stepIngredients.filter { $0.step.superStepId == nil }.map(\.step.name) == ["Schritt", "s2"])
    }
}

@Suite("Step")
struct StepModelTests {

    @Test("The initializer stores every argument")
    func initializer() {
        let step = Step(name: "Kneten", duration: 600, temperature: 24, notes: "langsam", isKneadingStep: true, recipeId: 5, number: 2)
        #expect(step.id == nil)
        #expect(step.name == "Kneten")
        #expect(step.duration == 600)
        #expect(step.temperature == 24)
        #expect(step.notes == "langsam")
        #expect(step.isKneadingStep)
        #expect(step.recipeId == 5)
        #expect(step.superStepId == nil)
        #expect(step.endTemp == nil)
        #expect(step.number == 2)
    }

    @Test("Defaults: one minute, room temperature, not a kneading step")
    func defaults() {
        let step = Step(recipeId: 1, number: 0)
        #expect(step.duration == 60)
        #expect(step.temperature == nil)
        #expect(step.notes.isEmpty)
        #expect(step.isKneadingStep == false)
    }

    @Test("formattedName trims whitespace and falls back to a placeholder", arguments: [
        ("test", "test"),
        ("test \n", "test"),
        ("", Strings.unnamedStep),
        (" \n", Strings.unnamedStep),
    ])
    func formattedName(name: String, expected: String) {
        let step = Step(name: name, recipeId: 0, number: 0)
        #expect(step.formattedName == expected)
    }

    @Test("Enabling the end temperature starts from the step temperature", arguments: [
        (Double?.none, 20.0), (Double?.some(26), 26.0),
    ])
    func enablingEndTemp(temperature: Double?, expectedEndTemp: Double) {
        var step = Step(temperature: temperature, recipeId: 0, number: 0)
        #expect(step.endTempEnabled == false)

        step.endTempEnabled = true
        #expect(step.endTempEnabled)
        #expect(step.endTemp == expectedEndTemp)

        step.endTempEnabled = false
        #expect(step.endTemp == nil)
    }

    @Test("Setting endTemp directly enables it")
    func settingEndTemp() {
        var step = Step(recipeId: 0, number: 0)
        step.endTemp = 5
        #expect(step.endTempEnabled)
    }

    @Test("Steps survive a JSON round trip")
    func codableRoundTrip() throws {
        var step = Step(name: "Gare", duration: 3600, temperature: 28, notes: "abgedeckt", isKneadingStep: true, recipeId: 3, number: 1)
        step.id = 9
        step.superStepId = 4
        step.endTemp = 24

        let decoded = try JSONDecoder().decode(Step.self, from: JSONEncoder().encode(step))
        #expect(decoded == step)
    }
}

@Suite("Ingredient")
struct IngredientModelTests {

    @Test("formattedName trims whitespace and falls back to a placeholder", arguments: [
        ("test", "test"),
        ("   test  \n", "test"),
        ("", Strings.unnamedIngredient),
        ("   ", Strings.unnamedIngredient),
        ("\n", Strings.unnamedIngredient),
    ])
    func formattedName(name: String, expected: String) {
        // Passed through the initializer so name-based type detection does not run.
        let ingredient = Ingredient(stepId: 0, name: name, number: 0)
        #expect(ingredient.formattedName == expected)
    }

    @Test("The type is stored as its heat capacity", arguments: Ingredient.Style.allCases)
    func typeRoundTrip(style: Ingredient.Style) {
        var ingredient = Ingredient(stepId: 0, number: 0)
        ingredient.type = style
        #expect(ingredient.type == style)
        #expect(ingredient.massCProduct == 0)

        ingredient.mass = 10
        #expect(ingredient.massCProduct == 10 * style.rawValue)
    }

    @Test("An unknown heat capacity reads as .other")
    func unknownHeatCapacity() throws {
        let json = #"{"name":"x","mass":1,"c":42,"stepId":0,"number":0}"#
        let ingredient = try JSONDecoder().decode(Ingredient.self, from: Data(json.utf8))
        #expect(ingredient.type == .other)
    }

    @Test("Every style has a distinct, localized name")
    func styleNames() {
        let names = Ingredient.Style.allCases.map(\.name)
        #expect(Set(names).count == names.count)
        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Ingredient.Style.flour.name == Strings.flour)
    }

    @Test("massCTempProduct uses the room temperature unless the ingredient has its own")
    func massCTempProduct() {
        var water = Ingredient(stepId: 0, name: "Wasser", amount: 100, type: .bulkLiquid, number: 0)
        #expect(water.massCTempProduct(roomTemp: 20) == 100 * Ingredient.Style.bulkLiquid.rawValue * 20)

        water.temperature = 35
        #expect(water.massCTempProduct(roomTemp: 20) == 100 * Ingredient.Style.bulkLiquid.rawValue * 35)
    }

    @Test(
        "Renaming detects flour and liquids from English names",
        .enabled(if: mainBundleLanguage == "en", "Detection uses the main bundle's language"),
        arguments: [
            ("Rye flour", Ingredient.Style.flour),
            ("Whole grain grist", .flour),
            ("Water", .bulkLiquid),
            ("whole milk", .bulkLiquid),
            ("Olive oil", .bulkLiquid),
            ("Salt", .ta200), // unrelated names keep the previous type
        ]
    )
    func autoDetectEnglish(name: String, expected: Ingredient.Style) {
        var ingredient = Ingredient(stepId: 0, type: .ta200, number: 0)
        ingredient.name = name
        #expect(ingredient.type == expected)
    }

    @Test(
        "Renaming detects flour and liquids from German names",
        .enabled(if: mainBundleLanguage == "de", "Detection uses the main bundle's language"),
        arguments: [
            ("Weizenmehl 550", Ingredient.Style.flour),
            ("Roggenschrot", .flour),
            ("RVKM", .flour),
            ("Wasser", .bulkLiquid),
            ("Vollmilch", .bulkLiquid),
            ("Salz", .ta200),
        ]
    )
    func autoDetectGerman(name: String, expected: Ingredient.Style) {
        var ingredient = Ingredient(stepId: 0, type: .ta200, number: 0)
        ingredient.name = name
        #expect(ingredient.type == expected)
    }

    @Test("Ingredients survive a JSON round trip")
    func codableRoundTrip() throws {
        var ingredient = Ingredient(stepId: 2, name: "Wasser", amount: 350, type: .bulkLiquid, number: 1)
        ingredient.id = 11
        ingredient.temperature = 30

        let decoded = try JSONDecoder().decode(Ingredient.self, from: JSONEncoder().encode(ingredient))
        #expect(decoded == ingredient)
        #expect(decoded.type == .bulkLiquid)
    }
}

@Suite("Small helpers")
struct HelperTests {

    @Test("Difficulty raw values are stable because they are persisted")
    func difficultyRawValues() {
        #expect(Difficulty.allCases.map(\.rawValue) == [0, 1, 2])
        #expect(Difficulty(rawValue: 3) == nil)
    }

    @Test("Dictionary.append inserts and overwrites")
    func dictionaryAppend() {
        var dictionary = ["a": 1]
        dictionary.append(2, forKey: "b")
        dictionary.append(3, forKey: "a")
        #expect(dictionary == ["a": 3, "b": 2])

        dictionary.append(contentsOf: ["b": 20, "c": 30])
        #expect(dictionary == ["a": 3, "b": 20, "c": 30])

        dictionary.append(contentsOf: [:])
        #expect(dictionary.count == 3)
    }
}
