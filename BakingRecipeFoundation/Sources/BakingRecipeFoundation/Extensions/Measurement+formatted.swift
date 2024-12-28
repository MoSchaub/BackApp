// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  Measurement+formatted.swift
//  
//
//  Created by Moritz Schaub on 13.01.21.
//

import Foundation

fileprivate var measurementFormatter: MeasurementFormatter {
    let formatter = MeasurementFormatter()
    formatter.numberFormatter.maximumFractionDigits = 1
    formatter.numberFormatter.usesGroupingSeparator = false
    formatter.unitStyle = .medium
    return formatter
}


public extension Measurement where UnitType == UnitTemperature {

    /// the temperature measurement formatted to a string with the unit appropriate for the users preference (locale or setting)
    /// only up to one fraction digit.
    /// fraction digits are not always shown e. g. 20.0 becomes 20
    var formatted: String {
        measurementFormatter.string(from: self)
    }

    /// the temperature Measurement formatted to a string containing the measurements value converted to the appopriate unit
    ///- NOTE: This does not include the unit. This is only the value
    var localizedValue: String {
        var string = measurementFormatter.string(from: self)
        string.removeLast(2)
        string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return string
    }
}
