//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings

public struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    public enum Style: Double, CaseIterable, Codable {
        
        case bulkLiquid = 4.187
        case flour = 1.465
        case ta150 = 1.5
        case ta200 = 2.0
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
    
    public var id: String
    
    public var name: String
    
    public var themperature: Int?
    
    public var amount: Double
    
    public var type: Style
    
    public var formattedAmount: String{
        Self.formattedAmount(for: self.amount)
    }
    
    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedIngredient : name
    }
    
    public var c: Double {
        type.rawValue
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
    
    public init(name: String, amount: Double, type: Style ) {
        self.id = UUID().uuidString
        self.name = name
        self.amount = amount
        self.type = type
    }
    
    enum CodingKeys: CodingKey{
        case name
        case amount
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.type = try container.decodeIfPresent(Style.self, forKey: .type) ?? .other
    }
    
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.amount == rhs.amount &&
        lhs.type == rhs.type
    }
}


