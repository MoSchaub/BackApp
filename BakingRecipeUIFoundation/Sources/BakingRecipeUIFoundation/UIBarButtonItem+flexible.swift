// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIBarButtonItem+flexible.swift
//  
//
//  Created by Moritz Schaub on 26.08.21.
//

import UIKit

public extension UIBarButtonItem {
    ///flexible item used as a spacer
    static var flexible: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}
