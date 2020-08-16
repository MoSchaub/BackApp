//
//  RecipeItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class RecipeItem: TextItem {
    var imageData: Data?
    var minuteLabel: String
    
    init(id: UUID = UUID(), name: String, imageData: Data?, minuteLabel: String) {
        self.imageData = imageData
        self.minuteLabel = minuteLabel
        super.init(id: id, text: name)
    }
}
