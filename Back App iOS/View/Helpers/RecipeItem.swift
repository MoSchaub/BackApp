//
//  RecipeItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

enum HomeSection: CaseIterable {
    case recipes
    case settings
}

class TextItem: Item {
    var text: String
    
    init(id: UUID = UUID(), text: String) {
        self.text = text
        super.init(id: id)
    }
}

class DetailItem: TextItem {
    var detailLabel: String
    
    init(id: UUID = UUID(), name: String, detailLabel: String) {
        self.detailLabel = detailLabel
        super.init(id: id, text: name)
    }
}

class RecipeItem: TextItem {
    var imageData: Data?
    var minuteLabel: String
    
    init(id: UUID = UUID(), name: String, imageData: Data?, minuteLabel: String) {
        self.imageData = imageData
        self.minuteLabel = minuteLabel
        super.init(id: id, text: name)
    }
}
