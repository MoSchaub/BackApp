//
//  TestModels.swift
//  Back App iOSUITests
//
//  Created by Moritz Schaub on 18.10.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation


public struct Ingredient: Codable, Hashable, Identifiable, Equatable{
    
    public enum Style: Double, CaseIterable, Codable {
        
        case bulkLiquid = 4.187
        case flour = 1.465
        case ta150 = 1.5
        case ta200 = 2.0
        case other = 1.0 //to be changed

        public var name: String {
            switch self {
            case .bulkLiquid: return NSLocalizedString("bulkLiquid", comment: "")
            case .flour: return NSLocalizedString("flour", comment: "")
            case .ta150: return NSLocalizedString("ta150", comment: "")
            case .ta200: return NSLocalizedString("ta200", comment: "")
            case .other: return NSLocalizedString("other", comment: "")
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
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamedIngredient", comment: "") : name
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

public struct Step: Equatable, Identifiable, Hashable, Codable {

    public var id: UUID
    
    public var time : TimeInterval
    
    public var name: String
    
    public var ingredients: [Ingredient]
    
    public var temperature : Int
    
    public var notes: String
    
    public var subSteps: [Step]
    
    public init(name: String = "", time: TimeInterval = 60, ingredients: [Ingredient] = [], themperature: Int = 20, notes: String = "") {
        self.id = UUID()
        self.time = time
        self.name = name
        self.ingredients = ingredients
        self.temperature = themperature
        self.notes = notes
        self.subSteps = []
    }
    
//    public var formattedTime: String{
//        Int(time/60).formattedTime
//    }
    
    public var formattedTemp: String{
        return String(self.temperature) + " °C"
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
    public func themperature(for ingredient: Ingredient, roomThemperature: Int) -> Int {
        
        let sumMassCProductAll = self.sumMassCProduct(data: ingredients.map { ($0.amount, $0.c)} + subSteps.map { ($0.totalAmount, $0.c)} )
        let tKnet = 0
        let sumMassCProductRest = sumMassCTempProduct(data: ingredients.filter { $0 != ingredient }.map { ($0.amount, $0.c, Double(roomThemperature)) } + subSteps.map { ($0.totalAmount, $0.c, Double($0.temperature))})
        return Int(((sumMassCProductAll * Double(self.temperature - tKnet)) - sumMassCProductRest)/(ingredient.amount * ingredient.c))
    }
    
    private var c: Double{
        let percentageFlour = flourAmount/totalAmount
        let percentageWater = waterAmount/totalAmount
        return percentageFlour * Ingredient.Style.flour.rawValue + percentageWater * Ingredient.Style.bulkLiquid.rawValue
        //Anteil Mehl*Cmehl+Anteil Wasser*CWasser
    }
    
    private var flourAmount: Double {
        var amount = 0.0
        _ = ingredients.filter { $0.type == .flour }.map { amount += $0.amount}
        _ = subSteps.map { amount += $0.flourAmount }
        return amount
    }
    
    private var waterAmount: Double {
        var amount = 0.0
        _ = ingredients.filter { $0.type == .bulkLiquid }.map { amount += $0.amount}
        _ = subSteps.map { amount += $0.waterAmount }
        return amount
    }
    
    func sumMassCProduct(data: [(mass: Double, c: Double)]) -> Double {
        var value = 0.0
        for pair in data {
            value += pair.mass * pair.c
        }
        return value;
    }
    
    func sumMassCTempProduct(data: [(mass: Double, c: Double, temp: Double)]) -> Double {
        var value = 0.0
        _ = data.map { value += ($0.mass * $0.c * $0.temp)}
        return value
    }
    
    public func text(startDate: Date, roomTemp: Int, scaleFactor: Double) -> String{
        var text = ""
        
        for step in subSteps {
            text += step.text(startDate: startDate, roomTemp: roomTemp, scaleFactor: scaleFactor)
        }
        
        let nameString = "\(self.formattedName) \(dateFormatter.string(from: startDate))\n"
        text.append(nameString)
        
        for ingredient in self.ingredients{
            let ingredientString = "\t" + ingredient.formattedName + ": " + ingredient.scaledFormattedAmount(with: scaleFactor) +
                " \(ingredient.type == .bulkLiquid ? String(self.themperature(for: ingredient, roomThemperature: roomTemp)) + "° C" : "" )" + "\n"
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
    
    func stepsForReodering() -> [Step] {
        var steps = [Step]()
        for sub in self.subSteps.sorted(by: { $0.time > $1.time }) {
            steps.append(contentsOf: sub.stepsForReodering())
        }
        steps.append(self)
        
        return steps
    }
    
    //MARK: init from Json and ==
    
    enum CodingKeys: CodingKey{
        case time
        case name
        case ingredients
        case temperature
        case notes
        case subSteps
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
    }
    
    public static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs.name == rhs.name &&
            lhs.time == rhs.time &&
            lhs.ingredients == rhs.ingredients &&
            lhs.temperature == rhs.temperature &&
            lhs.notes == rhs.notes &&
            lhs.subSteps == rhs.subSteps
    }

}

public enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard
}

public var dateFormatter: DateFormatter{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy',' HH:mm"
    return formatter
}

@available(iOS 10.0, *)
var isoFormatter = ISO8601DateFormatter()

@available(iOS 10.0, *)
public struct Recipe: Hashable, Codable, Identifiable{
    
    public var id: UUID
    
    ///name of the recipe
    public var name: String
    
    ///small text containing some Info about the recipe
    public var info: String
    
    ///array containing all steps involved in the recipe
    public var steps: [Step]
    
    ///property containing wether the recipe is a favourite
    public var isFavourite: Bool
    
    ///how difficult the recipe is
    public var difficulty: Difficulty
    
    //MARK: Date Properties
    
    ///property containing wether the "date" property is the end date or the start date
    public var inverted : Bool
    
    ///for how many items eg breads, rolls, etc the the ingredients are set
    public var times: Decimal?
    
    ///if the recipe is currently running
    public var running: Bool
    
    ///property used to make the date json compatible and strores the date as an string
    private var dateString: String
    
    ///date thats either the start or the end point of the recipe
    public var date: Date{
        get{
            return isoFormatter.date(from: dateString) ?? Date()
        }
        set(newValue){
            dateString =  isoFormatter.string(from: newValue)
        }
    }
    
    ///starting date
    private var startDate: Date {
        if !inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(-(totalTime * 60)))
        }
    }
    
    ///end date
    private var endDate: Date {
        if inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(totalTime * 60))
        }
        
    }
    
    
    //MARK: Image properties
    ///property used to make the image json compatible and stores the image as base64 encoded String
    public var imageString: Data?
    
