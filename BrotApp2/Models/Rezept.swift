//
//  Rezept.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

struct Rezept: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var brotValues: [BrotValue]
    
    /// returns the total time of all the BrotValues in the brotValues array
    func totalTime() -> TimeInterval {
        var allTimes: TimeInterval = 0
        for brotValue in brotValues {
            allTimes += brotValue.time
        }
        return allTimes
    }

}
