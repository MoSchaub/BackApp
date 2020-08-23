//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

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
    
    ///formatted total time
    public var formattedTotalTime: String{
        if self.totalTime == 1 {
            return "eine " + self.formattedTotalTimeAddition
        } else {
            return "\(self.totalTime) " + self.formattedTotalTimeAddition
        }
    }
    
    public var formattedTotalTimeAddition: String{
        if self.totalTime == 1 {
            return NSLocalizedString("minute", comment: "")
        } else {
            return NSLocalizedString("minutes", comment: "")
        }
    }
    
    public var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unnamedRecipe", comment: "") : name
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
    
    public func formattedStartDate(for item: Step) -> String{
        var start = self.startDate
        for step in self.steps{
            if step == item{
                return dateFormatter.string(from: start)
            }
            start.addTimeInterval(step.time)
        }
        return "error"
    }
    
    static public var example: Recipe {
        let vollkornMehl = Ingredient(name: "Vollkornmehl", amount: 50)
        let anstellgut = Ingredient(name: "Anstellgut TA 200", amount: 120, isBulkLiquid: false)
        let olivenöl = Ingredient(name: "Olivenöl", amount: 40, isBulkLiquid: true)
        let saaten = Ingredient(name: "Saaten", amount: 30)
        let salz = Ingredient(name: "Salz", amount: 5)
        
        let schritt1 = Step(name: "Mischen", time: 2, ingredients: [anstellgut,vollkornMehl,olivenöl,saaten,salz], themperature: 20)
        
        let backen = Step(name: "Backen", time: 18,notes: "170˚ C")
        var recipe = Recipe(name: "Sauerteigcrack", brotValues: [schritt1, backen])
        recipe.timesText = "20"
        return recipe
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
        
        for step in steps {
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
