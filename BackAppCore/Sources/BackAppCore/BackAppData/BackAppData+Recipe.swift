//
//  File.swift
//  
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import BakingRecipeStrings
import NotificationCenter

public extension Notification.Name {
    static var recipesChanged: Notification.Name {
        return Notification.Name.init(rawValue: "recipesChanged")
    }
}


// MARK: - Recipes
public extension BackAppData {
    
    /// all Recipes in the database
    var allRecipes: [Recipe] {
        (try? self.databaseReader.read { db in
            try? Recipe.all().orderedByNumber.fetchAll(db)
        }) ?? []
    }
    
    /// all favorited recipes in the database
    var favorites: [Recipe] {
        (try? self.databaseReader.read { db in
            try? Recipe.all().filterFavorites.fetchAll(db)
        }) ?? []
    }
    
    func moveRecipe(from source: Int, to destination: Int) {
        self.moveRecord(in: allRecipes, from: source, to: destination)
    }
}

//MARK: - Recipe Properties
public extension BackAppData {
    
    ///func to reduce code
    private func findRecipeAndReturnAttribute<T>(for recipeId: Int64, failValue: T, successCompletion: ((Recipe) -> T) ) -> T {
        guard let recipe = self.allRecipes.first(where: { $0.id == recipeId }) else {
            return failValue
        }
        
        return successCompletion(recipe)
    }
    
    ///total duration of all steps in minutes
    func totalDuration(for recipeId: Int64) -> Int {
        findRecipeAndReturnAttribute(for: recipeId, failValue: 0) { recipe in
            return recipe.totalDuration(reader: databaseReader)
        }
    }
    
    ///count of all ingredients used in the recipe
    func numberOfAllIngredients(for recipeId: Int64) -> Int {
        (try? databaseReader.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT( DISTINCT INGREDIENT.ID) FROM INGREDIENT LEFT JOIN STEP ON INGREDIENT.STEPID = STEP.ID WHERE STEP.ID IN (SELECT STEP.ID FROM STEP WHERE STEP.RECIPEID = \(recipeId))")
        }) ?? 0
    }
    
    /// totalAmount of all ingredients in the recipe
    func totalAmount(for recipeId: Int64) -> Double {
        var summ: Double = 0
        // iterate through all non substeps cause totalMass also uses the substeps
        _ = self.notSubsteps(for: recipeId).map { summ += self.totalMass(for: $0.id!)}
        return summ
    }

    /// total formatted amount of all ingredients in a given recipe in gramms
    func totalFormattedAmount(for recipeId: Int64) -> String {
        self.totalAmount(for: recipeId).formattedMass
    }
    
    /// dough Yield (waterSum/flourSum) * 100 + 100 for a given Recipe if locale == "de"
    private func totalDoughYield(for recipeId: Int64) -> Double {
        
        var flourSum = 0.0
        _ = self.notSubsteps(for: recipeId).map { flourSum += self.flourMass(for: $0.id!)}

        var waterSum = 0.0
        _ = self.notSubsteps(for: recipeId).map { waterSum += self.waterMass(for: $0.id!)}

        guard flourSum != 0 else {
            return 0
        }

        if Bundle.main.preferredLocalizations.first! == "de" {
            return (waterSum/flourSum) * 100 + 100
        } else {
            return (waterSum/flourSum)
        }
    }

    /// dough Yield (waterSum/flourSum) for a given Recipe as a String shorted to 2 decimal points
    func formattedTotalDoughYield(for recipeId: Int64) -> String {
        String(format: "%.2f", totalDoughYield(for: recipeId))
    } //tested

    ///formatted total duration in the right unit
    func formattedTotalDuration(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            recipe.totalDuration(reader: databaseReader).formattedDuration
        }
    }

    ///formatted total duration in hours
    func formattedTotalDurationHours(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return(recipe.totalDuration(reader: databaseReader).hours * 60).formattedDuration
        }
    }

    ///startDate formatted using the dateFormatter
    private func formattedStartDate(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return dateFormatter.string(from: recipe.startDate(reader: databaseReader))
        }
    }

    ///endDate formatted using the dateFormatter
    private func formattedEndDate(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return dateFormatter.string(from: recipe.endDate(reader: databaseReader))
        }
    }

    ///formatted Datetext including start and end Text e. g. “Start: 01.01. 1970 18:00”
    func formattedDate(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            if recipe.inverted {
                return "\(Strings.end) \(formattedEndDate(for: recipeId))"
            } else{
                return "\(Strings.start)) \(formattedStartDate(for: recipeId))"
            }
        }
    }

    ///combination of formattedEndDate and formattedStartDate
    func formattedStartBisEnde(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return "\(self.formattedStartDate(for: recipeId)) bis \n\(self.formattedEndDate(for: recipeId))"
        }
    }

    ///text for exporting
    func text(for recipeId: Int64, roomTemp: Double, scaleFactor: Double, kneadingHeating: Double) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return recipe.text(roomTemp: roomTemp, scaleFactor: scaleFactor, kneadingHeating: kneadingHeating, reader: databaseReader)
        }
    }

    ///steps that are no substeps of any other step
    func notSubsteps(for recipeId: Int64) -> [Step] {
        findRecipeAndReturnAttribute(for: recipeId, failValue: []) { recipe in
            recipe.notSubsteps(reader: databaseReader)
        }
    }

    func reorderedSteps(for recipeId: Int64) -> [Step] {
        findRecipeAndReturnAttribute(for: recipeId, failValue: []) { recipe in
            recipe.reorderedSteps(writer: self.dbWriter)
        }
    }

    func formattedStartDate(for item: Step, with recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            recipe.formattedStartDate(for: item, reader: databaseReader)
        }
    }
}
