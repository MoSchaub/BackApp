//
//  Item.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

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
