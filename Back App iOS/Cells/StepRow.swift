// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeFoundation
import BackAppCore

extension Step {

    private func firstLineHStack(showDate: Bool) -> UIStackView {

        // primary Label with formated name and headline font
        let primparyLabel = UILabel(frame: .zero)
        primparyLabel.attributedText = NSAttributedString(string: formattedName, attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)])
        primparyLabel.textColor = .primaryCellTextColor

        // secondary Label
        let secondaryLabel = UILabel(frame: .zero)

        //duration and temp if showing date else only temp
        let secondaryText = (showDate ? formattedDuration + ", " : "") + formattedTemp(roomTemp: Standarts.roomTemp)
        secondaryLabel.attributedText = NSAttributedString(string: secondaryText, attributes: [.font: UIFont.preferredFont(forTextStyle: .subheadline)])
        secondaryLabel.textColor = .secondaryCellTextColor //"gray" color

        // add primary and secondary Label together in a vertical stack
        let nameTempVStack = UIStackView(arrangedSubviews: [primparyLabel, secondaryLabel])
        nameTempVStack.axis = .vertical
        nameTempVStack.alignment = .leading

        // label in the corner with either date or duration
        let cornerLabel = UILabel(frame: .zero)
        if showDate {
            cornerLabel.attributedText = NSAttributedString(string: BackAppData.shared.formattedStartDate(for: self, with: recipeId), attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
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

    /// vertical stack view for the step in recipe detail
    /// - Parameter scaleFactor: the scalefactor for the amount, This determines wether it shows the date or the duration in the corner and wether there is spacing between the ingredients
    /// - Parameter editing: whether to show the notes label 
    func vstack(scaleFactor: Double? = nil, editing: Bool = false) -> UIStackView {
        var subviews = [UIView]()

        //first line
        subviews.append(firstLineHStack(showDate: scaleFactor != nil))
        subviews.append(contentsOf: ingredientStackViews(scaleFactor: scaleFactor))
        subviews.append(contentsOf: substepStackViews(scaleFactor: scaleFactor))

        if !editing && !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let notesLabel = UILabel(frame: .zero)
            notesLabel.attributedText = NSAttributedString(string: notes.trimmingCharacters(in: .whitespacesAndNewlines), attributes: [.font : UIFont.preferredFont(forTextStyle: .subheadline)])
            notesLabel.textColor = .primaryCellTextColor
            notesLabel.numberOfLines = 0 //to make it autogrow

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
