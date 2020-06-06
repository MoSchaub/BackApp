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
    
    init(name: String, imageData: Data? = nil) {
        self.name = name
        self.imageData = imageData
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    static var example = Category(name: "Brot", imageData: UIImage(named: "bread")?.jpegData(compressionQuality: 0.8))
    
}
