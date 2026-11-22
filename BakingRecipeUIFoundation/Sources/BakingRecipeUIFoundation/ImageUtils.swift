// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import ImageIO

@available(iOS 13.0, *)
fileprivate let largeConfiguration = UIImage.SymbolConfiguration(pointSize: 80, weight: .ultraLight)

@available(iOS 13.0, *)
public struct Images {
    static public let photo = UIImage(systemName: "photo", withConfiguration: largeConfiguration)!
    static public let largePhoto = #imageLiteral(resourceName: "photo")
    static public let bread = #imageLiteral(resourceName: "Brot")
    static public let cake = UIImage(named: "cake")!
    static public let rolls = UIImage(named: "roll")!
}

public extension UIImage {

    /// Decodes `data` into an image whose longest side is at most `maxPixelSize` pixels.
    ///
    /// Recipe photos are often full camera resolution (e.g. 4032×3024). Decoding them with
    /// `UIImage(data:)` allocates a full-size bitmap even for a small thumbnail, so ImageIO
    /// creates a downsampled image directly instead. The image orientation is applied.
    static func downsampled(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixelSize),
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
