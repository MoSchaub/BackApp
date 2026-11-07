// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
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
    
    public static func shared(includeTestingRecipe: Bool = false, resetDatabase: Bool = false) -> BackAppData {
        return makeShared(includeTestingRecipe: includeTestingRecipe, resetDatabase: resetDatabase)
    }
    
    private static func makeShared(includeTestingRecipe: Bool = false, resetDatabase: Bool = false) -> BackAppData {
        do {
            // Pick a folder for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            
            // Create the database folder if needed
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            // Wait instead of failing with SQLITE_BUSY when several connections
            // (app + tests, or multiple shared() calls) access the same file.
            var configuration = Configuration()
            configuration.busyMode = .timeout(5)
            let dbPool = try DatabasePool(path: dbURL.path, configuration: configuration)
            
            // Create the AppDatabase
            let appData = try BackAppData(dbPool)
            
            // adds the bundled example recipes for new users in their language (falls back to english)
            if Standarts.newUser, appData.allRecipes.isEmpty {
                importBundledExampleRecipes(into: appData)
                Standarts.newUser = false
            }

            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") || includeTestingRecipe || resetDatabase {
                try? appData.deleteAll(of: Recipe.self)
            }
            
            // Support for tests: add standart recipe to database if requested
            if CommandLine.arguments.contains("-includeTestingRecipe") || includeTestingRecipe {
                let recipeExample = Recipe.example
                var recipe = recipeExample.recipe
                
                appData.insert(&recipe)
                
                let id = recipe.id!
                
                let stepIngredients = recipeExample.stepIngredients
                
                _ = stepIngredients.map {
                    var step = $0.step
                    step.recipeId = id
                    appData.insert(&step)
                    
                    let stepId = step.id!
                    
                    for ingredient in $0.ingredients {
                        var ingredient = ingredient
                        ingredient.stepId = stepId
                        appData.insert(&ingredient)
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
    
    /// The bundled example recipe files for a language.
    /// The files are named like `1en.bakingAppRecipe`, so the language code follows the leading digit.
    static func bundledExampleRecipeURLs(for language: String, in bundle: Bundle = .main) -> [URL] {
        let urls = bundle.urls(forResourcesWithExtension: "bakingAppRecipe", subdirectory: nil) ?? []
        return urls
            .filter { $0.lastPathComponent.dropFirst().hasPrefix(language) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    /// Imports the bundled example recipes in the preferred language of the app,
    /// or in english if there are no examples for that language.
    static func importBundledExampleRecipes(into appData: BackAppData, bundle: Bundle = .main) {
        let preferred = bundle.preferredLocalizations.first ?? "en"
        var urls = bundledExampleRecipeURLs(for: preferred, in: bundle)
        if urls.isEmpty {
            urls = bundledExampleRecipeURLs(for: "en", in: bundle)
        }
        urls.forEach { appData.open($0) }
    }

    /// Creates an empty database for SwiftUI previews and other testing purposes
    static func empty() -> BackAppData {
        // Connect to an in-memory database
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
        let dbQueue = try! DatabaseQueue()
        return try! BackAppData(dbQueue)
    }
    
}
