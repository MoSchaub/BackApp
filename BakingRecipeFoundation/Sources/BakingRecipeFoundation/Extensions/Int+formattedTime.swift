//
//  Int+formattedTime.swift
//  
//
//  Created by Moritz Schaub on 08.09.20.
//

import Foundation
import BakingRecipeStrings

extension Int {
    var formattedDuration: String {
        let hours = self / 60
        let minutes = self % 60
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
