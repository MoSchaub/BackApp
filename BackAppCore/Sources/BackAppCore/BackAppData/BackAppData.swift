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
    
    private static func documentsPath() -> String {
        FileManager.default.documentsDirectory.path
    }
    
    ///the title of an alert displayed in the ui
    public var inputAlertTitle = ""
    
    ///the alert message for the same alert
    public var inputAlertMessage = ""
    
    public init(debug: Bool = false) {
        /// create new database or use the existing one if it exist in the documents directory
        do {
            if debug {
                _ = try? SqliteDatabase.deleteDatabase(at: Self.documentsPath() + "/db.sqlite")
            }
            self.database = try SqliteDatabase(filepath: Self.documentsPath() + "/db.sqlite")
        } catch {
            fatalError(error.localizedDescription)
        }
        
        do {
            try database.createTable(Recipe.self)
            try database.createTable(Step.self)
            try database.createTable(Ingredient.self)
        } catch {
            print(error.localizedDescription)
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
    
    ///generates a unique id for a new object in the database
    public func newId<T: BakingRecipeSqlable>(for type: T.Type) -> Int {
        var id = 0
        while objectsNotEmpty(with: id, on: type) {
            id = Int.random(in: 0..<Int.max)
        }
        return id
    }
    
    ///inserts a given object into the database
    ///if it already exists nothing happens
    /// - returns: wether  it succeded
    public func insert<T:BakingRecipeSqlable>(_ object: T) -> Bool {
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
    public func update<T:BakingRecipeSqlable>(_ object: T) -> Bool {
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
    public func delete<T:BakingRecipeSqlable>(_ object: T) -> Bool {
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
    
    public func object<T:BakingRecipeSqlable>(with id: Int, of Type: T.Type = T.self) -> T? {
        ((try? T.read().filter(T.id == id).run(database)) ?? []).first
    }
    
    /// do something if a specified table in the database updates
    public func observeChange<T:BakingRecipeSqlable>(of type: T.Type, do something: @escaping (Int) -> Void ) {
        database.observe(on: type, doThis: something)
    }
    
}
