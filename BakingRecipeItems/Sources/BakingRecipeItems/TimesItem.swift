//
//  TimesItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class TimesItem: Item {
    public var decimal: Decimal?
    
    public init(id: UUID = UUID(), decimal: Decimal?) {
        self.decimal = decimal
        super.init(id: id)
    }
}
