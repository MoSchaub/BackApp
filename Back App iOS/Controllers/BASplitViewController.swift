// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

class BASplitViewController: UISplitViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if UITraitCollection.current.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            // update nav bar
            NotificationCenter.default.post(name: .horizontalSizeClassDidChange, object: nil)
        }
    }

}
