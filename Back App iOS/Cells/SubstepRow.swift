// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore
import BakingRecipeFoundation

fileprivate let CORNER_RADIUS: CGFloat = 5
fileprivate let PADDING_VERTICAL: CGFloat = 2
fileprivate let PADDING_HORIZONTAL: CGFloat = 3

fileprivate func containerViewForSubstepIngredient(subviews: [UIView], even: Bool) -> UIView {
    
    let hstack = UIStackView(arrangedSubviews: subviews)
    hstack.axis = .horizontal
    hstack.distribution = .equalSpacing
    
    
    let containerView = UIView()
    containerView.addSubview(hstack)
    containerView.layer.cornerRadius = CORNER_RADIUS
    hstack.fillSuperview(padding: .init(top: PADDING_VERTICAL, left: PADDING_HORIZONTAL, bottom: PADDING_VERTICAL, right: PADDING_HORIZONTAL))
    if even {
        containerView.backgroundColor = .secondaryCellBackgroundColor
    } else {
        containerView.backgroundColor = .cellBackgroundColor
    }
    
    return containerView
}

/// creates row for ingredient or substep
func stepSubRow(formattedName: String, tempText: String?, amountText: String, even: Bool) -> UIView {
    var subviews = [UIView]()
    
    let textStyle = UIFont.TextStyle.subheadline

    let nameLabel  = UILabel(frame: .zero)
    nameLabel.attributedText = NSAttributedString(string: formattedName, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
    nameLabel.textColor = .primaryCellTextColor
    subviews.append(nameLabel)
    
    // tempText is optional...
    if let tempText = tempText {
        let tempTextLabel = UILabel(frame: .zero)
        tempTextLabel.attributedText = NSAttributedString(string: tempText, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        tempTextLabel.textColor = .primaryCellTextColor
        subviews.append(tempTextLabel)
    }
    
    let amountLabel = UILabel(frame: .zero)
    amountLabel.attributedText = NSAttributedString(string: amountText, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
    amountLabel.textColor = .primaryCellTextColor
    subviews.append(amountLabel)
    
    return containerViewForSubstepIngredient(subviews: subviews, even: even)
}

extension Step {
    func stepRow(scaleFactor: Double?, even: Bool) -> UIView {
        return stepSubRow(formattedName: formattedName, tempText: formattedEndTemp(roomTemp: Standarts.roomTemp), amountText: totalFormattedMass(reader: BackAppData.shared.databaseReader, factor: scaleFactor ?? 1), even: even)
    }
}
