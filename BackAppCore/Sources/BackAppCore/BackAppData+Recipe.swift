//
//  File.swift
//  
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import Sqlable
import BakingRecipeStrings


// MARK: - Recipes
public extension BackAppData {
    
    /// all Recipes in the database
    var allRecipes: [Recipe] {
        (try? Recipe.read().run(database)) ?? []
    }
    
    /// all favorited recipes in the database
    var favorites: [Recipe] {
        (try? Recipe.read().filter(Recipe.isFavorite == true).run(database)) ?? []
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
            return recipe.totalDuration(db: database)
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
            recipe.totalDuration(db: database).formattedDuration
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
    func text(for recipeId: Int, roomTemp: Int, scaleFactor: Double) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return recipe.text(roomTemp: roomTemp, scaleFactor: scaleFactor, db: database)
        }
    }
    
    ///steps that are no substeps of any other step
    func notSubsteps(for recipeId: Int) -> [Step] {
        findRecipeAndReturnAttribute(for: recipeId, failValue: []) { recipe in
            recipe.notSubsteps(db: database)
        }
    }
}


// MARK: - CRUD Operations for Recipes
public extension BackAppData {
    
    private func search(for recipeId: Int) -> (isNotEmpty: Bool, results: [Recipe]) {
        guard let results = try? Recipe.read().filter(Recipe.id == recipeId).run(database) else {
            return (false, [])
        }
        
        if results.isEmpty {
            return (false, results)
        } else {
            return (true, results)
        }
    }
    
    /// updates a given recipe in the database. If its not  present it gets inserted.
    func update(recipe: Recipe) -> Bool {
        let search = self.search(for: recipe.id)
        
        if search.isNotEmpty {
            do {
                // update the database
                try recipe.update().run(database)
            } catch  {
                print(error.localizedDescription)
                return false
            }
            
            return true
        } else {
            // recipe cant be found insert it
            return self.insert(recipe: recipe)
        }
    }
    
    /// insert a recipe into the database
    /// if it already exists nothing happens
    func insert(recipe: Recipe) -> Bool {
        let search = self.search(for: recipe.id)
        
        if search.isNotEmpty {
            //the recipe already exists don't readd it
            return false
        } else {
            do {
                try recipe.insert().run(database)
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            return true
        }
    }
    
    ///deletes a recipe from the database if it is present
    func delete(recipe: Recipe) -> Bool {
        let search = self.search(for: recipe.id)
        
        if search.isNotEmpty {
            do {
                try recipe.delete().run(database)
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            return true
            
        } else {
            return false
        }
    }
    
    
}
