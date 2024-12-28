// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  UITableViewController+deselectRow.swift
//  
//
//  Created by Moritz Schaub on 13.10.22.
//

import UIKit

public extension UITableViewController {
    func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
