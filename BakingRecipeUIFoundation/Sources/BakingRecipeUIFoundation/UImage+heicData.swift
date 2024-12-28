// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
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

        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                               space: cgImage.colorSpace!,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

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

    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func compressedDataToKb(value kb: Int, allowedMargin: CGFloat = 0.2) throws -> Data {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            let data = try holderImage.heicData(compressionQuality: 0.5)
            let ratio = data.count / bytes
            if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                complete = true
                return data
            } else {
                let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                compression -= (step * multiplier)
            }

            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return Data()
    }
}
