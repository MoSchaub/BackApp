//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    var id: String
    
    var name: String
    
    var themperature: Int?
    
    var amount: Double
    
    var isBulkLiquid: Bool
    
    var formattedAmount: String{
        Self.formattedAmount(for: self.amount)
    }
    
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamedIngredient", comment: "") : name
    }
    
    mutating func formatted(rest: String) -> String{
        let previousFactor = amountFactor(from: rest)
        self.amount *= previousFactor
        return self.formattedAmount
    }
    
    static func formattedAmount(for amount: Double) -> String{
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
    
    func scaledFormattedAmount(with factor: Double) -> String{
        Self.formattedAmount(for: self.amount * factor)
    }
    
    init(name: String, amount: Double, isBulkLiquid: Bool = false) {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.isBulkLiquid = try container.decode(Bool.self, forKey: .isBulkLiquid)
    }
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.amount == rhs.amount &&
            lhs.isBulkLiquid == rhs.isBulkLiquid
    }
}


