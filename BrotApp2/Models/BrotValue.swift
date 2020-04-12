//
//  BrotValue.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

struct BrotValue: Equatable, Identifiable, Hashable, Codable {

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
    
    init(name: String, amount: Double) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.isBulkLiquid = false
    }
}
