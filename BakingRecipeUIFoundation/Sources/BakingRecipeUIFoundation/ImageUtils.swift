//
//  ImageUtils.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

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
