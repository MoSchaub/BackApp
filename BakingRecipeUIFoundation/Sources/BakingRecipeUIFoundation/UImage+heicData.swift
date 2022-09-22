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

        //create image destination with mutable data
        let data = NSMutableData()
        guard let imageDestination =
                CGImageDestinationCreateWithData(
                    data, AVFileType.jpg as CFString, 1, nil
                )
        else {
            throw HEICError.heicNotSupported
        }
        
        guard let cgImage = self.cgImage else {
            throw HEICError.cgImageMissing
        }
        
        // compression as option
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        // put it all together and finalize
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.couldNotFinalize
        }
        
        return data as Data
    }

    //helper function to fix rotating images.
    func fixOrientation() -> UIImage {
        guard let cgImage = cgImage else { return self }

        if imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))

        case .up, .upMirrored:
            break

        @unknown default:
            return self
        }

        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break

        @unknown default:
            return self
        }

        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

            ctx.concatenate(transform)

            switch imageOrientation {

            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }

            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }

        // something failed -- return original
        return self
    }
}
