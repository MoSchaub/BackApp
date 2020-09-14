//
//  TimesItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class TimesItem: Item {
    var decimal: Decimal?
    
    init(id: UUID = UUID(), decimal: Decimal?) {
        self.decimal = decimal
        super.init(id: id)
    }
}
