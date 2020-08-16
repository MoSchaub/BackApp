//
//  TextItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class TextItem: Item {
    var text: String
    
    init(id: UUID = UUID(), text: String) {
        self.text = text
        super.init(id: id)
    }
}
