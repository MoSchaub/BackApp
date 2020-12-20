//
//  Step.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings
import Sqlable

public struct Step: Equatable, Identifiable, Hashable, Codable {
    
    /// id of the step
    public var id: Int
    public var name: String
    public var duration: TimeInterval
    public var temperature: Int
    public var notes: String
    public var recipeId: Int
    public var superStepId: Int?
    
    
    public init(id: Int, name: String = "", duration: TimeInterval = 60, themperature: Int = 20, notes: String = "", superStepId: Int? = nil, recipeId: Int) {
        self.id = id
        self.name = name
        self.duration = duration
        self.temperature = themperature
        self.notes = notes
        self.superStepId = superStepId
        self.recipeId = recipeId
    }
    
}

public extension Step {
    
//    private var ingredients: [Ingredient] {
//        return (try? Ingredient.read().filter(Ingredient.stepId == self.id).run(database)) ?? []
//    }
//
//    private var substeps: [Step] {
//        return (try? Step.read().filter(Step.superStepId == self.id).run(database)) ?? []
//    }
    
    // the duration of the step formatted with the right unit
    var formattedDuration: String{
        Int(duration/60).formattedDuration
    }
    
    /// the temperature of the step formatted with Celsius
    var formattedTemp: String{
        return String(self.temperature) + " °C"
    }
    
    /// name of the step
    ///- NOTE:should be used for displaying the name. For changing the name use name instead
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedStep : name
    }
    
//    /// the mass of all Ingredients and Substeps to this step in a given database
//    var totalMass: Double{
//        var mass = 0.0
//
//        for ingredient in ingredients{
//            mass += ingredient.mass
//        }
//        for substep in substeps {
//            mass += substep.totalMass
//        }
//
//        return mass
//    }
//
//    /// the mass of all ingredients and substeps formatted with the right unit
//    var totalFormattedMass: String {
//        MassFormatter.formattedMass(for: self.totalMass)
//    }
    
//    ///Themperature for bulk liquids so the step has the right Temperature
//    func themperature(for ingredient: Ingredient, roomThemperature: Int) -> Int {
//
//        let sumMassCProductAll = self.sumMassCProduct(data: ingredients.map { ($0.amount, $0.c)} + subSteps.map { ($0.totalAmount, $0.c)} )
//        let tKnet = 0
//        let sumMassCProductRest = sumMassCTempProduct(data: ingredients.filter { $0 != ingredient }.map { ($0.amount, $0.c, Double(roomThemperature)) } + subSteps.map { ($0.totalAmount, $0.c, Double($0.temperature))})
//        return Int(((sumMassCProductAll * Double(self.temperature - tKnet)) - sumMassCProductRest)/(ingredient.amount * ingredient.c))
//    }
    
    
//    private var c: Double{
//        let percentageFlour = flourAmount/totalAmount
//        let percentageWater = waterAmount/totalAmount
//        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue
//        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
//    }
    
