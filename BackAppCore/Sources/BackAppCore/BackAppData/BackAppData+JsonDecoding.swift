// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  BackAppData+JsonDecoding.swift
//  
//
//  Created by Moritz Schaub on 27.12.20.
//

import SwiftyJSON
import Foundation
import BakingRecipeFoundation
import BakingRecipeStrings

///Notifications for triggering events in the ui
public extension Notification.Name {
    static let homeShouldPopSplitVC = Self.init("homeShouldPopSplitVC")
}

/// The outcome of importing a recipe file, so the ui can tell the user whether it worked.
public enum ImportResult: Sendable, Equatable {
    /// the file contained recipes and they were imported
    case imported
    /// the file could be read, but it contains no recipes
    case noRecipes
    /// the file could not be read
    case unreadable

    /// title of the alert telling the user about the import
    public var alertTitle: String {
        self == .imported ? Strings.success : Strings.Alert_Error
    }

    /// message of the alert telling the user about the import
    public var alertMessage: String {
        switch self {
        case .imported: return Strings.recipesImported
        case .noRecipes: return Strings.importFileContainsNoRecipes
        case .unreadable: return Strings.importFileUnreadable
        }
    }
}

public extension BackAppData {
    
    /// Reads the file at `url` and imports the recipes it contains.
    ///
    /// `BackAppData` is not actor-isolated, so this `async` method runs on the global
    /// concurrent executor and reading and importing the file stays off the main actor.
    /// - Note: When the package adopts Swift 6.2's `NonisolatedNonsendingByDefault`,
    ///   mark this method `@concurrent` to keep it off the caller's actor.
    /// - Returns: whether the import worked, including when the file could not be read
    func open(_ url: URL) async -> ImportResult {
        importFile(at: url)
    }

    /// Synchronously reads the file at `url` and imports the recipes it contains.
    /// - Returns: whether the import worked, including when the file could not be read
    func importFile(at url: URL) -> ImportResult {
        guard let loadedData = url.loadData().data else { return .unreadable }
        return importData(loadedData) ? .imported : .noRecipes
    }
    
    /// imports data containing recipes into the database
    /// - Returns: wether the import succeeded
    func importData(_ data: Data) -> Bool {
        //make json from data and ensure it contains the coding keys
        if let json = try? JSON(data: data), let recipesJson = json[CodingKeys.recipes.rawValue].array {
            _ = recipesJson.map { decodeAndImportRecipe(from: $0)} //decode and import
            return true
        } else {
            return false
        }
    }
    
    private func decodeAndImportRecipe(from json: JSON) {
        
        var recipe = Recipe(number: 0)
        
        recipe.name = json[CodingKeys.name.rawValue].stringValue
        
        if let info = json[CodingKeys.info.rawValue].string {
            recipe.info = info
        }
        
        let difficultyNumber = json[CodingKeys.info.rawValue].intValue
        recipe.difficulty = Difficulty(rawValue: difficultyNumber) ?? .easy
        
        recipe.times = Decimal(json[CodingKeys.times.rawValue].doubleValue)
        
        let imageString = json[CodingKeys.imageData.rawValue].stringValue
        if imageString != "" {
            recipe.imageData = Data(base64Encoded: imageString)
        }
        
        recipe.number = json[CodingKeys.number.rawValue].intValue
        
        //add the recipe
        insert(&recipe)
        if let stepsJson = json[CodingKeys.steps.rawValue].array {
            //decode and import the steps
            _ = stepsJson.map { decodeAndImportStep(from: $0, with: recipe.id!, and: nil) }
        }
    }
    
    private func decodeAndImportStep(from json: JSON, with recipeId: Int64, and superstepId: Int64?)  {

        var step = Step(recipeId: recipeId, number: 0)

        step.superStepId = superstepId

        step.name = json[CodingKeys.name.rawValue].stringValue
        
        step.duration = json[CodingKeys.duration.rawValue].doubleValue
        
        step.number = json[CodingKeys.number.rawValue].intValue
        
        if let temperature = json[CodingKeys.temperature.rawValue].double {
            step.temperature = temperature
        }
        
        if let notes = json[CodingKeys.notes.rawValue].string {
            step.notes = notes
        }
        
        //insert into the database
        insert(&step)

        //substeps
        if let substepsJson = json[CodingKeys.substeps.rawValue].array {

            //do the same thing to the substeps
            _ = substepsJson.map { decodeAndImportStep(from: $0, with: recipeId, and: step.id) }
        }
        //ingredients
        if let ingredientsJson = json[CodingKeys.ingredients.rawValue].array {

            //import the ingredients used in this step
            let ingredients = ingredientsJson.map { decodeAndImportIngredient(from: $0, with: step.id!)  }
            try! dbWriter.write { db in
                _ = ingredients.map {
                    var ingredient = $0
                    try! ingredient.insert(db)
                }
            }
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
        }
    }
    
    private func decodeAndImportIngredient(from json: JSON, with stepId: Int64) -> Ingredient {
        
        var ingredient = Ingredient(stepId: stepId, number: 0)
        
        ingredient.name = json[CodingKeys.name.rawValue].stringValue
        
        ingredient.mass = json[CodingKeys.mass.rawValue].doubleValue
        
        ingredient.number = json[CodingKeys.number.rawValue].intValue
        
        if let temperature = json[CodingKeys.temperature.rawValue].double {
            ingredient.temperature = temperature
        }
        
        let typeDouble = json[CodingKeys.type.rawValue].doubleValue
        ingredient.type = Ingredient.Style(rawValue: typeDouble) ?? .other
        
        return ingredient
    }
    
}
