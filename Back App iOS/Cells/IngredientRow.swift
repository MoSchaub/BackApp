// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BakingRecipeFoundation
import BackAppCore

extension Ingredient {

    func stackView(scaleFactor: Double?, tempText: String) -> UIStackView {
        var subviews = [UIView]()

        let textStyle = UIFont.TextStyle.subheadline

        let nameLabel  = UILabel(frame: .zero)
        nameLabel.attributedText = NSAttributedString(string: self.formattedName, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        nameLabel.textColor = .primaryCellTextColor
        subviews.append(nameLabel)

        if self.type == .bulkLiquid {

            let tempTextLabel = UILabel(frame: .zero)
            tempTextLabel.attributedText = NSAttributedString(string: tempText, attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
            tempTextLabel.textColor = .primaryCellTextColor
            subviews.append(tempTextLabel)
        }

        let amountLabel = UILabel(frame: .zero)
        amountLabel.attributedText = NSAttributedString(string: scaledFormattedAmount(with: scaleFactor ?? 1), attributes: [.font : UIFont.preferredFont(forTextStyle: textStyle)])
        amountLabel.textColor = .primaryCellTextColor
        subviews.append(amountLabel)

        let hstack = UIStackView(arrangedSubviews: subviews)
        hstack.axis = .horizontal
        hstack.distribution = .equalSpacing
        return hstack
    }

    func tempText(in step: Step) -> String {
        if let temp = try? step.bulkLiquidTemperature(roomTemp: Standarts.roomTemp, kneadingHeating: Standarts.kneadingHeating, databaseReader: BackAppData.shared.databaseReader) {
            return Measurement(value: temp, unit: .celsius).formatted
        } else {
            print("Error getting the temp for the ingredient with name: \(self.formattedName)")
            return "error"
        }
    }
}
