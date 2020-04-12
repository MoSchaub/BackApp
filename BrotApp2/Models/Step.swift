//
//  Step.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

struct Step: Equatable, Identifiable, Hashable, Codable {

    var id: UUID
    
    var time : TimeInterval
    
    var name: String
    
    var ingredients: [Ingredient]
    
    var themperature = 20
    
    //add logic for themperture calc for bulkliquids
    
    init(name: String, time: TimeInterval, ingredients: [Ingredient]) {
        id = UUID()
        self.time = time
        self.name = name
        self.ingredients = ingredients
    }
    
    var formattedTime: String{
        "\(Int(time/60))" + "\(time == 60 ? " Minute" : " Minuten" )"
    }
    
}

struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    var id: UUID
    
    var name: String
    
    var themperature: Int?
    
    var amount: Double
    
    var isBulkLiquid: Bool
    
    
    mutating func formatted(rest: String) -> String{
        let previousFactor = factor(from: rest)
        self.amount *= previousFactor
        if self.amount >= 1000{
            return "\(self.amount/1000)" + " Kg"
        } else if amount < 0.1{
            return "\(self.amount * 1000)" + " mg"
        } else {
            return "\(self.amount)" + " g"
        }
    }
    
    func factor(from rest: String) -> Double{
        let str = rest.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .whitespacesAndNewlines)
        switch str {
        case "Kg": return 1000
        case "mg": return 0.001
        default: return 1
        }
    }
    
    init(name: String, amount: Double) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.isBulkLiquid = false
    }
}
