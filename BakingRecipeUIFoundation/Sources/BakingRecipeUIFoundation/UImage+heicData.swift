//
//  UImage+heicData.swift
//  
//
//  Created by Moritz Schaub on 14.06.21.
//

import UIKit
import AVFoundation

public extension UIImage {
    enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case couldNotFinalize
    }
    
    func heicData(compressionQuality: CGFloat) throws -> Data {
        // 1
        let data = NSMutableData()
        guard let imageDestination =
                CGImageDestinationCreateWithData(
                    data, AVFileType.jpg as CFString, 1, nil
                )
        else {
            throw HEICError.heicNotSupported
        }
        
        // 2
        guard let cgImage = self.cgImage else {
            throw HEICError.cgImageMissing
        }
        
        // 3
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        // 4
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.couldNotFinalize
        }
        
        return data as Data
    }
}
