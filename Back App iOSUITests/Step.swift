//
//  Step.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

public struct Step: Equatable, Identifiable, Hashable, Codable {

    public var id: UUID
    
    public var time : TimeInterval
    
    public var name: String
    
    public var ingredients: [Ingredient]
    
    public var temperature : Int
    
    public var notes: String
    
    public var subSteps: [Step]
    
    public var isDynamicTemperature: Bool {
        willSet {
            secondTemp = temperature
        }
    }
    
    public var secondTemp: Int
    
    public init(name: String = "", time: TimeInterval = 60, ingredients: [Ingredient] = [], themperature: Int = 20, notes: String = "") {
        self.id = UUID()
        self.time = time
        self.name = name
        self.ingredients = ingredients
        self.temperature = themperature
        self.notes = notes
        self.subSteps = []
        self.isDynamicTemperature = false
        self.secondTemp = temperature
    }
    
    public var formattedTime: String{
        "\(Int(time/60))" + " " + (time == 60 ? NSLocalizedString("minute", comment: "") : NSLocalizedString("minutes", comment: "")) 
    }
    
    public var formattedTemp: String{
        if isDynamicTemperature {
            return "\(NSLocalizedString("start", comment: "")): \(temperature) ºC, \(NSLocalizedString("end", comment: "")): \(secondTemp) °C"
        } else {
            return String(self.temperature) + " °C"
        }
    }
    
    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamedStep", comment: "") : name
    }
    
    public var totalAmount: Double{
        var amount = 0.0
        for ingredient in self.ingredients{
            amount += ingredient.amount
        }
        for substep in self.subSteps {
            amount += substep.totalAmount
        }
        return amount
    }
    
    public var totalFormattedAmount: String{
        Ingredient.formattedAmount(for: self.totalAmount)
    }
    
    
    ///Themperature for bulk liquids so the step has the right Temperature
    public func themperature(for bulkLiquid: Ingredient, roomThemperature: Int) -> Int {
        
        var summOfMassTempProductOfNonBulkLiquids = 0.0
        
        for ingredient in self.ingredients{
            if !ingredient.isBulkLiquid{
                summOfMassTempProductOfNonBulkLiquids += ingredient.amount * Double(roomThemperature)
            }
        }
        var totalAmount = self.totalAmount
        for substep in subSteps{
            summOfMassTempProductOfNonBulkLiquids += substep.totalAmount * Double(isDynamicTemperature ? substep.secondTemp : substep.temperature)
            totalAmount += substep.totalAmount
        }
        
        let diff = Double(self.temperature) * totalAmount - summOfMassTempProductOfNonBulkLiquids
        if bulkLiquid.amount != 0{
            return Int( diff / bulkLiquid.amount)
        } else {
            return roomThemperature
        }
        
    }
    
    public func text(startDate: Date, roomTemp: Int, scaleFactor: Double) -> String{
        var text = ""
        
        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
        text.append(nameString)
        
        for ingredient in self.ingredients{
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.isBulkLiquid ? String(self.themperature(for: ingredient, roomThemperature: roomTemp)) + "° C" : "" )" + "\n"
            text.append(ingredientString)
        }
        for subStep in self.subSteps{
            let substepString = subStep.formattedName + ": " + "\(self.totalAmount)" + "\(subStep.temperature)" + "° C\n"
            text.append(substepString)
        }
        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            text.append(self.notes + "\n")
        }
        return text
    }
    
    //MARK: init from Json and ==
    
    enum CodingKeys: CodingKey{
        case time
        case name
        case ingredients
        case temperature
        case notes
        case subSteps
        case isDynamicTemperature
        case secondTemp
        case id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.time = try container.decode(TimeInterval.self, forKey: .time)
        self.name = try container.decode(String.self, forKey: .name)
        self.ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        self.temperature = try container.decode(Int.self, forKey: .temperature)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.subSteps = try container.decode([Step].self, forKey: .subSteps)
        self.isDynamicTemperature = try container.decode(Bool.self, forKey: .isDynamicTemperature)
        self.secondTemp = try container.decode(Int.self, forKey: .secondTemp)
    }
    
    public static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs.name == rhs.name &&
            lhs.time == rhs.time &&
            lhs.ingredients == rhs.ingredients &&
            lhs.temperature == rhs.temperature &&
            lhs.notes == rhs.notes &&
            lhs.subSteps == rhs.subSteps &&
            lhs.isDynamicTemperature == rhs.isDynamicTemperature &&
            lhs.secondTemp == rhs.secondTemp
    }

}
