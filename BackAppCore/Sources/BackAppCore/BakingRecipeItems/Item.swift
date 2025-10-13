// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

public class Item: Hashable {
    
    public var id: Int
    
    public init(id: Int? = nil) {
        if let id = id {
            self.id = id
        } else {
            self.id = Int.random(in: Int.min...Int.max)
        }
    }
    
    static public func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
