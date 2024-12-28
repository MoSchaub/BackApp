// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

public class ImageItem: Item {
    public var imageData: Data?
    
    public init(imageData: Data?) {
        self.imageData = imageData
        super.init()
    }
}
