//
//  File.swift
//  
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import Sqlable
import BakingRecipeStrings
import Combine
import NotificationCenter

public extension Notification.Name {
    static var recipesChanged: Notification.Name {
        return Notification.Name.init(rawValue: "recipesChanged")
    }
}


@available(iOS 13.0, *)
public extension BackAppData {
    #if canImport(Combine)
    func getRecipes(favouritesOnly: Bool = false) -> Future<[Recipe], Error> {
        Future { promise in
            do {
                var statement = Recipe.read().orderBy(Recipe.number)
                if favouritesOnly {
                    statement = statement.filter(Recipe.isFavorite == true)
                }
                let recipes = try statement.run(self.database)
                promise(.success(recipes))
            } catch {
                promise(.failure(error))
            }
        }
    }
    #endif
}


// MARK: - Recipes
public extension BackAppData {
    
    /// all Recipes in the database
    var allRecipes: [Recipe] {
        (try? Recipe.read().orderBy(Recipe.number, .asc).run(database)) ?? []
    }
    
    /// all favorited recipes in the database
    var favorites: [Recipe] {
        (try? Recipe.read().filter(Recipe.isFavorite == true).run(database)) ?? []
    }
    
    func moveRecipe(from source: Int, to destination: Int) {
    
        var recipeIds = allRecipes.map { $0.id }
        
        let removedObject = recipeIds.remove(at: source)
        recipeIds.insert(removedObject, at: destination)
        
        var number = 0
        for id in recipeIds {
            
            //database operations need to be run from the main thread
            DispatchQueue.main.async {
                var object = self.object(with: id, of: Recipe.self)!
                object.number = number
                number += 1
                _ = self.update(object)
            }
        }
    }
}

//MARK: - Recipe Properties
public extension BackAppData {
    
    ///func to reduce code
    private func findRecipeAndReturnAttribute<T>(for recipeId: Int, failValue: T, successCompletion: ((Recipe) -> T) ) -> T {
        guard let recipe = self.allRecipes.first(where: { $0.id == recipeId }) else {
            return failValue
        }
        
        return successCompletion(recipe)
    }
    
    ///total duration of all steps
    func totalDuration(for recipeId: Int) -> Int {
        findRecipeAndReturnAttribute(for: recipeId, failValue: 0) { recipe in
            return recipe.totalDuration(steps: steps(with: recipeId))
        }
    }
    
    ///count of all ingredients used in the recipe
    func numberOfAllIngredients(for recipeId: Int) -> Int {
        findRecipeAndReturnAttribute(for: recipeId, failValue: 0) { recipe in
            var counter = 0
            _ = steps(with: recipeId).map { counter += (try? Ingredient.count().filter(Ingredient.stepId == $0.id).run(database)) ?? 0 }
            return counter
        }
    }
    
    ///formatted total duration in the right unit
    func formattedTotalDuration(for recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            recipe.totalDuration(steps: steps(with: recipeId)).formattedDuration
        }
    }
    
    ///startDate formatted using the dateFormatter
    func formattedStartDate(for recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return dateFormatter.string(from: recipe.startDate(db: database))
        }
    }
    
    ///endDate formatted using the dateFormatter
    func formattedEndDate(for recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return dateFormatter.string(from: recipe.endDate(db: database))
        }
    }
    
    ///formatted Datetext including start and end Text e. g. “Start: 01.01. 1970 18:00”
    func formattedDate(for recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            if recipe.inverted {
                return "\(Strings.end) \(formattedEndDate(for: recipeId))"
            } else{
                return "\(Strings.start)) \(formattedStartDate(for: recipeId))"
            }
        }
    }
    
    ///combination of formattedEndDate and formattedStartDate
    func formattedStartBisEnde(for recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return "\(self.formattedStartDate(for: recipeId)) bis \n\(self.formattedEndDate(for: recipeId))"
        }
    }
    
    ///text for exporting
    func text(for recipeId: Int, roomTemp: Double, scaleFactor: Double, kneadingHeating: Double) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return recipe.text(roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, db: database)
        }
    }
    
    ///steps that are no substeps of any other step
    func notSubsteps(for recipeId: Int) -> [Step] {
        findRecipeAndReturnAttribute(for: recipeId, failValue: []) { recipe in
            recipe.notSubsteps(db: database)
        }
    }
    
    func reorderedSteps(for recipeId: Int) -> [Step] {
        findRecipeAndReturnAttribute(for: recipeId, failValue: []) { recipe in
            recipe.reorderedSteps(db: database)
        }
    }
    
    func formattedStartDate(for item: Step, with recipeId: Int) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            recipe.formattedStartDate(for: item, db: database)
        }
    }
}