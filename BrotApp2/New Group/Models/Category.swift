//
//  Category.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 07.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

struct Category: Codable, Hashable, Identifiable {
    var id: UUID{
        UUID()
    }
    
    var name: String

    var imageData: Data?
    ///getter and setter for the image
    
    init(name: String, imageData: Data? = nil) {
        self.name = name
        self.imageData = imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.imageData = try container.decode(Data?.self, forKey: .imageData)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case imageData
    }
    
    
     static var example = Category(name: "Brot")
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }

}
