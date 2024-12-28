// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

public class DateItem: Item {
    public var date: Date
    
    public init(date: Date) {
        self.date = date
        super.init()
    }
}
