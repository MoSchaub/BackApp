//
//  Category.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 07.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct Category: Codable, Hashable, Identifiable {
    var id: UUID
    
    var name: String

    private var imageString: String
    
    ///getter and setter for the image
    var image: UIImage?{
        get{
            let data = Data(base64Encoded: imageString)
            return UIImage(data: data!)
        }
        set{
            if newValue == nil{
                imageString = UIImage().base64(format: .PNG)
            }
            else {
                imageString = newValue!.base64(format: .PNG)
            }
        }
    }
    
    init(name: String, image: UIImage) {
        self.id = UUID()
        self.name = name
        self.imageString = ""
        self.image = image
    }
    
    static var example = Category(name: "Brot", image: UIImage(named: "bread")!)
    
}
