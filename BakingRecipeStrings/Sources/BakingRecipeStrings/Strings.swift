// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

public struct Strings {
    public static let General_BackButtonTitle = NSLocalizedString("General_BackButtonTitle", bundle: .module, comment: "")
    public static let Alert_ActionCancel = NSLocalizedString("Alert_ActionCancel", bundle: .module, comment: "")
    public static let Alert_ActionOk = NSLocalizedString("Alert_ActionOk", bundle: .module, comment: "")
    public static let Alert_ActionRemove = NSLocalizedString("Alert_ActionRemove", bundle: .module, comment: "")
    public static let Alert_ActionDelete = NSLocalizedString("Alert_ActionDelete", bundle: .module, comment: "")
    public static let Alert_ActionSave = NSLocalizedString("Alert_ActionSave", bundle: .module, comment: "")
    public static let Alert_Error = NSLocalizedString("Alert_Error", bundle: .module, comment: "")
    public static let EditButton_Done = NSLocalizedString("EditButton_Done", bundle: .module, comment: "")
    public static let EditButton_Edit = NSLocalizedString("EditButton_Edit", bundle: .module, comment: "")
    public static let about = NSLocalizedString("about", bundle: .module, comment: "")
    public static let addIngredient = NSLocalizedString("addIngredient", bundle: .module, comment: "")
    public static let addStep = NSLocalizedString("addStep", bundle: .module, comment: "")
    public static let amount = NSLocalizedString("amount", bundle: .module, comment: "")
    public static let amountCellPlaceholder1 = NSLocalizedString("amountCellPlaceholder1", bundle: .module, comment: "")
    public static let amountCellPlaceholder2 = NSLocalizedString("amountCellPlaceholder2", bundle: .module, comment: "")
    public static let appTitle = NSLocalizedString("appTitle", bundle: .module, comment: "")
    public static let bulkLiquid = NSLocalizedString("bulkLiquid", bundle: .module, comment: "")
    public static let CancelRecipeMessage = NSLocalizedString("CancelRecipeMessage", bundle: .module, comment: "")
    public static let type = NSLocalizedString("type", bundle: .module, comment: "")
    public static let duration = NSLocalizedString("duration", bundle: .module, comment: "")
    public static let dynamicTemp = NSLocalizedString("dynamicTemp", bundle: .module, comment: "")
    public static let end = NSLocalizedString("end", bundle: .module, comment: "")
    public static let exportAll = NSLocalizedString("exportAll", bundle: .module, comment: "")
    public static let image = NSLocalizedString("image", bundle: .module, comment: "")
    public static let importFile = NSLocalizedString("importFile", bundle: .module, comment: "")
    public static let ingredientOrStep = NSLocalizedString("ingredientOrStep", bundle: .module, comment: "")
    public static let ingredients = NSLocalizedString("ingredients", bundle: .module, comment: "")
    public static let name = NSLocalizedString("name", bundle: .module, comment: "")
    public static let newIngredient = NSLocalizedString("newIngredient", bundle: .module, comment: "")
    public static let notes = NSLocalizedString("notes", bundle: .module, comment: "")
    public static let quantity = NSLocalizedString("quantity", bundle: .module, comment: "")
    public static let recipes = NSLocalizedString("recipes", bundle: .module, comment: "")
    public static let noRecipeSelected = NSLocalizedString("noRecipeSelected", bundle: .module, comment: "Title of the empty detail pane next to the recipe list")
    public static let noRecipeSelectedHint = NSLocalizedString("noRecipeSelectedHint", bundle: .module, comment: "Hint below the title of the empty detail pane")
    public static let roomTemperature = NSLocalizedString("roomTemperature", bundle: .module, comment: "")
    public static let selectStep = NSLocalizedString("selectStep", bundle: .module, comment: "")
    public static let start = NSLocalizedString("start", bundle: .module, comment: "")
    public static let startRecipe = NSLocalizedString("startRecipe", bundle: .module, comment: "")
    public static let step = NSLocalizedString("step", bundle: .module, comment: "")
    public static let steps = NSLocalizedString("steps", bundle: .module, comment: "")
    public static let temperature = NSLocalizedString("temperature", bundle: .module, comment: "")
    public static let unnamedRecipe = NSLocalizedString("unnamedRecipe", bundle: .module, comment: "")
    public static let unnamedIngredient = NSLocalizedString("unnamedIngredient", bundle: .module, comment: "")
    public static let unnamedStep = NSLocalizedString("unnamedStep", bundle: .module, comment: "")
    public static let image_alert_title = NSLocalizedString("image_alert_title", bundle: .module, comment: "")
    public static let take_picture = NSLocalizedString("take_picture", bundle: .module, comment: "")
    public static let website = NSLocalizedString("website", bundle: .module, comment: "")
    public static let privacy_policy = NSLocalizedString("privacy_policy", bundle: .module, comment: "")
    public static let select_image = NSLocalizedString("select_image", bundle: .module, comment: "")
    public static let importFileUnreadable = NSLocalizedString("importFileUnreadable", bundle: .module, comment: "")
    public static let importFileContainsNoRecipes = NSLocalizedString("importFileContainsNoRecipes", bundle: .module, comment: "")
    public static let success = NSLocalizedString("success", bundle: .module, comment: "")
    public static let flour = NSLocalizedString("flour", bundle: .module, comment: "")
    public static let other = NSLocalizedString("other", bundle: .module, comment: "")
    public static let ta150 = NSLocalizedString("ta150", bundle: .module, comment: "")
    public static let ta200 = NSLocalizedString("ta200", bundle: .module, comment: "")
    public static let startDate = NSLocalizedString("startDate", bundle: .module, comment: "")
    public static let endDate = NSLocalizedString("endDate", bundle: .module, comment: "")
    public static let settings = NSLocalizedString("settings", bundle: .module, comment: "")
    public static let kneadingHeating = NSLocalizedString("kneadingHeating", bundle: .module, comment: "")
    public static let kneadingHeatCellPlaceholder = NSLocalizedString("kneadingHeatCellPlaceholder", bundle: .module, comment: "")
    public static let language = NSLocalizedString("language", bundle: .module, comment: "")
    public static var favorites = NSLocalizedString("favorites", bundle: .module, comment: "")
    public static var weighIn = NSLocalizedString("weighIn", bundle: .module, comment: "")
    public static var doughYield = NSLocalizedString("doughYield", bundle: .module, comment: "")
    public static var roomTempQuestionLabel = NSLocalizedString("roomTempQuestionLabel", bundle: .module, comment: "")
    public static var schedule = NSLocalizedString("schedule", bundle: .module, comment: "")
    public static var createSchedule = NSLocalizedString("createSchedule", bundle: .module, comment: "")
    public static var isKneadingStep = NSLocalizedString("isKneadingStep", bundle: .module, comment: "")
    public static var share = NSLocalizedString("share", bundle: .module, comment: "")
    public static var addFavorite = NSLocalizedString("addFavorite", bundle: .module, comment: "")
    public static var removeFavorite = NSLocalizedString("removeFavorite", bundle: .module, comment: "")
    public static var endTemp = NSLocalizedString("endTemp", bundle: .module, comment: "")
    public static var duplicate = NSLocalizedString("duplicate", bundle: .module, comment: "")
    public static var addRecipe = NSLocalizedString("addRecipe", bundle: .module, comment: "")
    public static var license = NSLocalizedString("License", bundle: .module, comment: "")
    public static let version = String.localizedStringWithFormat(
        NSLocalizedString("versionFormat", bundle: .module, comment: "App version on the about screen; first the release, then the build number"),
        Bundle.main.releaseVersionNumber!, Bundle.main.buildVersionNumber!
    )

