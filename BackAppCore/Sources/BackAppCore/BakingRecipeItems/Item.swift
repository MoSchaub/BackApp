// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

fileprivate var counter = 0

public class Item: Hashable {
    
    public var id: Int
    
    public init(id: Int? = nil) {
        if id != nil {
            self.id = id!
        } else {
            self.id = counter
        }
        if self.id == counter {
            counter += 1
        }
    }
    
    static public func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
