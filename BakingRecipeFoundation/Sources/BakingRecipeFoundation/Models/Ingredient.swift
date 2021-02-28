//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings
import Sqlable

///Ingredient in the Recipe
public struct Ingredient: Equatable, BakingRecipeSqlable {
    
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
        
        public func massOfSelfIngredients(in step: Step, db: SqliteDatabase) -> Double {
            var mass = 0.0
            _ = step.ingredients(db: db).filter { $0.type == self }.map { mass += $0.mass}
            return mass
        }
    }
    
    ///id of the ingredient, is counted up incrementally
    public var id: Int
    
    /// name of the ingredient
    ///- NOTE: Should only be used when the name is modified. Use formattedNameInstead
    public var name: String
    
    /// temp the ingredient should have
    /// - NOTE: The temperature only has a value if the ingredient is a bulkLiquid
    public var temperature: Int?
    
    /// mass of the ingredient
    public var mass: Double
    
    ///speciphic temperature capacity of the ingredient
    private var c: Double
    
    /// the id of the step the ingredient is used for
    public var stepId: Int
    
    /// the number in a step used for sorting the ingredient
    public var number: Int
    
}

public extension Ingredient {
    
    /// the name of the ingredient
    ///- NOTE: This name should be used whenever you need to only show the name
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedIngredient : name
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
        MassFormatter.formattedMass(for: self.mass)
    }
    
    /// updates the amount
    mutating func formatted(rest: String) -> String{
        let previousFactor = MassFormatter.massFactor(from: rest)
        self.mass *= previousFactor
        return self.formattedAmount
    }
    
    ///amount of the ingredient formatted with the right unit and scaled with the scale Factor provided by the recipe
    func scaledFormattedAmount(with factor: Double) -> String{
        MassFormatter.formattedMass(for: self.mass * factor)
    }
    
    var massCProduct: Double {
        mass * c
    }
    
    func massCTempProduct(roomTemp: Double) -> Double {
        let temp = self.temperature == nil ? roomTemp : Double(self.temperature!)
        return self.massCProduct * temp
    }
    
    //initializer
    init(stepId: Int, id: Int, name: String = "", amount: Double = 0, type: Style = .other, number: Int) {
        self.id = id
        self.name = name
        self.mass = amount
        self.c = type.rawValue
        self.stepId = stepId
        self.number = number
    }
    
}

public extension Ingredient{
    
    // create columns for the sql database
    static let id = Column("id", .integer, PrimaryKey(autoincrement: true))
    static let name = Column("name", .text)
    static let temperature = Column("temperature", .nullable(.integer))
    static let mass = Column("mass", .real)
    static let c = Column("c", .real)
    static let stepId = Column("stepId", .integer, ForeignKey<Step>(onDelete: .cascade, onUpdate: .ignore))
    static let number = Column("number", .integer)
    static var tableLayout: [Column] = [id, name, temperature, mass, c, stepId, number]
    
    
    //get values from columns
    func valueForColumn(_ column: Column) -> SqlValue? {
        switch column {
        case Ingredient.id:
            return self.id
        case Ingredient.name:
            return self.name
        case Ingredient.temperature:
            return self.temperature == nil ? Null() : self.temperature!
        case Ingredient.mass:
            return self.mass
        case Ingredient.c:
            return self.c
        case Ingredient.stepId:
            return self.stepId
        case Ingredient.number:
            return self.number
        default:
            return nil
        }
    }
    
    // init ingredient from database
    init(row: ReadRow) throws {
        stepId = try row.get(Ingredient.stepId)
        id = try row.get(Ingredient.id)
        name = try row.get(Ingredient.name)
        temperature = try? row.get(Ingredient.temperature)
        mass = try row.get(Ingredient.mass)
        c = try row.get(Ingredient.c) ?? Style.other.rawValue
        number = try row.get(Ingredient.number)
    }
}