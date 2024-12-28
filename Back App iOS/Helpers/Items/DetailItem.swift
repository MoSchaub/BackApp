// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

class DetailItem: TextItem {
    var detailLabel: String
    
    init(id: UUID = UUID(), name: String, detailLabel: String = "" ) {
        self.detailLabel = detailLabel
        super.init(id: id, text: name)
    }
}
