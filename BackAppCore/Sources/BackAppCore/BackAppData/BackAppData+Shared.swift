//
//  BackAppData+Shared.swift
//  
//
//  Created by moritz on 04.06.21.
//

import GRDB
import Foundation

extension BackAppData {
    public static let shared = makeShared()
    
    private static func makeShared() -> BackAppData {
        do {
            // Pick a folder for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)

            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") {
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
            
            // adds to examples for new users when the user is new
            if Standarts.newUser, appData.allRecipes.isEmpty {
                let urls = Bundle.main.urls(forResourcesWithExtension: "bakingAppRecipe", subdirectory: nil)!//url(forResource: nil, withExtension: "bakingAppRecipe")
                _ = urls.map { appData.open($0)}
                Standarts.newUser = false
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
