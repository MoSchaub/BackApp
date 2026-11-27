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

        if hours == 0 {
            return Strings.minutesCount(minutes)
        } else if minutes == 0 {
            return Strings.hoursCount(hours)
        } else {
            return Strings.hoursCount(hours) + " " + Strings.minutesCount(minutes)
        }
    }
    
    var minutes: Int {
        self % 60
    }
    
    var hours: Int {
        self / 60
    }

    var formattedDurationHours: String {
        Strings.hoursCount(hours)
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
            return Strings.hoursDecimalCount(hours, formatted: formatNumber(hours))
        }
    }
}
