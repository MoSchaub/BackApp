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
public struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
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
    }
    
    ///id of the ingredient, is counted up incrementally
    public var id: Int
    
    /// name of the ingredient
    ///- NOTE: Should only be used when the name is modified. Use formattedNameInstead
    public var name: String
    
    /// temp the ingredient should have
    /// - NOTE: The temperature only has a value if the ingredient is a bulkLiquid
    public var temperature: Int?
    
    /// amount of the ingredient
    public var amount: Double
    
    ///speciphic temperature capacity of the ingredient
    private var c: Double
    
    /// the id of the step the ingredient is used for
    private var stepId: Int
    
}

public extension Ingredient {
    
    private struct Formatter {
        static public func formattedAmount(for amount: Double) -> String{
            if amount >= 1000{
                return "\(amount/1000)" + " Kg"
            } else if amount < 0.1, amount != 0 {
                return "\(amount * 1000)" + " mg"
            } else {
                return "\(amount)" + " g"
            }
        }
        
        static public func amountFactor(from rest: String) -> Double{
            let str = rest.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            switch str {
            case "kg": return 1000
            case "mg": return 0.001
            default: return 1
            }
        }
    }
    
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
        Formatter.formattedAmount(for: self.amount)
    }
    
    /// updates the amount
    mutating func formatted(rest: String) -> String{
        let previousFactor = Formatter.amountFactor(from: rest)
        self.amount *= previousFactor
        return self.formattedAmount
    }
    
    ///amount of the ingredient formatted with the right unit and scaled with the scale Factor provided by the recipe
    func scaledFormattedAmount(with factor: Double) -> String{
        Formatter.formattedAmount(for: self.amount * factor)
    }
    
    //initializer
    init(stepId: Int, id: Int, name: String, amount: Double, type: Style ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.c = type.rawValue
        self.stepId = stepId
    }
    
}

extension Ingredient: SqlableProtocol {
    
    // create columns for the sql database
    static let id = Column("id", .integer, PrimaryKey(autoincrement: true))
    static let name = Column("name", .text)
    static let temperature = Column("temperature", .integer)
    static let amount = Column("amount", .real)
    static let c = Column("c", .real)
    static let stepId = Column("stepId", .integer, ForeignKey<Step>())
    public static var tableLayout: [Column] = [id, name, temperature, amount, c]
    
    
    //get values from columns
    public func valueForColumn(_ column: Column) -> SqlValue? {
        switch column {
        case Ingredient.id:
            return self.id
        case Ingredient.name:
            return self.name
        case Ingredient.temperature:
            return self.temperature
        case Ingredient.amount:
            return self.amount
        case Ingredient.c:
            return self.c
        case Ingredient.stepId:
            return self.stepId
        default:
            return nil
        }
    }
    
    // init ingredient from database
    public init(row: ReadRow) throws {
        stepId = try row.get(Ingredient.stepId)
        id = try row.get(Ingredient.id)
        name = try row.get(Ingredient.name)
        temperature = try? row.get(Ingredient.temperature)
        amount = try row.get(Ingredient.amount)
        c = try row.get(Ingredient.c) ?? Style.other.rawValue
    }
}
