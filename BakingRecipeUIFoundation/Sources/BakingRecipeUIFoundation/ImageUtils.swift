// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
