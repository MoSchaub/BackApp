//
//  ImageUtils.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

let largeConfiguration = UIImage.SymbolConfiguration(pointSize: 80, weight: .ultraLight)

struct Images {
    static let photo = UIImage(systemName: "photo", withConfiguration: largeConfiguration)!
    static let largePhoto = #imageLiteral(resourceName: "photo")
    static let bread = UIImage(named:"bread")!
    static let cake = UIImage(named: "cake")!
    static let rolls = UIImage(named: "roll")!
}
