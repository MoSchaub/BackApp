//
//  DateItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 14.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class DateItem: Item {
    public var date: Date
    
    public init(date: Date) {
        self.date = date
        super.init()
    }
}
