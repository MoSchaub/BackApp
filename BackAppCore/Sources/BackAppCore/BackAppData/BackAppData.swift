//
//  BackAppData.swift
//  
//
//  Created by Moritz Schaub on 21.12.20.
//

import GRDB
import Foundation
import BakingRecipeFoundation

public extension Database.ColumnType {
    static let real = Database.ColumnType.init(rawValue: "REAL")
}

public struct BackAppData {
    
    
    /// Creates an `BackAppData`, and make sure the database schema is ready.
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
    internal let dbWriter: DatabaseWriter
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        ///define the schema
        migrator.registerMigration("migration") { db in
            try db.create(table: "Recipe") { t in
                t.autoIncrementedPrimaryKey(Recipe.Columns.id.name)
                t.column(Recipe.Columns.name.name, .text).notNull().defaults(to: "")
                t.column(Recipe.Columns.info.name, .text).notNull().defaults(to: "")
                t.column(Recipe.Columns.isFavorite.name, .boolean).notNull().defaults(to: false)
                t.column(Recipe.Columns.difficulty.name, .integer ).notNull().defaults(to: 0)
                t.column(Recipe.Columns.inverted.name, .boolean).notNull().defaults(to: false)
                t.column(Recipe.Columns.times.name, .real)
                t.column(Recipe.Columns.date.name, .datetime).notNull().defaults(to: Date())
                t.column(Recipe.Columns.imageData.name, .blob)
                t.column(Recipe.Columns.number.name, .integer).notNull()
            }
            
            try db.create(table: "Step") { t in
                t.autoIncrementedPrimaryKey(Step.Columns.id.name)
                t.column(Step.Columns.name.name, .text).notNull().defaults(to: "")
                t.column(Step.Columns.duration.name, .double).notNull().defaults(to: 60)
                t.column(Step.Columns.temperature.name, .double)
                t.column(Step.Columns.notes.name, .text).notNull().defaults(to: "")
                t.column(Step.Columns.recipeId.name, .integer).references("Recipe", onDelete: .cascade)
                t.column(Step.Columns.superStepId.name, .integer).references("Step")
                t.column(Step.Columns.number.name, .integer).notNull()
            }
            
            try db.create(table: "Ingredient") { t in
                t.autoIncrementedPrimaryKey(Ingredient.Columns.id.name)
                t.column(Ingredient.Columns.name.name, .text).notNull().defaults(to: "")
                t.column(Ingredient.Columns.temperature.name, .double)
                t.column(Ingredient.Columns.mass.name, .double).notNull().defaults(to: 0)
                t.column(Ingredient.Columns.c.name, .double)
                t.column(Ingredient.Columns.stepId.name, .integer).references("Step", onDelete: .cascade)
                t.column(Ingredient.Columns.number.name, .integer).notNull()
            }
        }
        return migrator
    }
}

//TODO: Testing funcs

// MARK: - Database Access: Writes
public extension BackAppData {
    
    /// Saves (inserts or updates) a record. When the method returns, the
    /// record is present in the database, and its id is not nil.
    func save<T:BakingRecipeRecord>(_ record: inout T) {
        do {
            try dbWriter.write { db in
                return try record.save(db)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
        
        if record is Recipe, !databaseAutoUpdatesDisabled {
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
        }
    }
    
    /// updates a record
    func update<T:BakingRecipeRecord>(_ record: T, completion: ((Error?) -> Void)? = nil) {
        do {
            try dbWriter.write { db in
                try record.update(db)
            }
            if let completion = completion {
                completion(nil)
            }
            //completion(nil)
        } catch {
            print(error.localizedDescription)
            if let completion = completion {
                completion(error)
            }
        }
    }
    
    /// delete the specified record and returns wether the deletion was succesfull
    func delete<T:BakingRecipeRecord>(_ record: T) -> Bool {
        do {
            return try dbWriter.write { db in
                try T.deleteOne(db, key: ["id" : record.id])
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    internal func deleteAll<T:BakingRecipeRecord>(of type: T.Type) throws {
        _ = try dbWriter.write { db in
            try T.deleteAll(db)
        }
    }
    
    /// move Records (change their number) so their sorted order changes
    internal func moveRecord<T: BakingRecipeRecord>(in array: [T] ,from source: Int, to destination: Int) {
        DispatchQueue.global(qos: .background).async {
            databaseAutoUpdatesDisabled = true
            var recordIds = array.map { $0.id }
            
            let removedRecord = recordIds.remove(at: source)
            recordIds.insert(removedRecord, at: destination)
            
            var number = 0
            for id in recordIds {
                var record: T = self.record(with: id!)!
                record.number = number
                number += 1
                self.save(&record)
            }
            databaseAutoUpdatesDisabled = false
        }
    }
}


// MARK: - Database Access: Reads

public extension BackAppData {
    /// Provides a read-only access to the database
    var databaseReader: DatabaseReader {
        dbWriter
    }
    
    /// fetch a record from a database
    func record<T:BakingRecipeRecord>(with id: Int64, of type: T.Type = T.self) -> T? {
        return try? databaseReader.read { db in
            return try? T.all().filter(key: ["id":id]).fetchOne(db)
        }
    }
    
    /// all Records of a specified type in the database
    func allRecords<T:BakingRecipeRecord>(of type: T.Type = T.self) -> [T] {
        (try? databaseReader.read { try? T.fetchAll($0)}) ?? []
    }
}
