//
//  Double+formattedTemp.swift
//  
//
//  Created by Moritz Schaub on 13.01.21.
//

import Foundation

public extension Double {
    var formattedTemp: String {
        String(format: "%.01f", self) + "° C"
    }
}
