//
//  Category.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 07.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct Category: Codable, Hashable, Identifiable {
    var id: UUID{
        UUID()
    }
    
    var name: String

    private var imageData: Data?
    
    #if os(macOS)
    ///getter and setter for the image
    var image: NSImage?{
        get{
        if let data = imageData{
        return NSImage(data: data)
        } else {
        return nil
        }
        }
        set{
        if newValue == nil{
        imageData = nil
        }
        else {
        imageData = newValue!.tiffRepresentation
        }
        }
    }
    
    init(name: String, image: NSImage? = nil) {
           self.name = name
           self.imageData = nil
           self.image = image
    }
    
    
    #elseif os(iOS)
    ///getter and setter for the image
    var image: UIImage?{
        get{
            if let data = imageData{
                return UIImage(data: data)
            } else {
                return nil
            }
        }
        set{
            if newValue == nil{
                imageData = nil
            }
            else {
                imageData = newValue!.jpegData(compressionQuality: 1)
            }
        }
    }
    
    
    init(name: String, image: UIImage? = nil) {
        self.name = name
        self.imageData = nil
        self.image = image
    }
    
    #endif
     static var example = Category(name: "Brot")
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }

}
