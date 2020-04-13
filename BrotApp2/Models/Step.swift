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
    
    //add logic for themperture calc for bulkliquids
    
    init(name: String, time: TimeInterval, ingredients: [Ingredient], themperature: Int) {
        id = UUID()
        self.time = time
        self.name = name
        self.ingredients = ingredients
        self.themperature = themperature
    }
    
    var formattedTime: String{
        "\(Int(time/60))" + "\(time == 60 ? " Minute" : " Minuten" )"
    }
    
    var formattedTemp: String{
        String(self.themperature) + " °C"
    }
    
    ///Themperature for bulk liquids so the step has the right Temperature
    func themperature(for bulkLiquid: Ingredient, roomThemperature: Int) -> Int {
        
        var summOfMassTempProductOfNonBulkLiquids = 0.0
        var totalAmount = 0.0
        for ingredient in self.ingredients{
            if !ingredient.isBulkLiquid{
                summOfMassTempProductOfNonBulkLiquids += ingredient.amount * Double(roomThemperature)
            }
            totalAmount += ingredient.amount
        }
        
        let diff = Double(self.themperature) * totalAmount - summOfMassTempProductOfNonBulkLiquids
        return Int( diff / bulkLiquid.amount)
    }
    
}