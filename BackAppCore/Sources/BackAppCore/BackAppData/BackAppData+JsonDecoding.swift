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
    static var homeNavBarShouldReload = Self.init(rawValue: "homeNavBarShouldReload")
    static var alertShouldBePresented = Self.init(rawValue: "alertShouldBePresented")
}

public extension BackAppData {
    
    /// opens the data at a specified url and tries to import it as a recipe, sets alertTitle and Message
    func open(_ url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if !databaseAutoUpdatesDisabled {
                databaseAutoUpdatesDisabled = true
                let loaded = url.loadData() //gets the data from the file at url
                
                if let loadedData = loaded.data { //make sure the data is succesfully loaded
                    if self.importData(loadedData) { //import the data into the internal database
                        
                        //set succes
                        self.inputAlertTitle = Strings.success
                        self.inputAlertTitle = Strings.recipesImported
                    } else {
                        
                        //send error message
                        self.inputAlertTitle = Strings.Alert_Error
                        self.inputAlertMessage = "" //TODO: add Error message like "error importing recipes"
                    }
                }
                
                // reload the navbar since the updates are disabled
                NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
                
                // present the alert when it is done
                NotificationCenter.default.post(name: .alertShouldBePresented, object: nil)
                
                // make sure the last one displays the correct time since the updates are disabled
                NotificationCenter.default.post(name: .recipesChanged, object: nil)
                
                //reenable the updates
                databaseAutoUpdatesDisabled = false
            }
        }
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
        let newId = self.newId(for: Recipe.self)
        
        var recipe = Recipe(id: newId, number: 0)
        
        recipe.name = json[CodingKeys.name.rawValue].stringValue
        
        if let info = json[CodingKeys.info.rawValue].string {
            recipe.info = info
        }
        
        let difficultyNumber = json[CodingKeys.info.rawValue].intValue
        recipe.difficulty = Difficulty(rawValue: difficultyNumber) ?? .easy
        
        recipe.times = Decimal(json[CodingKeys.times.rawValue].doubleValue)
        
        let imageString = json[CodingKeys.imageData.rawValue].stringValue
        recipe.imageData = Data(base64Encoded: imageString)
        
        recipe.number = json[CodingKeys.number.rawValue].intValue
        
        //add the recipe
        if insert(recipe), let stepsJson = json[CodingKeys.steps.rawValue].array {
            //decode and import the steps
            _ = stepsJson.map { decodeAndImportStep(from: $0, with: newId, and: nil) }
        }
        
    }
    
    private func decodeAndImportStep(from json: JSON, with recipeId: Int, and superstepId: Int?) {

        let newId = self.newId(for: Step.self)

        var step = Step(id: newId, recipeId: recipeId, number: 0)

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
        if insert(step) {
        
            //substeps
            if let substepsJson = json[CodingKeys.substeps.rawValue].array {
                
                //do the same thing to the substeps
                _ = substepsJson.map { decodeAndImportStep(from: $0, with: recipeId, and: step.id) }
            }
            
            //ingredients
            if let ingredientsJson = json[CodingKeys.ingredients.rawValue].array {
                
                //import the ingredients used in this step
                _ = ingredientsJson.map { decodeAndImportIngredient(from: $0, with: step.id)  }
            }
        
        }
    }
    
    private func decodeAndImportIngredient(from json: JSON, with stepId: Int) {
        
        let newId = self.newId(for: Ingredient.self)
        
        var ingredient = Ingredient(stepId: stepId, id: newId, number: 0)
        
        ingredient.name = json[CodingKeys.name.rawValue].stringValue
        
        ingredient.mass = json[CodingKeys.mass.rawValue].doubleValue
        
        ingredient.number = json[CodingKeys.number.rawValue].intValue
        
        if let temperature = json[CodingKeys.temperature.rawValue].int {
            ingredient.temperature = temperature
        }
        
        let typeDouble = json[CodingKeys.type.rawValue].doubleValue
        ingredient.type = Ingredient.Style(rawValue: typeDouble) ?? .other
        
        //insert it
        _ = insert(ingredient)
    }
    
}
