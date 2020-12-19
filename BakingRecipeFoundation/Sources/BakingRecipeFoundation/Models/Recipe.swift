//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings

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
                    (times!.description == "1" ? Strings.piece : Strings.pieces)
            } else {
                return "1 " + Strings.piece
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
    public var formattedTotalTime: String{
        totalTime.formattedTime
    }

    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? Strings.unnamedRecipe : name
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
            return "\(Strings.end) \(formattedEndDate)"
        } else{
            return "\(Strings.start)) \(formattedStartDate)"
        }
    }
    
    /// combination of formattedEndDate and formattedStartDate
    public var formattedStartBisEnde: String{
        "\(self.formattedStartDate) bis \n\(self.formattedEndDate)"
    }
    
    public func formattedStartDate(for item: Step) -> String{
        let datesDict = startDates()
        if let date = datesDict[item] {
            return dateFormatter.string(from: date)
        }
        return "error"
    }
    
    private func startDates() -> [Step : Date]{
        var dict = [Step : Date]()
        var h = startDate
        for step in self.notSubsteps {
            let stepDates = startDates(for: step, h: h)
            dict.append(contentsOf: stepDates.dict)
            h = stepDates.h
            
            h.addTimeInterval(step.time)
        }
        return dict
    }
    
    func startDates(for step: Step, h: Date) -> (h: Date, dict: [Step : Date]) {
        var dict = [Step : Date]()
        var h = h
        var sortedSubs = step.subSteps.sorted(by: { $0.time > $1.time })
        if let first = sortedSubs.first { //get the longest sub
            sortedSubs.removeFirst() //remove so it does not get used twice
            let firstDates = startDates(for: first, h: h)
            dict.append(contentsOf: firstDates.dict)
            h = firstDates.h
            
            let subEndDate = h.addingTimeInterval(first.time) //data when all substebs of the step should end
            for sub in sortedSubs {
                let subDates = startDates(for: sub, h: subEndDate.addingTimeInterval(-(sub.time)))
                dict.append(contentsOf: subDates.dict)
            }
            
            h = subEndDate
        }
        dict[step] = h
        
        return (h,dict)
    }
    
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
        
        return Recipe(name: "Sauerteigcrack", brotValues: [schritt1, backen])
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
