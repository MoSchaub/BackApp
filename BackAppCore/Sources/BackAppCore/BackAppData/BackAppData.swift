//
//  BackAppData.swift
//  
//
//  Created by Moritz Schaub on 21.12.20.
//

import Sqlable
import Foundation
import BakingRecipeFoundation



public class BackAppData {
    
    private(set) internal var database: SqliteDatabase
    
    public init() {
        /// create new database or use the existing one if it exist in the documents directory
        do {
            self.database = try SqliteDatabase(filepath: FileManager.default.documentsDirectory.path + "db.sqlite")
            try database.createTable(Recipe.self)
            try database.createTable(Step.self)
            try database.createTable(Ingredient.self)
        } catch {
            fatalError(error.localizedDescription)
        }

    }
    
    //MARK: - CUD Operations
    //C: Create, U: Update, D: Delete
    
    ///helper method for cud operations
    internal func objectsNotEmpty<T: BakingRecipeSqlable>(with objectId: Int, on type: T.Type = T.self) -> Bool {
        guard let results = try? T.read().filter(T.id == objectId).run(database) else {
            return false
        }
        
        return !results.isEmpty
    }
    
    ///inserts a given object into the database
    ///if it already exists nothing happens
    /// - returns: wether  it succeded
    func insert<T:BakingRecipeSqlable>(_ object: T) -> Bool {
        if objectsNotEmpty(with: object.id, on: T.self) {
            //the object already exists: Do nothing!
            return false
        } else {
            //object does not exist yet: Try inserting it!
            do {
                try object.insert().run(database)
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            //success
            return true
        }
    }
    
    ///updates object in the database if it does not exists it gets inserted
    func update<T:BakingRecipeSqlable>(_ object: T) -> Bool {
        if objectsNotEmpty(with: object.id, on: T.self) {
            //found the object in the database: Try updating it!
            do {
                try object.update().run(database)
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            //succes
            return true
        } else {
            //the object does not exist: Insert it!
            return self.insert(object)
        }
    }
    
    ///deletes an object if present from the database
    func delete<T:BakingRecipeSqlable>(_ object: T) -> Bool {
        if objectsNotEmpty(with: object.id, on: T.self) {
            //found the object in the database: Try deleting it!
            do {
                try object.delete().run(database)
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            //succes
            return true
        } else {
            //the object does not exist: Do nothing!
            return false
        }
    }
}
