//
//  TextFiedItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class TextFieldItem: TextItem {
    public override init(id: UUID = UUID(), text: String) {
        super.init(id: id, text: text)
    }
}
