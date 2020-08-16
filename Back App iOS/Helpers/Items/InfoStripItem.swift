//
//  InfoStripItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class InfoStripItem: Item {
    var stepCount: Int
    var minuteCount: Int
    var ingredientCount: Int
    
    init(stepCount: Int, minuteCount: Int, ingredientCount: Int) {
        self.stepCount = stepCount
        self.minuteCount = minuteCount
        self.ingredientCount = ingredientCount
        super.init()
    }
}
