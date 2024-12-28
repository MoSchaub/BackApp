// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  File.swift
//  
//
//  Created by Moritz Schaub on 27.10.20.
//

import UIKit

public extension UIAlertController {
    
    convenience init(preferredStyle: UIAlertController.Style) {
        self.init(title: nil, message: nil, preferredStyle: preferredStyle)
    }
}

