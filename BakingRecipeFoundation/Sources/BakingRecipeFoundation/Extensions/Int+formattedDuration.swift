// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
            return Strings.one + " " + formattedDurationUnit(for: hours, hours: true) + (minutes > 0 ? " " + minutesFormatted() : "")
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

    var formattedDurationHours: String {
        let hours = self.hours
        return (hours == 1 ? Strings.one : "\(hours)") + " " + formattedDurationUnit(for: hours, hours: true)
    }
    
    var compactForamttedDuration: String {
        
        func formatNumber(_ number: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0 // Don't force decimal places if not needed
            formatter.maximumFractionDigits = 2 // Limit to 2 decimal places
            
            if let formattedString = formatter.string(from: NSNumber(value: number)) {
                return formattedString
            } else {
                return "\(number)" // Fallback if formatting fails
            }
        }
        
        if self <= 60 {
            return self.formattedDuration
        } else {
            let hours = Double(self) / 60.0
            return formatNumber(hours) + " " + Strings.hours
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
