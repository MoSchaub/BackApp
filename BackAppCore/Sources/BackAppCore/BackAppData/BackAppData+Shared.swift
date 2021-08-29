//
//  BackAppData+Shared.swift
//  
//
//  Created by moritz on 04.06.21.
//

import GRDB
import Foundation
import BakingRecipeFoundation

extension BackAppData {
    public static let shared = makeShared()
    
    public static func shared(includeTestingRecipe: Bool = false) -> BackAppData {
        return makeShared(includeTestingRecipe: includeTestingRecipe)
    }
    
    private static func makeShared(includeTestingRecipe: Bool = false) -> BackAppData {
        do {
            // Pick a folder for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)

            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") || includeTestingRecipe {
                try? fileManager.removeItem(at: folderURL)
            }
            
            // Create the database folder if needed
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let dbPool = try DatabasePool(path: dbURL.path)
            
            // Create the AppDatabase
            let appData = try BackAppData(dbPool)
            
            // adds to examples for new users when the user is new in the right language if it exists
            if Standarts.newUser, appData.allRecipes.isEmpty, let subdir = Bundle.main.preferredLocalizations.first, let urls = Bundle.main.urls(forResourcesWithExtension: "bakingAppRecipe", subdirectory: nil) {

                //filter the right files by the prefix which is eg. 1en
                _ = urls.filter({ $0.description.prefix(3).contains(subdir)}).map { appData.open($0)}
                Standarts.newUser = false
            }
            
            // Support for tests: add standart recipe to database if requested
            if CommandLine.arguments.contains("-includeTestingRecipe") || includeTestingRecipe {
                let recipeExample = Recipe.example
                var recipe = recipeExample.recipe
                
                appData.save(&recipe)
                
                let id = recipe.id!
                
                let stepIngredients = recipeExample.stepIngredients
                
                _ = stepIngredients.map {
                    var step = $0.step
                    step.recipeId = id
                    appData.save(&step)
                    
                    let stepId = step.id!
                    
                    for ingredient in $0.ingredients {
                        var ingredient = ingredient
                        ingredient.stepId = stepId
                        appData.save(&ingredient)
                    }
                }
            }
            
            return appData
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Creates an empty database for SwiftUI previews and other testing purposes
    static func empty() -> BackAppData {
        // Connect to an in-memory database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = DatabaseQueue()
        return try! BackAppData(dbQueue)
    }
    
}