    /// total time of all the steps in the brotValues array
    public var totalTime: Int {
        var allTimes: Int = 0
        for step in self.steps {
            allTimes += Int(step.time/60)
        }
        return allTimes
    }
    
    ///number of all ingredients used in the recipe
    public var numberOfIngredients: Int{
        var ingredients = [Ingredient]()
        for step in steps{
            for ingredient in step.ingredients{
                if !ingredients.contains(where: { $0.name.lowercased() == ingredient.name.lowercased()}){
                    ingredients.append(ingredient)
                }
            }
        }
        return ingredients.count
    }
    
    
    public var timesText: String{
        get{
            if self.times != nil {
                return times!.description + " " +
                   (times!.description == "1" ? NSLocalizedString("piece", comment: "") : NSLocalizedString("pieces", comment: ""))
            } else {
                return "1 " + NSLocalizedString("piece", comment: "")
            }
        }
        set{
            if let int = Int(newValue){
                self.times = Decimal(integerLiteral: int)
            } else{
                self.times = nil
            }
        }
    }
    
    
    //MARK: formatted Properties
    
    ///formatted total time in
//    public var formattedTotalTime: String{
//        totalTime.formattedTime
//    }

    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamed recipe", comment: "") : name
    }
    
    /// startDate formatted using the dateFormatter
    public var formattedStartDate: String {
        dateFormatter.string(from: startDate)
    }
    
    /// endDate formatted using the dateFormatter
    public var formattedEndDate: String {
        dateFormatter.string(from: endDate)
    }
    
    public var formattedDate: String {
        if inverted{
            return "\(NSLocalizedString("end", comment: "")) \(formattedEndDate)"
        } else{
            return "\(NSLocalizedString("start", comment: "")) \(formattedStartDate)"
        }
    }
    
    /// combination of formattedEndDate and formattedStartDate
    public var formattedStartBisEnde: String{
        "\(self.formattedStartDate) bis \n\(self.formattedEndDate)"
    }
    
//    public func formattedStartDate(for item: Step) -> String{
//        let datesDict = startDates()
//        if let date = datesDict[item] {
//            return dateFormatter.string(from: date)
//        }
//        return "error"
//    }
//
//    private func startDates() -> [Step : Date]{
//        var dict = [Step : Date]()
//        var h = startDate
//        for step in self.notSubsteps {
//            let stepDates = startDates(for: step, h: h)
//            dict.append(contentsOf: stepDates.dict)
//            h = stepDates.h
//
//            h.addTimeInterval(step.time)
//        }
//        return dict
//    }
//
//    func startDates(for step: Step, h: Date) -> (h: Date, dict: [Step : Date]) {
//        var dict = [Step : Date]()
//        var h = h
//        var sortedSubs = step.subSteps.sorted(by: { $0.time > $1.time })
//        if let first = sortedSubs.first { //get the longest sub
//            sortedSubs.removeFirst() //remove so it does not get used twice
//            let firstDates = startDates(for: first, h: h)
//            dict.append(contentsOf: firstDates.dict)
//            h = firstDates.h
//
//            let subEndDate = h.addingTimeInterval(first.time) //data when all substebs of the step should end
//            for sub in sortedSubs {
//                let subDates = startDates(for: sub, h: subEndDate.addingTimeInterval(-(sub.time)))
//                dict.append(contentsOf: subDates.dict)
//            }
//
//            h = subEndDate
//        }
//        dict[step] = h
//
//        return (h,dict)
//    }
    
