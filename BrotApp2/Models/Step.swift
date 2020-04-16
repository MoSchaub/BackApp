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
    
    var themperature : Int
    
    var notes: String
    
    var subSteps: [Step]
    
    init(name: String, time: TimeInterval, ingredients: [Ingredient], themperature: Int) {
        id = UUID()
        self.time = time
        self.name = name
        self.ingredients = ingredients
        self.themperature = themperature
        self.notes = ""
        self.subSteps = []
    }
    
    var formattedTime: String{
        "\(Int(time/60))" + "\(time == 60 ? " Minute" : " Minuten" )"
    }
    
    var formattedTemp: String{
        String(self.themperature) + " °C"
    }
    
    var totalAmount: Double{
        var amount = 0.0
        for ingredient in self.ingredients{
            amount += ingredient.amount
        }
        return amount
    }
    
    ///Themperature for bulk liquids so the step has the right Temperature
    func themperature(for bulkLiquid: Ingredient, roomThemperature: Int) -> Int {
        
        var summOfMassTempProductOfNonBulkLiquids = 0.0
        
        for ingredient in self.ingredients{
            if !ingredient.isBulkLiquid{
                summOfMassTempProductOfNonBulkLiquids += ingredient.amount * Double(roomThemperature)
            }
        }
        var totalAmount = self.totalAmount
        for step in self.subSteps{
            summOfMassTempProductOfNonBulkLiquids += step.totalAmount * Double(step.themperature)
            totalAmount += step.totalAmount
        }
        
        let diff = Double(self.themperature) * totalAmount - summOfMassTempProductOfNonBulkLiquids
        return Int( diff / bulkLiquid.amount)
    }
    
    func text(startDate: Date, roomTemp: Int, scaleFactor: Double) -> String{
        var text = ""
        text += "\(self.name) am \(dateFormatter.string(from: startDate))"
        text += "\n"
        
        for ingredient in self.ingredients{
            text += ingredient.name + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) + "\(ingredient.isBulkLiquid ? String(self.themperature(for: ingredient, roomThemperature: roomTemp)) + "° C" : "" )"
            text += "\n"
        }
        for subStep in self.subSteps{
            text += subStep.name + ": " + "\(self.totalAmount)" + "\(subStep.themperature)" + "° C"
            text += "\n"
        }
        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            text += self.notes
            text += "\n"
        }
        return text
    }
    
}
