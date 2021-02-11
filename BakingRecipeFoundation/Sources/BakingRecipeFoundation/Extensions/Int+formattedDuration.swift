//
//  Int+formattedDuration.swift
//  
//
//  Created by Moritz Schaub on 08.09.20.
//

import Foundation
import BakingRecipeStrings

public extension Int {
    var formattedDuration: String {
        let hours = self.hours
        let minutes = self.minutes
        
        func minutesFormatted() -> String {
            if minutes == 0 && hours != 0 {
                return ""
            } else if minutes == 1 {
                return Strings.one + " " + formattedDurationUnit(for: minutes)
            } else {
                return "\(minutes) " + formattedDurationUnit(for: minutes)
            }
        }
        
        if hours > 1 {
            return "\(hours) " + formattedDurationUnit(for: hours, hours: true) + " " + minutesFormatted()
        } else if hours == 1 {
            return Strings.one + " " + formattedDurationUnit(for: hours, hours: true) + " " + minutesFormatted()
        } else {
            return minutesFormatted()
        }
    }
    
    var minutes: Int {
        self % 60
    }
    
    var hours: Int {
        self / 60
    }
}

fileprivate func formattedDurationUnit(for time: Int, hours: Bool = false) -> String{
    if hours {
        if time == 1 {
            return Strings.hour
        } else {
            return Strings.hours
        }
    } else {
        if time == 1 {
            return Strings.minute
        } else {
            return Strings.minutes
        }
    }
}
