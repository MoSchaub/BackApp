//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings
import GRDB

///Ingredient in the Recipe
public struct Ingredient: BakingRecipeRecord {
    
    /// diffrent styles of ingredients
    /// - NOTE: raw value is their c
    public enum Style: Double, CaseIterable, Codable {
        
        /// water or something similar
        case bulkLiquid = 4.187
        
        /// some kind of flour
        case flour = 1.465
        
        /// starter around 50% hydration
        case ta150 = 1.5
        
        /// starter with around 100% hydration
        case ta200 = 2.0
        
        /// other ingredients
        case other = 1.0 //to be changed
        
        public var name: String {
            switch self {
            case .bulkLiquid: return Strings.bulkLiquid
            case .flour: return Strings.flour
            case .ta150: return Strings.ta150
            case .ta200: return Strings.ta200
            case .other: return Strings.other
            }
        }
        
        public func massOfSelfIngredients(in step: Step, reader: DatabaseReader) -> Double {
            var mass = 0.0
            _ = step.ingredients(reader: reader).filter { $0.type == self }.map { mass += $0.mass}
            return mass
        }

        public func massOfSelfIngredients(in step: Step, db: Database) throws -> Double {
            var mass = 0.0
            _ = try step.ingredients(db: db).filter { $0.type == self }.map { mass += $0.mass }
            return mass
        }
    }
    
    ///id of the ingredient, is counted up incrementally
    ///optional so that you can instantiate a record before it gets inserted and gains an id (by `didInsert(with:for:)`)
    public var id: Int64?
    
    /// name of the ingredient
    ///- NOTE: Should only be used when the name is modified. Use formattedNameInstead
    public var name: String {
        didSet {
            autoDetectIngredientType()
        }
    }
    
    /// temp the ingredient should have
    /// - NOTE: The temperature only has a value if the ingredient is a bulkLiquid
    public var temperature: Double?
    
    /// mass of the ingredient
    public var mass: Double
    
    ///speciphic temperature capacity of the ingredient
    private var c: Double
    
    /// the id of the step the ingredient is used for
    public var stepId: Int64
    
    /// the number in a step used for sorting the ingredient
    public var number: Int
    
}

// MARK: - Auto ingredient type detection
private extension Ingredient {
    
    mutating func autoDetectIngredientType() {
        if Bundle.main.preferredLocalizations.first! == "de" || Bundle.main.preferredLocalizations.first! == "en" { //only german locale at first
            
            let flourStrings = Bundle.main.preferredLocalizations.first! == "de" ? ["Mehl", "mehl", "Schrot", "schrot", "WM", "RM", "DM", "RVKM", "WVKM", "Typo", "typo"] : ["flour", "Flour", "grist", "Grist"]
            let bulkLiquidStrings = Bundle.main.preferredLocalizations.first! == "de" ? ["Wasser", "wasser", "Milch", "milch", "Bier", "bier", "Öl", "öl", "saft", "Saft", " ei", "Ei "] : ["water", "Water", "milk", "Milk", "beer", "Beer", "oil", "Oil", "juice", "Juice", "egg", "Egg "]
            
            for flourString in flourStrings {
                if self.name.contains(flourString) {
                    self.type = .flour
                    return
                }
            }
            
            for bulkLiquidString in bulkLiquidStrings {
                if self.name.contains(bulkLiquidString) {
                    self.type = .bulkLiquid
                    return
                }
            }
        }
    }
    
}

public extension Ingredient {
    
    /// the name of the ingredient
    ///- NOTE: This name should be used whenever you need to only show the name
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedIngredient : name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// type of the recipe
    var type: Style {
        get{
            return Style.allCases.first(where: {$0.rawValue == self.c} ) ?? Style.other
        }
        set {
            self.c = newValue.rawValue
        }
    }
    
    ///amount of the ingredient formatted with the right unit
    var formattedAmount: String{
        self.mass.formattedMass
    }
    
    /// formatts the amount (used to update the amount)
    mutating func formatted(rest: String) -> String{
        return self.formattedAmount
    }
    
    ///amount of the ingredient formatted with the right unit and scaled with the scale Factor provided by the recipe
    func scaledFormattedAmount(with factor: Double) -> String{
        (self.mass * factor).formattedMass
    }
    
    var massCProduct: Double {
        mass * c
    }
    
    func massCTempProduct(roomTemp: Double) -> Double {
        let temp = self.temperature == nil ? roomTemp : Double(self.temperature!)
        return self.massCProduct * temp
    }
    
    //initializer
    init(stepId: Int64, name: String = "", amount: Double = 0, type: Style = .other, number: Int) {
        self.name = name
        self.mass = amount
        self.c = type.rawValue
        self.stepId = stepId
        self.number = number
    }
    
}

// SQL generation
public extension Ingredient {
    /// the table columns
    enum Columns{
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let temperature = Column(CodingKeys.temperature)
        public static let mass = Column(CodingKeys.mass)
        public static let c = Column(CodingKeys.c)
        public static let stepId = Column(CodingKeys.stepId)
        public static let number = Column(CodingKeys.number)
    }
    
    /// Arange the seleted columns and lock their order
    static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.temperature,
        Columns.mass,
        Columns.c,
        Columns.stepId,
        Columns.number
    ]
}

// Fetching methods
public extension Ingredient {
    /// creates a record from a database row
    init(row: Row) {
        /// For high performance, use numeric indexes that match the
        /// order of `Ingredient.databaseSelection`
        id = row[0]
        name = row[1]
        temperature = row[2]
        mass = row[3]
        c = row[4]
        stepId = row[5]
        number = row[6]
    }
}

// Persistence methods
public extension Ingredient {
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.temperature] = temperature
        container[Columns.mass] = mass
        container[Columns.c] = c
        container[Columns.stepId] = stepId
        container[Columns.number] = number
    }
    
    /// Update auto-increment id upon successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
}

// MARK: - Ingredient Database Requests

/// Define some ingredient requests used by the application.
extension DerivableRequest where RowDecoder == Ingredient {
    // A request of ingredients with a stepId ordered by number in ascending order.
    ///
    /// For example:
    ///
    ///     let ingredients: [Ingredient] = try dbWriter.read { db in
    ///         try Ingredient.all().orderedByNumber().fetchAll(db)
    ///     }
    public func orderedByNumber(with stepId: Int64) -> Self {
        filter(by: stepId)/// filter stepid
            .order(Ingredient.Columns.number) // sort by number in ascending order (asc is the default)
    }
    
    private func filter(by stepId: Int64) -> Self {
        filter(Ingredient.Columns.stepId == stepId) /// filter stepId
    }
}

//MARK: - Associations
public extension Ingredient {
    static let step = belongsTo(Step.self)
}
