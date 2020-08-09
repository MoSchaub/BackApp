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

class HomeItem: Hashable {
    var name: String
    var id: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

class DetailItem: HomeItem {
    var detailLabel: String
    
    init(id: UUID = UUID(), name: String, detailLabel: String) {
        self.detailLabel = detailLabel
        super.init(id: id, name: name)
    }
}

class RecipeItem: HomeItem {
    var imageData: Data?
    var minuteLabel: String
    
    init(id: UUID = UUID(), name: String, imageData: Data?, minuteLabel: String) {
        self.imageData = imageData
        self.minuteLabel = minuteLabel
        super.init(id: id, name: name)
    }
}
