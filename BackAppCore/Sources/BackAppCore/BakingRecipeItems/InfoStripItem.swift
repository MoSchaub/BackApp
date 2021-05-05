//
//  InfoStripItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

public class InfoStripItem: Item {
    public var weighIn: String
    public var formattedDuration: String
    public var doughYield: String
    
    public init(weighIn: String, formattedDuration: String, doughYield: String) {
        self.weighIn = weighIn
        self.formattedDuration = formattedDuration
        self.doughYield = doughYield
        super.init()
    }
}