    // MARK: - Counted and formatted strings
    // Built from format strings so each language picks its own plural form and word order.

    /// e.g. "5 minutes"
    public static func minutesCount(_ count: Int) -> String {
        String.localizedStringWithFormat(NSLocalizedString("minutesCount", bundle: .module, comment: "A duration in whole minutes"), count)
    }

    /// e.g. "2 hours"
    public static func hoursCount(_ count: Int) -> String {
        String.localizedStringWithFormat(NSLocalizedString("hoursCount", bundle: .module, comment: "A duration in whole hours"), count)
    }

    /// e.g. "1.5 hours"
    /// - Parameters:
    ///   - hours: the value the plural form is chosen for
    ///   - formatted: `hours` as it should be displayed
    public static func hoursDecimalCount(_ hours: Double, formatted: String) -> String {
        String.localizedStringWithFormat(NSLocalizedString("hoursDecimalCount", bundle: .module, comment: "A duration in hours that can have a fraction; the second argument is the displayed number"), hours, formatted)
    }

    /// e.g. "12 pieces"
    /// - Parameters:
    ///   - count: the value the plural form is chosen for
    ///   - formatted: `count` as it should be displayed
    public static func piecesCount(_ count: Double, formatted: String) -> String {
        String.localizedStringWithFormat(NSLocalizedString("piecesCount", bundle: .module, comment: "Number of breads or rolls a recipe makes; the second argument is the displayed number"), count, formatted)
    }

