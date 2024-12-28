// Copyright © 2019 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

var dateFormatter: DateFormatter{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy',' HH:mm"
    return formatter
}

var isoFormatter = ISO8601DateFormatter()

struct Recipe: Hashable, Codable, Identifiable{
    
    var id: String
    
    ///name of the recipe
    var name: String
    
    ///small text containing some Info about the recipe
    var info: String
    
    ///array containing all steps involved in the recipe
    var steps: [Step]
    
    ///property containing wether the recipe is a favourite
    var isFavourite: Bool
    
    ///how difficult the recipe is
    var difficulty: Difficulty
    
    //MARK: Date Properties
    
    ///property containing wether the "date" property is the end date or the start date
    var inverted : Bool
    
    ///for how many items eg breads, rolls, etc the the ingredients are set
    var times: Decimal?
    
    ///if the recipe is currently running
    var running: Bool
    
    ///property used to make the date json compatible and strores the date as an string
    private var dateString: String
    
    ///date thats either the start or the end point of the recipe
    var date: Date{
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
    var imageString: Data?
    
    /// total time of all the steps in the brotValues array
    var totalTime: Int {
        var allTimes: Int = 0
        for step in self.steps {
            allTimes += Int(step.time/60)
        }
        return allTimes
    }
    
    ///number of all ingredients used in the recipe
    var numberOfIngredients: Int{
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
    
    
    var timesText: String{
        get{
            if self.times != nil {
                return times!.description + " " +
                   (times!.description == "1" ? NSLocalizedString("1stk", comment: "") : NSLocalizedString("stk", comment: ""))
            } else {
                return "1 " + NSLocalizedString("1stk", comment: "")
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
    var formattedTotalTime: String{
        if self.totalTime == 1 {
            return "eine " + self.formattedTotalTimeAddition
        } else {
            return "\(self.totalTime) " + self.formattedTotalTimeAddition
        }
    }
    
    var formattedTotalTimeAddition: String{
        if self.totalTime == 1 {
            return "Minute"
        } else {
            return "Minuten"
        }
    }
    
    var formattedName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? NSLocalizedString("unbenanntesRezept", comment: "") : name
    }
    
    /// startDate formatted using the dateFormatter
    var formattedStartDate: String {
        dateFormatter.string(from: startDate)
    }
    
    /// endDate formatted using the dateFormatter
    var formattedEndDate: String {
        dateFormatter.string(from: endDate)
    }
    
    var formattedDate: String {
        if inverted{
            return "\(NSLocalizedString("end", comment: "")) \(formattedEndDate)"
        } else{
            return "\(NSLocalizedString("start", comment: "")) \(formattedStartDate)"
        }
    }
    
    /// combination of formattedEndDate and formattedStartDate
    var formattedStartBisEnde: String{
        "\(self.formattedStartDate) bis \n\(self.formattedEndDate)"
    }
    
    func formattedStartDate(for item: Step) -> String{
        var start = self.startDate
        for step in self.steps{
            if step == item{
                return dateFormatter.string(from: start)
            }
            start.addTimeInterval(step.time)
        }
        return "error"
    }
    
    static var example: Recipe {
        let vollkornMehl = Ingredient(name: "Vollkornmehl", amount: 50)
        let anstellgut = Ingredient(name: "Anstellgut TA 200", amount: 120, isBulkLiquid: false)
        let olivenöl = Ingredient(name: "Olivenöl", amount: 40, isBulkLiquid: true)
        let saaten = Ingredient(name: "Saaten", amount: 30)
        let salz = Ingredient(name: "Salz", amount: 5)
        
        let schritt1 = Step(name: "Mischen", time: 2, ingredients: [anstellgut,vollkornMehl,olivenöl,saaten,salz], themperature: 20)
        
        let backen = Step(name: "Backen", time: 18,notes: "170˚ C")
        
        return Recipe(name: "Sauerteigcrack", brotValues: [schritt1, backen])
    }
    
    init(name: String, info: String = "" , brotValues: [Step], inverted: Bool = false , running: Bool = false, dateString: String = "", isFavourite: Bool = false, difficulty: Difficulty = .easy) {
        self.id = UUID().uuidString
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
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
    
    func text(roomTemp: Int, scaleFactor: Double) -> String {
        var h = startDate
        var text = ""
        
        for step in steps {
            text += step.text(startDate: h, roomTemp: roomTemp, scaleFactor: scaleFactor)
            h = h.addingTimeInterval(step.time)
        }
        text += "Fertig: \(dateFormatter.string(from: endDate))"
        return text
    }
    
    func neutralizedForExport() -> Recipe {
        var neutralized = self
        neutralized.inverted = false
        neutralized.running = false
        neutralized.dateString = ""
        neutralized.isFavourite = false
        return neutralized
    }
    
}

extension Recipe: Equatable{
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name &&
            lhs.info == rhs.info &&
            lhs.steps == rhs.steps &&
            lhs.inverted == rhs.inverted &&
            lhs.isFavourite == rhs.isFavourite &&
            lhs.difficulty == rhs.difficulty &&
            lhs.times == rhs.times 
    }
}
