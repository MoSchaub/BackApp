//
//  DetailItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation

class DetailItem: TextItem {
    var detailLabel: String
    
    init(id: UUID = UUID(), name: String, detailLabel: String = "" ) {
        self.detailLabel = detailLabel
        super.init(id: id, text: name)
    }
}
