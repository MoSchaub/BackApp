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
        if self == 1 {
            return Strings.one + " " + Strings.minute
        } else {
            if hours > 1 {
                return "\(hours) " + formattedDurationUnit(for: hours, hours: true) + " " + (minutes > 0 ? minutes
                .formattedDuration : "")
            } else if hours == 1 {
                return "\(hours) " + formattedDurationUnit(for: hours, hours: true) + " " + minutes.formattedDuration
            } else {
                return "\(minutes) " + formattedDurationUnit(for: minutes)
            }
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
