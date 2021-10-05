//
//  StepRow.swift
//
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BackAppCore

extension Step {

    private func firstLineHStack(showDate: Bool) -> UIStackView {
        let primparyLabel = UILabel(frame: .zero)
        primparyLabel.attributedText = NSAttributedString(string: formattedName, attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)])
        primparyLabel.textColor = .primaryCellTextColor

        let secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.attributedText = NSAttributedString(string: formattedTemp(roomTemp: Standarts.roomTemp), attributes: [.font: UIFont.preferredFont(forTextStyle: .subheadline)])
        secondaryLabel.textColor = .secondaryCellTextColor

        let nameTempVStack = UIStackView(arrangedSubviews: [primparyLabel, secondaryLabel])
        nameTempVStack.axis = .vertical
        nameTempVStack.alignment = .leading

        let cornerLabel = UILabel(frame: .zero)
        if showDate {
            cornerLabel.text = BackAppData.shared.formattedStartDate(for: self, with: recipeId)
            cornerLabel.textColor = .primaryCellTextColor
        } else {
            cornerLabel.attributedText = NSAttributedString(string: formattedDuration, attributes: [.font:UIFont.preferredFont(forTextStyle: .subheadline)])
            cornerLabel.textColor = .secondaryCellTextColor
        }

        let hstack = UIStackView(arrangedSubviews: [nameTempVStack, cornerLabel])
        hstack.axis = .horizontal
        hstack.alignment = .center

        return hstack
    }

    func vstack(scaleFactor: Double? = nil, editing: Bool = false) -> UIStackView {
        var subviews: [UIView] = [firstLineHStack(showDate: scaleFactor != nil)]
        subviews.append(contentsOf: ingredientStackViews(scaleFactor: scaleFactor))
        subviews.append(contentsOf: substepStackViews(scaleFactor: scaleFactor))

        if !editing {
            let notesLabel = UILabel(frame: .zero)
            notesLabel.text = notes
            notesLabel.textColor = .primaryCellTextColor
            notesLabel.numberOfLines = 0

            subviews.append(notesLabel)
        }

        let totalVStack = UIStackView(arrangedSubviews: subviews)
        totalVStack.axis = .vertical
        totalVStack.spacing = scaleFactor != nil ? 5 : 0
        return totalVStack
    }


    func ingredientStackViews(scaleFactor: Double?) -> [UIStackView] {
        self.ingredients(reader: BackAppData.shared.databaseReader).map { ingredient in
            ingredient.stackView(scaleFactor: scaleFactor, tempText: ingredient.tempText(in: self))
        }
    }

    func substepStackViews(scaleFactor: Double?) -> [UIStackView] {
        self.sortedSubsteps(reader: BackAppData.shared.databaseReader).map { substep in
            substep.stepRow(scaleFactor: scaleFactor)
        }
    }
}
