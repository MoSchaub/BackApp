// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  UITableViewController+setUpItemToolbar.swift
//
//
//  Created by Moritz Schaub on 14.08.21.
//

import UIKit

private var openSettingsKey: UInt8 = 0

public extension UITableViewController {
    
    // Store/retrieve the openSettings closure on the controller
    private var _openSettingsHandler: (() -> Void)? {
        get { objc_getAssociatedObject(self, &openSettingsKey) as? (() -> Void) }
        set { objc_setAssociatedObject(self, &openSettingsKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    @objc private func _ba_openSettingsTapped() {
        _openSettingsHandler?()
    }
    
    func setUpItemToolbar(item1: UIBarButtonItem,
                          item2: UIBarButtonItem,
                          item3: UIBarButtonItem,
                          openSettings: @escaping () -> Void) {
        // put the buttons in the appropriate bar and show the right bar and hide the other one
        
        if UITraitCollection.current.horizontalSizeClass == .regular { // ipad and large iphone landscape
            
            
            // fill navbar with buttons
            self.navigationItem.rightBarButtonItems = [item3, item2, item1]
            
            
            // disable the toolbar
            self.navigationController?.setToolbarHidden(true, animated: true)
            
        } else { // normal iphone format and small ipad
            
            // first empty the bar
            self.navigationItem.rightBarButtonItems = []
            if #available(iOS 14.0, *) {
                // create a settings item that triggers the provided closure
                self._openSettingsHandler = openSettings
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: UIImage(systemName: "gear"),
                    style: .plain,
                    target: self,
                    action: #selector(_ba_openSettingsTapped)
                )
            }
            
            // enable the toolbar
            self.navigationController?.setToolbarHidden(false, animated: true)
            
            // fill the toolbar with buttons
            if #available(iOS 26.0, *) {
                self.setToolbarItems([item1, item2, .flexible, item3], animated: false)
            } else {
                self.setToolbarItems([item1, .flexible, item2, .flexible, item3], animated: false)
            }
        }
    }
}
