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
        let textStyle = UIFont.TextStyle.subheadline

        let nameLabel  = UILabel(frame: .zero)
        nameLabel.attributedText = NSAttributedString(string: formattedName, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        nameLabel.textColor = .primaryCellTextColor

        let tempTextLabel = UILabel(frame: .zero)
        tempTextLabel.attributedText = NSAttributedString(string: formattedEndTemp(roomTemp: Standarts.roomTemp), attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        tempTextLabel.textColor = .primaryCellTextColor

        let amountLabel = UILabel(frame: .zero)
        amountLabel.attributedText = NSAttributedString(string: totalFormattedMass(reader: BackAppData.shared.databaseReader, factor: scaleFactor ?? 1), attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        amountLabel.textColor = .primaryCellTextColor

        let hstack = UIStackView(arrangedSubviews: [nameLabel, tempTextLabel, amountLabel])
        hstack.axis = .horizontal
        hstack.distribution = .equalSpacing
        return hstack
    }
}
