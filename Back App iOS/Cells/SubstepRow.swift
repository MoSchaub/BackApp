//
//  SubstepRow.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 24.08.21.
//  Copyright © 2021 Moritz Schaub. All rights reserved.
//

import BackAppCore
import BakingRecipeFoundation

extension Step {
    func stepRow(scaleFactor: Double?) -> UIStackView {
        let nameLabel  = UILabel(frame: .zero)
        nameLabel.text = self.formattedName
        nameLabel.textColor = .primaryCellTextColor

        let tempTextLabel = UILabel(frame: .zero)
        tempTextLabel.text = self.formattedEndTemp(roomTemp: Standarts.roomTemp)
        tempTextLabel.textColor = .primaryCellTextColor

        let amountLabel = UILabel(frame: .zero)
        amountLabel.text = self.totalFormattedMass(reader: BackAppData.shared.databaseReader, factor: scaleFactor ?? 1)
        amountLabel.textColor = .primaryCellTextColor

        let hstack = UIStackView(arrangedSubviews: [nameLabel, tempTextLabel, amountLabel])
        hstack.axis = .horizontal
        hstack.distribution = .equalSpacing
        return hstack
    }
}
