//
//  Double+formattedMass.swift
//  
//
//  Created by moritz on 05.06.21.
//

import Foundation

extension Double {
    public var formattedMass: String {
        return String(format: "%.1f", self) + " g"
    }
}
