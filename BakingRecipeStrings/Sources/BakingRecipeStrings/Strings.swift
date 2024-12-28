//
//  Strings.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

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
    public static let Alert_ActionRetry = NSLocalizedString("Alert_ActionRetry", bundle: .module, comment: "")
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
    public static let minute = NSLocalizedString("minute", bundle: .module, comment: "")
    public static let minutes = NSLocalizedString("minutes", bundle: .module, comment: "")
    public static let name = NSLocalizedString("name", bundle: .module, comment: "")
    public static let newIngredient = NSLocalizedString("newIngredient", bundle: .module, comment: "")
    public static let notes = NSLocalizedString("notes", bundle: .module, comment: "")
    public static let piece = NSLocalizedString("piece", bundle: .module, comment: "")
    public static let pieces = NSLocalizedString("pieces", bundle: .module, comment: "")
    public static let quantity = NSLocalizedString("quantity", bundle: .module, comment: "")
    public static let recipes = NSLocalizedString("recipes", bundle: .module, comment: "")
    public static let roomTemperature = NSLocalizedString("roomTemperature", bundle: .module, comment: "")
    public static let scheduleFormErrorMessage = NSLocalizedString("scheduleFormErrorMessage", bundle: .module, comment: "")
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
    public static let version = NSLocalizedString("version", bundle: .module, comment: "") + " \(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))"
    public static let donate_text = NSLocalizedString("donateText", bundle: .module, comment: "")
    public static let website = NSLocalizedString("website", bundle: .module, comment: "")
    public static let support = NSLocalizedString("support", bundle: .module, comment: "")
    public static let privacy_policy = NSLocalizedString("privacy_policy", bundle: .module, comment: "")
    public static let select_image = NSLocalizedString("select_image", bundle: .module, comment: "")
    public static let recipesImported = NSLocalizedString("recipesImported", bundle: .module, comment: "")
    public static let recipeImported = NSLocalizedString("recipeImported", bundle: .module, comment: "")
    public static let success = NSLocalizedString("success", bundle: .module, comment: "")
    public static let flour = NSLocalizedString("flour", bundle: .module, comment: "")
    public static let other = NSLocalizedString("other", bundle: .module, comment: "")
    public static let ta150 = NSLocalizedString("ta150", bundle: .module, comment: "")
    public static let ta200 = NSLocalizedString("ta200", bundle: .module, comment: "")
    public static let startDate = NSLocalizedString("startDate", bundle: .module, comment: "")
    public static let endDate = NSLocalizedString("endDate", bundle: .module, comment: "")
    public static let one = NSLocalizedString("one", bundle: .module, comment: "")
    public static let hour = NSLocalizedString("hour", bundle: .module, comment: "")
    public static let hours = NSLocalizedString("hours", bundle: .module, comment: "")
    public static let settings = NSLocalizedString("settings", bundle: .module, comment: "")
    public static let kneadingHeating = NSLocalizedString("kneadingHeating", bundle: .module, comment: "")
    public static let kneadingHeatCellPlaceholder = NSLocalizedString("kneadingHeatCellPlaceholder", bundle: .module, comment: "")
    public static let appearance = NSLocalizedString("appearance", bundle: .module, comment: "")
    public static let auto = NSLocalizedString("auto", bundle: .module, comment: "")
    public static let dark = NSLocalizedString("dark", bundle: .module, comment: "")
    public static let light = NSLocalizedString("light", bundle: .module, comment: "")
    public static let language = NSLocalizedString("language", bundle: .module, comment: "")
    public static var favorites = NSLocalizedString("favorites", bundle: .module, comment: "")
    public static var allRecipes = NSLocalizedString("allRecipes", bundle: .module, comment: "")
    public static var next = NSLocalizedString("next", bundle: .module, comment: "")
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
    
    public static let info = "info"
    public static let recipe_already_exist_error = NSLocalizedString("recipe_already_exist_error", bundle: .module, comment: "")
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