    /// e.g. "12 pieces, 80.0 g each"
    public static func piecesWithMass(_ pieces: String, mass: String) -> String {
        String.localizedStringWithFormat(NSLocalizedString("piecesWithMass", bundle: .module, comment: "Number of pieces (piecesCount) followed by the mass of one piece"), pieces, mass)
    }

    /// e.g. "4 steps"
    public static func stepsCount(_ count: Int) -> String {
        String.localizedStringWithFormat(NSLocalizedString("stepsCount", bundle: .module, comment: "Number of steps of a recipe in the recipe list"), count)
    }

    /// Message after importing recipes from a file
    public static func recipesImported(_ count: Int) -> String {
        String.localizedStringWithFormat(NSLocalizedString("recipesImportedCount", bundle: .module, comment: "Alert message after importing recipes from a file"), count)
    }

    /// Last line of an exported recipe, e.g. "Done: 08.11.26, 14:00"
    public static func exportEndDate(_ date: String) -> String {
        String.localizedStringWithFormat(NSLocalizedString("exportEndDate", bundle: .module, comment: "Last line of an exported recipe: when the recipe is finished"), date)
    }

    public static let info = "info"
    public static let websiteURL = URL(string: "https://heimbaecker.de/backapp")!
    public static let privacyPolicyURL = URL(string: "https://heimbaecker.de/backapp-datenschutzerklaerung")!
    public static let donateURL = URL(string: "https://heimbaecker.de/backapp-donate")!
    
    public static let init_coder_not_implemented = "init(coder:) has not been implemented"
    
    public static let recipeCell = "recipe"
    public static let detailCell = "detail"
    public static let plainCell = "plain"
    public static let tempPickerCell = "tempPicker"
    public static let nameCell = "name"
    public static let notesCell = "notes"
    public static let durationCell = "duration"
    public static let tempCell = "temp"
    public static let ingredientCell = "ingredient"
    public static let addIngredientCell = "addIngredient"
    public static let substepCell = "substep"
    public static let amountCell = "amount"
    public static let IngredientTypeCell = "ingredientType"
    public static let toggleCell = "toggle"
    public static let pickerCell = "picker"
    public static let timePickerCell = "timePicker"
    public static let imageCell = "image"
    public static let stepCell = "step"
    public static let infoStripCell = "infoStrip"
    public static let infoCell = "info"
    public static let textFieldCell = "textField"
    public static let scheduleCell = "schedule"
    public static let switchCell = "switch"
    public static let kneadingHeatingCell = "kneadingHeating"
    public static let apperanceCell = "appearance"
    public static let languageCell = "language"
    public static let textCell = "text"
    public static let kneadingStepCell = "kneadingStep"
    public static let endTempCell = "endTempCell"
    public static let timesCell = "timesCell"
}
