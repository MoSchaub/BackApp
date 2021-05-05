//
//  MassFormatter.swift
//  
//
//  Created by Moritz Schaub on 20.12.20.
//

import Foundation

public struct MassFormatter {
    
    ///func that takes in a raw mass and formatts it with the right unit
    static public func formattedMass(for amount: Double) -> String{
        if amount >= 1000{
            return "\(amount/1000)" + " Kg"
        } else if amount < 0.1, amount != 0 {
            return "\(amount * 1000)" + " mg"
        } else {
            return "\(amount)" + " g"
        }
    }
    
    ///the factor which results of Kg or mg
    static public func massFactor(from rest: String) -> Double{
        let str = rest.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch str {
        case "kg": return 1000
        case "mg": return 0.001
        default: return 1
        }
    }
}