    /// steps that are no substeps of any other step
    public var notSubsteps: [Step] {
        // get steps with substeps
        let stepsWithSubsteps = steps.filter({ !$0.subSteps.isEmpty })
        
        // get all substeps
        var allSubsteps = [Step]()
        let _ = stepsWithSubsteps.map({ allSubsteps.append(contentsOf: $0.subSteps)})
        allSubsteps = Array<Step>(Set(allSubsteps)) // make them unique
        let result = steps.filter { step in !allSubsteps.contains(where: { $0.id == step.id })}
        return result
    }
    
    static public var example: Recipe {
        let vollkornMehl = Ingredient(name: "Vollkornmehl", amount: 50, type: .flour)
        let anstellgut = Ingredient(name: "Anstellgut TA 200", amount: 120, type: .ta200)
        let olivenöl = Ingredient(name: "Olivenöl", amount: 40, type: .bulkLiquid)
        let saaten = Ingredient(name: "Saaten", amount: 30, type: .other)
        let salz = Ingredient(name: "Salz", amount: 5, type: .other)
        
        let schritt1 = Step(name: "Mischen", time: 2*60, ingredients: [anstellgut,vollkornMehl,olivenöl,saaten,salz], themperature: 20)
        
        let backen = Step(name: "Backen", time: 18*60,notes: "170˚ C")
        
        return Recipe(name: "Sauerteigcracker", brotValues: [schritt1, backen])
    }
    
    static public var complexExample: Recipe {
        let sub = Step(name: "Sauerteig", ingredients: [
            Ingredient(name: "Mehl", amount: 200, type: .flour),
            Ingredient(name: "Wasser", amount: 100, type: .bulkLiquid)
        ], themperature: 30)
        var step = Step(name: "Hauptteig", time: 1800, ingredients: [
            Ingredient(name: "Mehl", amount: 200, type: .flour),
            Ingredient(name: "Wasser", amount: 150, type: .bulkLiquid),
            Ingredient(name: "Salz", amount: 20, type: .other)
        ], themperature: 26)
        step.subSteps.append(sub)
        return Recipe(name: "Komplexes Rezept", brotValues: [sub, step])
    }
    
    public init(name: String, info: String = "" , brotValues: [Step], inverted: Bool = false , running: Bool = false, dateString: String = "", isFavourite: Bool = false, difficulty: Difficulty = .easy) {
        self.id = UUID()
        self.name = name
        self.info = info
        self.steps = brotValues
        self.inverted = inverted
        self.dateString = dateString
        self.running = running
        self.isFavourite = isFavourite
        self.difficulty = difficulty
        self.times = Decimal(integerLiteral: 1)
    }
    
    //reorderSteps to make sense
    public var reorderedSteps: [Step] {
        var steps = [Step]()
        for step in notSubsteps {
            steps.append(contentsOf: step.stepsForReodering())
        }
        steps = Array<Step>(Set(steps)) // make them unique
        return steps
    }
    
    
    enum CodingKeys: CodingKey {
        case name
        case info
        case steps
        case inverted
        case running
        case dateString
        case isFavourite
        case imageString
        case difficulty
        case times
        case id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString)!
        self.name = try container.decode(String.self, forKey: .name)
        self.info = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.steps = try container.decode([Step].self, forKey: .steps)
        self.inverted = try container.decode(Bool.self, forKey: .inverted)
        self.isFavourite = try container.decode(Bool.self, forKey: .isFavourite)
        self.dateString = try container.decodeIfPresent(String.self, forKey: .dateString) ?? ""
        self.running = try container.decodeIfPresent(Bool.self, forKey: .running) ?? false
        self.imageString = try container.decodeIfPresent(Data.self, forKey: .imageString)
        self.difficulty = try container.decodeIfPresent(Difficulty.self, forKey: .difficulty) ?? Difficulty.easy
        self.times = try container.decode(Decimal.self, forKey: .times)
    }
    
    public func text(roomTemp: Int, scaleFactor: Double) -> String {
        var h = startDate
        var text = ""
        
        for step in notSubsteps {
            text += step.text(startDate: h, roomTemp: roomTemp, scaleFactor: scaleFactor)
            h = h.addingTimeInterval(step.time)
        }
        text += "Fertig: \(dateFormatter.string(from: endDate))"
        return text
    }
    
    public func neutralizedForExport() -> Recipe {
        var neutralized = self
        neutralized.inverted = false
        neutralized.running = false
        neutralized.dateString = ""
        neutralized.isFavourite = false
        return neutralized
    }
    
}

@available(iOS 10.0, *)
extension Recipe: Equatable{
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name &&
            lhs.info == rhs.info &&
            lhs.steps == rhs.steps &&
            lhs.inverted == rhs.inverted &&
            lhs.isFavourite == rhs.isFavourite &&
            lhs.difficulty == rhs.difficulty &&
            lhs.times == rhs.times &&
            lhs.imageString == rhs.imageString &&
            lhs.running == rhs.running &&
            lhs.dateString == rhs.dateString
    }
}
