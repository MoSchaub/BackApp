//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

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
    
    var date: Date{
        get{
            return isoFormatter.date(from: dateString) ?? Date()
        }
        set(newValue){
            dateString =  isoFormatter.string(from: newValue)
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
    
    /// returns the total time of all the BrotValues in the brotValues array
    func totalTime() -> Int {
        var allTimes: Int = 0
        for brotValue in brotValues {
            allTimes += Int(brotValue.time/60)
        }
        return allTimes
    }

}
