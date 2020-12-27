//
//  BackAppData+JsonDecoding.swift
//  
//
//  Created by Moritz Schaub on 27.12.20.
//

import BackAppCore
import SwiftyJSON
import Foundation
import BakingRecipeFoundation

extension BackAppData {
    
    func importFile(data: Data) {
        if let json = try? JSON(data: data) {

            if let recipesJson = json["recipes"].array {
                _ = recipesJson.map { decodeAndImportRecipe(from: $0)}
            }
        }
    }
    
    private func decodeAndImportRecipe(from json: JSON) {
        let newId = self.newId(for: Recipe.self)
        
        var recipe = Recipe(id: newId)
        
        recipe.name = json["name"].stringValue
        
        if let info = json["info"].string {
            recipe.info = info
        }
        
        let difficultyNumber = json["difficulty"].intValue
        recipe.difficulty = Difficulty(rawValue: difficultyNumber) ?? .easy
        
        recipe.times = Decimal(json["times"].doubleValue)
        
        let imageString = json["imageData"].stringValue
        recipe.imageData = Data(base64Encoded: imageString)
        
        //add the recipe
        if insert(recipe), let stepsJson = json["step"].array {
            //decode and import the steps
            _ = stepsJson.map { decodeAndImportStep(from: $0, with: newId, and: nil) }
        }
        
    }
    
    private func decodeAndImportStep(from json: JSON, with recipeId: Int, and superstepId: Int?) {

        let newId = self.newId(for: Step.self)

        var step = Step(id: newId, recipeId: recipeId)

        step.superStepId = superstepId

        step.name = json["name"].stringValue
        
        step.duration = json["duration"].doubleValue
        
        if let temperature = json["temperature"].int {
            step.temperature = temperature
        }
        
        if let notes = json["notes"].string {
            step.notes = notes
        }
        
        //insert into the database
        if insert(step) {
        
            //substeps
            if let substepsJson = json["substeps"].array {
                
                //do the same thing to the substeps
                _ = substepsJson.map { decodeAndImportStep(from: $0, with: recipeId, and: step.id) }
            }
            
            //ingredients
            if let ingredientsJson = json["ingredients"].array {
                
                
                _ = ingredientsJson.map { decodeAndImportIngredient(from: $0, with: step.id)  }
            }
        
        }
    }
    
    private func decodeAndImportIngredient(from json: JSON, with stepId: Int) {
        
        let newId = self.newId(for: Ingredient.self)
        
        var ingredient = Ingredient(stepId: stepId, id: newId)
        
        ingredient.name = json["name"].stringValue
        
        ingredient.mass = json["mass"].doubleValue
        
        if let temperature = json["temperature"].int {
            ingredient.temperature = temperature
        }
        
        let typeDouble = json["type"].doubleValue
        ingredient.type = Ingredient.Style(rawValue: typeDouble) ?? .other
        
        //insert it
        insert(ingredient)
    }
    
//    private func decodeIngredient(from json: JSON, with stepId: Int) {
//
//        let newId = self.newId(for: Ingredient.self)
//
//        var ingredient = Ingredient(stepId: stepId, id: newId)
//
//        ingredient.name = json["name"].stringValue
//
//        if let amount = json["amount"].double {
//            ingredient.mass = amount
//        } else if let mass = json["mass"].double {
//            ingredient.mass = mass
//        }
//
//        if let isBulkLiquid = json["isBulkLiquid"].bool {
//            if isBulkLiquid {
//                ingredient.type = .bulkLiquid
//            } else {
//                ingredient.type = .other
//            }
//        } else if let typeDouble = json["type"].double {
//            let type = Ingredient.Style.allCases.first(where: { $0.rawValue == typeDouble }) ?? .other
//            ingredient.type = type
//        }
//
//        //insert the ingredient into the database
//
//        _ = self.insert(ingredient)
//    }
    
}
