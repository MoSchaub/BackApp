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
    }
    
    ///exports all recipes to a file
    /// - Returns: the url the file is written to
    func exportAllRecipesToFile() -> URL {
        return exportRecipesToFile(recipes: self.allRecipes)
    }
    
    //encodes recipes with its steps and ingredients to a .bakingAppRecipeFile
    func exportRecipesToFile(recipes: [Recipe]) -> URL {
        let recipesJSON = recipes.map { encodeRecipeToJson(with: $0.id) }
        
        let json: JSON = [
            CodingKeys.recipes.rawValue:recipesJSON
        ]
        
        let url = FileManager.default.documentsDirectory.appendingPathComponent("exportedRecipes.bakingAppRecipe")
        
        let data = try! json.rawData(options: .prettyPrinted)
        
         try! data.write(to: url)
        
        return url
    }
    
    private func encodeRecipeToJson(with id: Int) -> JSON {
        guard let recipe = object(with: id, of: Recipe.self) else {
            return JSON()
        }
        
        let steps = self.notSubsteps(for: id).map { encodeStepToJson(with: $0.id)}
        
        var json: JSON = [
            CodingKeys.name.rawValue:recipe.name,
            CodingKeys.difficulty.rawValue:recipe.difficulty.rawValue,
            CodingKeys.steps.rawValue:steps
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
    
    private func encodeStepToJson(with id: Int) -> JSON {
        
        guard let step = object(with: id, of: Step.self) else {
            return JSON()
        }
        
        let ingredients = self.ingredients(with: step.id).map { encodeIngredientToJson(with: $0.id) }
        let substeps = self.substeps(for: step.id).map { encodeStepToJson(with: $0.id) }
        
        
        var json: JSON = [
            CodingKeys.name.rawValue:step.name,
            CodingKeys.duration.rawValue:step.duration,
            CodingKeys.ingredients.rawValue: ingredients,
            CodingKeys.substeps.rawValue: substeps
        ]
        
        if let temperature = step.temperature {
            json[CodingKeys.temperature.rawValue].int = temperature
        }
        if step.notes != "" {
            json[CodingKeys.notes.rawValue].string = step.notes
        }
        
        return json
    }
    
    private func encodeIngredientToJson(with id: Int) -> JSON {

        guard let ingredient = object(with: id, of: Ingredient.self) else {
            return JSON()
        }
        
        var json: JSON = [
            CodingKeys.name.rawValue:ingredient.name,
            CodingKeys.mass.rawValue:ingredient.mass,
            CodingKeys.type.rawValue:ingredient.type.rawValue
        ]
        
        if let temperature = ingredient.temperature {
            json[CodingKeys.temperature.rawValue].int = temperature
        }
        
        return json
    }
    
}
