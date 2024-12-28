// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

class RecipeItem: TextItem {
    var imageData: Data?
    var minuteLabel: String
    
    init(id: UUID = UUID(), name: String, imageData: Data?, minuteLabel: String) {
        self.imageData = imageData
        self.minuteLabel = minuteLabel
        super.init(id: id, text: name)
    }
}
