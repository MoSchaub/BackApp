//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

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
    
    ///array containing all steps involved in the recipe
    var steps: [Step]
    
    ///property containing wether the recipe is a favourite
    var isFavourite: Bool
    
    ///property that contains the category of the recipe eg. Bread
    var category: Category
    
    //MARK: Date Properties
    
    ///property containing wether the "date" property is the end date or the start date
    var inverted : Bool
    
   ///for how many items eg breads, rolls, etc the the ingredients are calculated
    var times: Decimal?

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
    private var imageString: Data?
    
    ///getter and setter for the image
    var image: UIImage?{
        get{
            if let data = imageString{
                return UIImage(data: data)?.resizeTo(width: 300)
            } else{ return nil }
        }
        set{
            if newValue == nil{
                imageString = nil
            }
            else {
                imageString = newValue!.jpegData(compressionQuality: 1)
            }
        }
    }
    
    
    /// total time of all the steps in the brotValues array
    var totalTime: Int {
        var allTimes: Int = 0
        for step in steps {
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
            return "Ende am \(formattedEndDate)"
        } else{
            return "Start am \(formattedStartDate)"
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
    
    static var example = Recipe(name: "Rezept", brotValues: [Step(name: "Schritt1", time: 60, ingredients: [Ingredient](), themperature: 20)], inverted: true, dateString: isoFormatter.string(from: Date()), isFavourite: false, category: Category.example)
    
    init(name:String, brotValues: [Step], inverted: Bool, dateString: String, isFavourite: Bool, category: Category) {
        self.id = UUID().uuidString
        self.name = name
        self.steps = brotValues
        self.inverted = inverted
        self.dateString = dateString
        self.isFavourite = isFavourite
        self.category = category
        self.times = Decimal(integerLiteral: 1)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case steps
        case inverted
        case isFavourite
        case category
        case times
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.steps = try container.decode([Step].self, forKey: .steps)
        self.inverted = try container.decode(Bool.self, forKey: .inverted)
        self.dateString = dateFormatter.string(from: Date())
        self.isFavourite = try container.decode(Bool.self, forKey: .isFavourite)
        self.category = try container.decode(Category.self, forKey: .category)
        self.times = try container.decode(Decimal.self, forKey: .times)
    }
    
    
    
    func text(roomTemp: Int, scaleFactor: Double) -> String {
        var h = startDate
        var text = ""
        
        for step in steps {
            text += step.text(startDate: h, roomTemp: roomTemp, scaleFactor: scaleFactor)
            h = h.addingTimeInterval(step.time)
        }
        text += "fertig am \(dateFormatter.string(from: endDate))"
        return text
    }
    
}

extension Recipe: Equatable{
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name &&
            lhs.steps == rhs.steps &&
            lhs.inverted == rhs.inverted &&
            lhs.isFavourite == rhs.isFavourite &&
            lhs.category == rhs.category &&
            lhs.times == rhs.times 
    }
}
