// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BackAppData+JsonEncoding.swift
//  
//
//  Created by Moritz Schaub on 27.12.20.
//

import Foundation
import BakingRecipeFoundation
import SwiftyJSON

public extension BackAppData {
    
    //the keys used in the json de- and encoding
    internal enum CodingKeys: String {
        case recipes
        case name
        case info
        case times
        case difficulty
        case imageData
        case steps
        case duration
        case temperature
        case notes
        case substeps
        case ingredients
        case mass
        case type
        case number
    }
    
    ///exports all recipes to a file
    /// - Returns: the url the file is written to
    func exportAllRecipesToFile() -> URL {
        return exportRecipesToFile(recipes: self.allRecipes)
    }
    
    //encodes recipes with its steps and ingredients to a .bakingAppRecipeFile
    func exportRecipesToFile(recipes: [Recipe]) -> URL {
        let recipesJSON = recipes.map { encodeRecipeToJson(with: $0.id!) }
        
        let json: JSON = [
            CodingKeys.recipes.rawValue:recipesJSON
        ]
        
        let url = FileManager.default.documentsDirectory.appendingPathComponent("exportedRecipes.bakingAppRecipe")
        
        let data: Data
        if #available(iOS 11.0, *) {
            data = try! json.rawData(options: .sortedKeys)
        } else {
            data = try! json.rawData(options: .prettyPrinted)
        }
        
         try! data.write(to: url)
        
        return url
    }
    
    private func encodeRecipeToJson(with id: Int64) -> JSON {
        guard let recipe = record(with: id, of: Recipe.self) else {
            return JSON()
        }
        
        let steps = self.notSubsteps(for: id).map { encodeStepToJson(with: $0.id!)}
        
        var json: JSON = [
            CodingKeys.name.rawValue:recipe.name,
            CodingKeys.difficulty.rawValue:recipe.difficulty.rawValue,
            CodingKeys.steps.rawValue:steps,
            CodingKeys.number.rawValue:recipe.number
        ]
        
        if recipe.info != "" {
            json[CodingKeys.info.rawValue].string = recipe.info
        }
        if let times = recipe.times {
            json[CodingKeys.times.rawValue].double = (times as NSDecimalNumber).doubleValue
        }
        if let imageData = recipe.imageData {
            json[CodingKeys.imageData.rawValue].string = imageData.base64EncodedString()
        }
        
        return json
    }
    
    private func encodeStepToJson(with id: Int64) -> JSON {
        
        guard let step = record(with: id, of: Step.self) else {
            return JSON()
        }
        
        let ingredients = self.ingredients(with: step.id!).map { encodeIngredientToJson(with: $0.id!) }
        let substeps = self.sortedSubsteps(for: step.id!).map { encodeStepToJson(with: $0.id!) }
        
        
        var json: JSON = [
            CodingKeys.name.rawValue:step.name,
            CodingKeys.duration.rawValue:step.duration,
            CodingKeys.ingredients.rawValue: ingredients,
            CodingKeys.substeps.rawValue: substeps,
            CodingKeys.number.rawValue: step.number
        ]
        
        if let temperature = step.temperature {
            json[CodingKeys.temperature.rawValue].double = temperature
        }
        if step.notes != "" {
            json[CodingKeys.notes.rawValue].string = step.notes
        }
        
        return json
    }
    
    private func encodeIngredientToJson(with id: Int64) -> JSON {

        guard let ingredient = record(with: id, of: Ingredient.self) else {
            return JSON()
        }
        
        var json: JSON = [
            CodingKeys.name.rawValue:ingredient.name,
            CodingKeys.mass.rawValue:ingredient.mass,
            CodingKeys.type.rawValue:ingredient.type.rawValue,
            CodingKeys.number.rawValue:ingredient.number
        ]
        
        if let temperature = ingredient.temperature {
            json[CodingKeys.temperature.rawValue].double = temperature
        }
        
        return json
    }
    
}
