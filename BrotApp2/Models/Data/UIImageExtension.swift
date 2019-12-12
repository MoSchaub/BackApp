//
//  UIImageExtension.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.12.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import UIKit

public enum ImageFormat {
    case PNG
    case JPEG(CGFloat)
}

extension UIImage {
    
    public func base64(format: ImageFormat) -> String {
        var imageData: Data
        switch format {
        case .PNG: imageData = self.pngData()!
        case .JPEG(let compression): imageData = self.jpegData(compressionQuality: compression)!
        }
        return imageData.base64EncodedString()
    }
}
