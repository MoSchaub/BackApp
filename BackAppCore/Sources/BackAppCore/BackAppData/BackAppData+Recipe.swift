// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  BackAppData+Recipe.swift
//
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import BakingRecipeStrings
import NotificationCenter
import GRDB
import Combine

public extension Notification.Name {
    static var recipesChanged: Notification.Name {
        return Notification.Name.init(rawValue: "recipesChanged")
    }
}

// Feeds the list of recipes
public extension BackAppData {
    struct RecipeListItem: Decodable, Hashable, FetchableRecord {
        public let recipe: Recipe
        public let stepCount: Int

        static var request = Recipe.annotated(with: Recipe.steps.count).orderedByNumber
    }

    private func recipeList(db: Database) throws -> [RecipeListItem] {
        try RecipeListItem.fetchAll(db, RecipeListItem.request)
    }

    var recipeListPublisher: DatabasePublishers.Value<[RecipeListItem]> {
        ValueObservation
            .tracking { db in
                try self.recipeList(db: db)
            }
            .publisher(in: dbWriter, scheduling: .immediate)
    }

    struct RecipeDetailItem: Decodable, FetchableRecord {
        public var recipe: Recipe
        public var stepItems: [StepItem]
        public var infoStripItem: InfoStripItem
        public var timesText: String
    }

    private func recipeInfo(recipeId: Int64, db: Database) throws -> RecipeDetailItem? {
        guard let recipe = try Recipe.fetchOne(db, id: recipeId) else {
            return nil
        }

        let stepsItems = try recipe.stepItems(db: db)

        let infoStripItem = try recipe.infoStripItem(db: db)

        let timesText = try recipe.timesTextWithIndivialMass(with: recipe.totalAmount(db: db))
        return RecipeDetailItem.init(recipe: recipe, stepItems: stepsItems, infoStripItem: infoStripItem, timesText: timesText)
    }

    func recipeInfoPublisher(for recipeId: Int64) -> DatabasePublishers.Value<RecipeDetailItem?> {
        ValueObservation
            .tracking { db in
                try self.recipeInfo(recipeId: recipeId, db: db)
            }
            .publisher(in: dbWriter, scheduling: .immediate) //immediate to improve recipe loading times
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
    
    func moveRecipe(from source: Int, to destination: Int) {
        self.moveRecord(in: allRecipes.filter{ !$0.isFavorite }, from: source, to: destination)
    }

    /// creates new blank recipe generates a new number inserts it and returns the inserted recipe
    func addBlankRecipe() throws -> Recipe {
        try self.dbWriter.write { db in
            let newNumber = try Recipe.fetchCount(db)
            var newRecipe = Recipe(number: newNumber)
            try newRecipe.insert(db)
            return newRecipe
        }
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
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            (try? self.databaseReader.read { db in
                try recipe.formattedTotalDoughYield(db: db)
            }) ?? ""
        }
    }

    ///formatted total duration in hours
    func totalCompactFormattedDuration(for recipeId: Int64) -> String {
        findRecipeAndReturnAttribute(for: recipeId, failValue: "") { recipe in
            return(recipe.totalDuration(reader: databaseReader)).compactForamttedDuration
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
