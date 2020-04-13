//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import UIKit

var dateFormatter: DateFormatter{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy',' HH:mm"
    return formatter
}

var isoFormatter = ISO8601DateFormatter()

struct Recipe: Hashable, Codable{
    
    ///name of the recipe
    var name: String
    
    ///array containing all steps involved in the recipe
    var steps: [Step]
    
    ///property containing wether the recipe is a favourite
    var isFavourite: Bool
    
    var category: Category
    
    //MARK: Date Properties
    
    ///property containing wether the "date" property is the end date or the start date
    var inverted : Bool
    
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
    private var imageString: String
    
    ///getter and setter for the image
    var image: UIImage?{
        get{
            if let data = Data(base64Encoded: imageString){
                return UIImage(data: data)
            } else{ return nil }
        }
        set{
            if newValue == nil{
                imageString = ""
            }
            else {
                imageString = newValue!.base64(format: .PNG)
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
        var number = 0
        for step in steps{
            number += step.ingredients.count
        }
        return number
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
    
    static var example = Recipe(name: "Rezept", brotValues: [Step(name: "Schritt1", time: 60, ingredients: [Ingredient](), themperature: 20)], inverted: true, dateString: isoFormatter.string(from: Date()), imageString: "", isFavourite: false, category: Category.example)
    
    init(name:String, brotValues: [Step], inverted: Bool, dateString: String, imageString: String, isFavourite: Bool, category: Category) {
        self.name = name
        self.steps = brotValues
        self.inverted = inverted
        self.dateString = dateString
        self.imageString = imageString
        self.isFavourite = isFavourite
        self.category = category
    }
    
    //TODO: Remove this one
    func text() -> String {
        var h = startDate
        var text = ""
        
        for brotValue in steps {
            text += "\(brotValue.name) am \(dateFormatter.string(from: h))"
            text += "\n"
            h = h.addingTimeInterval(brotValue.time)
        }
        text += "fertig am \(dateFormatter.string(from: endDate))"
        return text
    }
    
}

extension Recipe: Identifiable{
    var id: String{
        UUID().uuidString
    }
}