//    /// total mass of flour in the step
//    private var flourMass: Double {
//        var mass = 0.0
//        _ = ingredients.filter { $0.type == .flour }.map { mass += $0.mass}
//        _ = substeps.map { mass += $0.flourMass }
//        return mass
//    }
//
//    /// total mass of water in the step
//    private var waterMass: Double {
//        var mass = 0.0
//        _ = ingredients.filter { $0.type == .bulkLiquid }.map { mass += $0.mass}
//        _ = substeps.map { mass += $0.waterMass }
//        return mass
//    }
    //
    //    func sumMassCProduct(data: [(mass: Double, c: Double)]) -> Double {
    //        var value = 0.0
    //        for pair in data {
    //            value += pair.mass * pair.c
    //        }
    //        return value;
    //    }
    //
    //    func sumMassCTempProduct(data: [(mass: Double, c: Double, temp: Double)]) -> Double {
    //        var value = 0.0
    //        _ = data.map { value += ($0.mass * $0.c * $0.temp)}
    //        return value
    //    }
    //
    //    public func text(startDate: Date, roomTemp: Int, scaleFactor: Double) -> String{
    //        var text = ""
    //
    //        for step in subSteps {
    //            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor)
    //        }
    //
    //        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
    //        text.append(nameString)
    //
    //        for ingredient in self.ingredients{
    //            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
    //                " \(ingredient.type == .bulkLiquid ? String(self.themperature(for: ingredient, roomThemperature: roomTemp)) + "° C" : "" )" + "\n"
    //            text.append(ingredientString)
    //        }
    //        for subStep in self.subSteps{
    //            let substepString = subStep.formattedName + ": " + "\(self.totalAmount)" + "\(subStep.temperature)" + "° C\n"
    //            text.append(substepString)
    //        }
    //        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
    //            text.append(self.notes + "\n")
    //        }
    //        return text
    //    }
    //
    //    func stepsForReodering() -> [Step] {
    //        var steps = [Step]()
    //        for sub in self.subSteps.sorted(by: { $0.time > $1.time }) {
    //            steps.append(contentsOf: sub.stepsForReodering())
    //        }
    //        steps.append(self)
    //
    //        return steps
    //    }
}
    
extension Step: Sqlable {
    
    static let id = Column("name", .integer, PrimaryKey(autoincrement: true))
    static let name = Column("name", .text)
    static let duration = Column("duration", .real)
    static let temperature = Column("temperature", .integer)
    static let notes = Column("notes", .text)
    static let superStepId = Column("superStepId", .integer, ForeignKey<Step>())
    static let recipeId = Column("recipeId", .integer, ForeignKey<Recipe>())
    public static var tableLayout: [Column] = [id, name, duration, temperature, notes, superStepId]
    
    public func valueForColumn(_ column: Column) -> SqlValue? {
        switch column {
        case Step.id:
            return self.id
        case Step.name:
            return self.name
        case Step.duration:
            return self.duration
        case Step.temperature:
            return self.temperature
        case Step.notes:
            return self.notes
        case Step.superStepId:
            return self.superStepId
        default:
            return nil
        }
    }
    
    public init(row: ReadRow) throws {
        self.recipeId = try row.get(Step.recipeId)
        self.id = try row.get(Step.id)
        self.name = try row.get(Step.name)
        self.duration = try row.get(Step.duration)
        self.temperature = try row.get(Step.temperature)
        self.notes = try row.get(Step.notes)
        self.superStepId = try? row.get(Step.superStepId)
    }
    
}

