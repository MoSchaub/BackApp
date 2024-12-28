// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

class ImageItem: Item {
    var imageData: Data?
    
    init(id: UUID = UUID(), imageData: Data?) {
        self.imageData = imageData
        super.init(id: id)
    }
}
