// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  UITableViewController+setUp3ButtonToolbar.swift
//  
//
//  Created by Moritz Schaub on 14.08.21.
//

import UIKit

public extension UITableViewController {
    func setUp3ItemToolbar(item1: UIBarButtonItem, item2: UIBarButtonItem, item3: UIBarButtonItem, shouldFillNavbar: Bool = true) {
        // put the buttons in the appropriate bar and show the right bar and hide the other one

        if UITraitCollection.current.horizontalSizeClass == .regular { // ipad and large iphone landscape

            if shouldFillNavbar {
                // fill navbar with buttons
                self.navigationItem.rightBarButtonItems = [item3, item2, item1]
            }

            // disable the toolbar
            self.navigationController?.setToolbarHidden(true, animated: true)

        } else { // normal iphone format and small ipad

            if shouldFillNavbar {
                // disable the navbar
                self.navigationItem.rightBarButtonItems = []
            }

            //enable the toolbar
            self.navigationController?.setToolbarHidden(false, animated: true)

            //fill the toolbar with buttons
            self.setToolbarItems([item1, .flexible, item2, .flexible, item3], animated: false)
        }
    }
}
