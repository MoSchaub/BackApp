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
    formatter.dateFormat = "dd.MM.yy 'um' HH:mm"
    return formatter
}

var isoFormatter = ISO8601DateFormatter()

struct Rezept: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var brotValues: [BrotValue]
    var inverted : Bool
    
    private var dateString: String
    private var imageString: String
    
    var date: Date{
        get{
            return isoFormatter.date(from: dateString) ?? Date()
        }
        set(newValue){
            dateString =  isoFormatter.string(from: newValue)
        }
    }
    
    var image: UIImage{
        get{
            let data = Data(base64Encoded: imageString)
            return UIImage(data: data!)!
        }
        set{
            imageString = newValue.base64(format: .PNG)
        }
    }
    
    func startDate() -> Date {
        if !inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(-(totalTime()*60)))
        }
    }
    func endDate() -> Date {
        if inverted {
            return date
        } else {
            return date.addingTimeInterval(TimeInterval(totalTime()*60))
        }
        
    }
    func text() -> String {
        var h = startDate()
        var text = ""
        
        for brotValue in brotValues {
            text += "\(brotValue.name) am \(dateFormatter.string(from: h))"
            text += "\n"
            h = h.addingTimeInterval(brotValue.time)
        }
        text += "fertig am \(dateFormatter.string(from: endDate()))"
        return text
    }
    
    /// returns the total time of all the BrotValues in the brotValues array
    func totalTime() -> Int {
        var allTimes: Int = 0
        for brotValue in brotValues {
            allTimes += Int(brotValue.time/60)
        }
        return allTimes
    }

}
