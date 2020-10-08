//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    public var id: String
    
    public var name: String
    
    public var themperature: Int?
    
    public var amount: Double
    
    public var isBulkLiquid: Bool
    
    public var formattedAmount: String{
        Self.formattedAmount(for: self.amount)
    }
    
    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamedIngredient", comment: "") : name
    }
    
    mutating public func formatted(rest: String) -> String{
        let previousFactor = amountFactor(from: rest)
        self.amount *= previousFactor
        return self.formattedAmount
    }
    
    static public func formattedAmount(for amount: Double) -> String{
        if amount >= 1000{
            return "\(amount/1000)" + " Kg"
        } else if amount < 0.1, amount != 0 {
            return "\(amount * 1000)" + " mg"
        } else {
            return "\(amount)" + " g"
        }
    }
    
    private func amountFactor(from rest: String) -> Double{
        let str = rest.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .whitespacesAndNewlines)
        switch str {
        case "Kg": return 1000
        case "kg": return 1000
        case "mg": return 0.001
        default: return 1
        }
    }
    
    public func scaledFormattedAmount(with factor: Double) -> String{
        Self.formattedAmount(for: self.amount * factor)
    }
    
    public init(name: String, amount: Double, isBulkLiquid: Bool = false) {
        self.id = UUID().uuidString
        self.name = name
        self.amount = amount
        self.isBulkLiquid = isBulkLiquid
    }
    
    enum CodingKeys: CodingKey{
        case name
        case amount
        case isBulkLiquid
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.isBulkLiquid = try container.decode(Bool.self, forKey: .isBulkLiquid)
    }
    
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.amount == rhs.amount &&
            lhs.isBulkLiquid == rhs.isBulkLiquid
    }
}


