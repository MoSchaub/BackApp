// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

public class TextItem: Item {
    public var text: String
    
    public init(id: Int? = nil, text: String) {
        self.text = text
        super.init(id: id)
    }
}
