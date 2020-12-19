//
//  ImageItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

public class ImageItem: Item {
    public var imageData: Data?
    
    public init(id: UUID = UUID(), imageData: Data?) {
        self.imageData = imageData
        super.init(id: id)
    }
}