//import Foundation
//import BakingRecipeStrings
//
//public struct Step: Equatable, Identifiable, Hashable, Codable {
//
//    public var id: UUID
//    
//    public var time : TimeInterval
//    
//    public var name: String
//    
//    public var ingredients: [Ingredient]
//    
//    public var temperature : Int
//    
//    public var notes: String
//    
//    public var subSteps: [Step]
//    
//    public init(name: String = "", time: TimeInterval = 60, ingredients: [Ingredient] = [], themperature: Int = 20, notes: String = "") {
//        self.id = UUID()
//        self.time = time
//        self.name = name
//        self.ingredients = ingredients
//        self.temperature = themperature
//        self.notes = notes
//        self.subSteps = []
//    }
//    
//    public var formattedTime: String{
//        Int(time/60).formattedTime
//    }
//    
//    public var formattedTemp: String{
//        return String(self.temperature) + " °C"
//    }
//    
//    public var formattedName: String {
//        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedStep : name
//    }
//    
//    public var totalAmount: Double{
//        var amount = 0.0
//        for ingredient in self.ingredients{
//            amount += ingredient.amount
//        }
//        for substep in self.subSteps {
//            amount += substep.totalAmount
//        }
//        return amount
//    }
//    
//    public var totalFormattedAmount: String{
//        Ingredient.formattedAmount(for: self.totalAmount)
//    }
//    
//    
//    ///Themperature for bulk liquids so the step has the right Temperature
//    public func themperature(for ingredient: Ingredient, roomThemperature: Int) -> Int {
//        
//        let sumMassCProductAll = self.sumMassCProduct(data: ingredients.map { ($0.amount, $0.c)} + subSteps.map { ($0.totalAmount, $0.c)} )
//        let tKnet = 0
//        let sumMassCProductRest = sumMassCTempProduct(data: ingredients.filter { $0 != ingredient }.map { ($0.amount, $0.c, Double(roomThemperature)) } + subSteps.map { ($0.totalAmount, $0.c, Double($0.temperature))})
//        return Int(((sumMassCProductAll * Double(self.temperature - tKnet)) - sumMassCProductRest)/(ingredient.amount * ingredient.c))
//    }
//    
//    private var c: Double{
//        let percentageFlour = flourAmount/totalAmount
//        let percentageWater = waterAmount/totalAmount
//        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue
//        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
//    }
//    
//    private var flourAmount: Double {
//        var amount = 0.0
//        _ = ingredients.filter { $0.type == .flour }.map { amount += $0.amount}
//        _ = subSteps.map { amount += $0.flourAmount }
//        return amount
//    }
//    
//    private var waterAmount: Double {
//        var amount = 0.0
//        _ = ingredients.filter { $0.type == .bulkLiquid }.map { amount += $0.amount}
//        _ = subSteps.map { amount += $0.waterAmount }
//        return amount
//    }
//    
//    func sumMassCProduct(data: [(mass: Double, c: Double)]) -> Double {
//        var value = 0.0
//        for pair in data {
//            value += pair.mass * pair.c
//        }
//        return value;
//    }
//    
//    func sumMassCTempProduct(data: [(mass: Double, c: Double, temp: Double)]) -> Double {
//        var value = 0.0
//        _ = data.map { value += ($0.mass * $0.c * $0.temp)}
//        return value
//    }
//    
//    public func text(startDate: Date, roomTemp: Int, scaleFactor: Double) -> String{
//        var text = ""
//        
//        for step in subSteps {
//            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor)
//        }
//        
//        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
//        text.append(nameString)
//        
//        for ingredient in self.ingredients{
//            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
//                " \(ingredient.type == .bulkLiquid ? String(self.themperature(for: ingredient, roomThemperature: roomTemp)) + "° C" : "" )" + "\n"
//            text.append(ingredientString)
//        }
//        for subStep in self.subSteps{
//            let substepString = subStep.formattedName + ": " + "\(self.totalAmount)" + "\(subStep.temperature)" + "° C\n"
//            text.append(substepString)
//        }
//        if !self.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
//            text.append(self.notes + "\n")
//        }
//        return text
//    }
//    
//    func stepsForReodering() -> [Step] {
//        var steps = [Step]()
//        for sub in self.subSteps.sorted(by: { $0.time > $1.time }) {
//            steps.append(contentsOf: sub.stepsForReodering())
//        }
//        steps.append(self)
//        
//        return steps
//    }
//    
//    //MARK: init from Json and ==
//    
//    enum CodingKeys: CodingKey{
//        case time
//        case name
//        case ingredients
//        case temperature
//        case notes
//        case subSteps
//        case id
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        self.time = try container.decode(TimeInterval.self, forKey: .time)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
//        self.temperature = try container.decode(Int.self, forKey: .temperature)
//        self.notes = try container.decode(String.self, forKey: .notes)
//        self.subSteps = try container.decode([Step].self, forKey: .subSteps)
//    }
//    
//    public static func == (lhs: Step, rhs: Step) -> Bool {
//        return lhs.name == rhs.name &&
//            lhs.time == rhs.time &&
//            lhs.ingredients == rhs.ingredients &&
//            lhs.temperature == rhs.temperature &&
//            lhs.notes == rhs.notes &&
//            lhs.subSteps == rhs.subSteps
//    }
//
//}
