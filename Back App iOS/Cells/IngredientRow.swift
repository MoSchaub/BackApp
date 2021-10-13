//
//  IngredientRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//
import BakingRecipeFoundation
import BackAppCore

extension Ingredient {

    func stackView(scaleFactor: Double?, tempText: String) -> UIStackView {
        var subviews = [UIView]()

        let nameLabel  = UILabel(frame: .zero)
        nameLabel.text = self.formattedName
        nameLabel.textColor = .primaryCellTextColor
        subviews.append(nameLabel)

        if self.type == .bulkLiquid {

            let tempTextLabel = UILabel(frame: .zero)
            tempTextLabel.text = tempText
            tempTextLabel.textColor = .primaryCellTextColor
            subviews.append(tempTextLabel)
        }

        let amountLabel = UILabel(frame: .zero)
        amountLabel.text = self.scaledFormattedAmount(with: scaleFactor ?? 1)
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
