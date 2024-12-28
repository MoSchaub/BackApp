// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit

let largeConfiguration = UIImage.SymbolConfiguration(pointSize: 80, weight: .ultraLight)

struct Images {
    static let photo = UIImage(systemName: "photo", withConfiguration: largeConfiguration)!
    static let largePhoto = #imageLiteral(resourceName: "photo")
    static let bread = UIImage(named:"bread")!
    static let cake = UIImage(named: "cake")!
    static let rolls = UIImage(named: "roll")!
}
