//
//  TextItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class TextItem: Item {
    public var text: String
    
    public init(id: Int? = nil, text: String) {
        self.text = text
        super.init(id: id)
    }
}
