//
//  Ingredient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    var id: UUID{
        UUID()
    }
    
    var name: String
    
    var themperature: Int?
    
    var amount: Double
    
    var isBulkLiquid: Bool
    
    var formattedAmount: String{
        formattedAmount(for: self.amount)
    }
    
    mutating func formatted(rest: String) -> String{
        let previousFactor = amountFactor(from: rest)
        self.amount *= previousFactor
        return self.formattedAmount
    }
    
    private func formattedAmount(for amount: Double) -> String{
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
        case "mg": return 0.001
        default: return 1
        }
    }
    
    func scaledFormattedAmount(with factor: Double) -> String{
        self.formattedAmount(for: self.amount * factor)
    }
    
    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
        self.isBulkLiquid = false
    }
}


