// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Accessibility identifiers of the controls the UI tests use.
///
/// This file is compiled into both the app and the UI test target,
/// so the tests can find controls without matching localized text.
enum AccessibilityID {

    // MARK: Shared

    /// The name text field of a recipe, step or ingredient
    static let nameField = "nameField"
    /// The navigation bar Done button shown while editing a text field
    static let doneButton = "doneButton"

    // MARK: Recipe list

    static let addRecipeButton = "addRecipeButton"
    static let settingsButton = "settingsButton"

    // MARK: Recipe detail

    static let editRecipeButton = "editRecipeButton"

    // MARK: Edit recipe

    static let saveRecipeButton = "saveRecipeButton"
    static let cancelRecipeButton = "cancelRecipeButton"
    static let cancelRecipeAlert = "cancelRecipeAlert"
    static let recipeQuantityField = "recipeQuantityField"
    static let addStepCell = "addStepCell"

    // MARK: Step detail

    static let stepDurationCell = "stepDurationCell"
    static let stepDurationPicker = "stepDurationPicker"
    static let addIngredientCell = "addIngredientCell"

    // MARK: Ingredient detail

    static let ingredientAmountField = "ingredientAmountField"
    /// The row that shows the ingredient's type and expands the type options
    static let ingredientTypeCell = "ingredientTypeCell"

    /// The option row for an ingredient type, e.g. `ingredientTypeOption.bulkLiquid`
    static func ingredientTypeOption(_ caseName: String) -> String {
        "ingredientTypeOption.\(caseName)"
    }

    // MARK: Settings

    static let closeSettingsButton = "closeSettingsButton"
    static let roomTemperatureCell = "roomTemperatureCell"
    static let aboutCell = "aboutCell"
}
