//
//  RecipeItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class RecipeItem: TextItem {
    public var imageData: Data?
    public var minuteLabel: String
    
    public init(id: UUID = UUID(), name: String, imageData: Data?, minuteLabel: String) {
        self.imageData = imageData
        self.minuteLabel = minuteLabel
        super.init(id: id, text: name)
    }
}
