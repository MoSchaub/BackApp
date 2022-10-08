//
//  BASplitViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 27.09.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import Foundation

class BASplitViewController: UISplitViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if UITraitCollection.current.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            // update nav bar
            NotificationCenter.default.post(name: .horizontalSizeClassDidChange, object: nil)
        }
    }

}
