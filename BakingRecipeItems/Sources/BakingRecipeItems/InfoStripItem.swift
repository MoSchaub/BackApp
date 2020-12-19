//
//  InfoStripItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class InfoStripItem: Item {
    public var stepCount: Int
    public var minuteCount: Int
    public var ingredientCount: Int
    
    public init(stepCount: Int, minuteCount: Int, ingredientCount: Int) {
        self.stepCount = stepCount
        self.minuteCount = minuteCount
        self.ingredientCount = ingredientCount
        super.init()
    }
}
