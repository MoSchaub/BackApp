//
//  BrotValue.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import Foundation

struct BrotValue: Equatable, Identifiable, Hashable, Codable {
    var id: Int
    
    var time : TimeInterval
    
    var name: String
}
