// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Accessibility identifiers of the controls the UI tests use.
///
/// Lives in BakingRecipeStrings so the app and the UI tests share one definition and
/// the tests can find controls without matching localized text.
/// These are identifiers, not user-facing text, so they are not localized.
public enum AccessibilityID {

    // MARK: Shared

    /// The name text field of a recipe, step or ingredient
    public static let nameField = "nameField"
    /// The navigation bar Done button shown while editing a text field
    public static let doneButton = "doneButton"

    // MARK: Recipe list

    public static let addRecipeButton = "addRecipeButton"
    public static let settingsButton = "settingsButton"

    // MARK: Recipe detail

    public static let editRecipeButton = "editRecipeButton"

    // MARK: Schedule form

    /// The OK button that creates the schedule (iOS 26 shows it as a checkmark labelled "Done")
    public static let confirmScheduleButton = "confirmScheduleButton"

    // MARK: Edit recipe

    public static let saveRecipeButton = "saveRecipeButton"
    public static let cancelRecipeButton = "cancelRecipeButton"
    public static let cancelRecipeAlert = "cancelRecipeAlert"
    public static let recipeQuantityField = "recipeQuantityField"
    public static let addStepCell = "addStepCell"

    // MARK: Step detail

    public static let stepDurationCell = "stepDurationCell"
    public static let stepDurationPicker = "stepDurationPicker"
    public static let addIngredientCell = "addIngredientCell"

    // MARK: Ingredient detail

    public static let ingredientAmountField = "ingredientAmountField"
    /// The row that shows the ingredient's type and expands the type options
    public static let ingredientTypeCell = "ingredientTypeCell"

    /// The option row for an ingredient type, e.g. `ingredientTypeOption.bulkLiquid`
    public static func ingredientTypeOption(_ caseName: String) -> String {
        "ingredientTypeOption.\(caseName)"
    }

    // MARK: Settings

    public static let closeSettingsButton = "closeSettingsButton"
    public static let roomTemperatureCell = "roomTemperatureCell"
    public static let aboutCell = "aboutCell"
}
