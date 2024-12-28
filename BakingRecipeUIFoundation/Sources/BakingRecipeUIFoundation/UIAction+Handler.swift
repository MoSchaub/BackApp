// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  UIAction+Handler.swift
//  
//
//  Created by Moritz Schaub on 02.10.21.
//

import UIKit

public extension UIAction {
    var handler: UIActionHandler {
        get {
            typealias ActionHandlerBlock = @convention(block) (UIAction) -> Void
            let handler = value(forKey: "handler") as AnyObject
            return unsafeBitCast(handler, to: ActionHandlerBlock.self)
        }
    }
}
