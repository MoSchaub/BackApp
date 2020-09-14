//
//  DateItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class DateItem: Item {
    var date: Date
    
    init(id: UUID = UUID(), date: Date) {
        self.date = date
        super.init(id: id)
    }
}
