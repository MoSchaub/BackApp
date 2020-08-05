//
//  RecipeItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

enum HomeSection {
    case recipes
    case settings
}

class Item: Hashable {
    var name: String!
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String) {
        self.name = name
    }
}

class RecipeItem: Item {
    var image: UIImage!
    var minuteLabel: String!
    
    init(name: String, image: UIImage, minuteLabel: String) {
        super.init(name: name)
        self.image = image
        self.name = name
        self.minuteLabel = minuteLabel
    }
}
