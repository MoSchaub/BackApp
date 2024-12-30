// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore
import BakingRecipeFoundation

extension Step {
    func stepRow(scaleFactor: Double?, even: Bool) -> UIView {
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
        
        let containerView = UIView()
        containerView.addSubview(hstack)
        containerView.layer.cornerRadius = 10
        hstack.fillSuperview(padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        if even {
            containerView.backgroundColor = .secondaryCellBackgroundColor
        } else {
            containerView.backgroundColor = .cellBackgroundColor
        }
        
        return containerView
    }
}
