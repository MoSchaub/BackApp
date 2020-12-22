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
    
    init() {
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
    
    static public var standard = BackAppData()
}
