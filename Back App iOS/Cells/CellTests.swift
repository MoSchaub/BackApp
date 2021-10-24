//
//  CellTests.swift
//  Back App iOSTests
//
//  Created by Moritz Schaub on 16.10.21.
//  Copyright © 2021 Moritz Schaub. All rights reserved.
//

import XCTest
import BakingRecipeFoundation
import BackAppCore
@testable import Back_App

class CellTests: XCTestCase {

    func test_ingredientRow() throws {

        var ingredient = try XCTUnwrap(Recipe.example.stepIngredients.first?.ingredients.first)
        var stackView = ingredient.stackView(scaleFactor: nil, tempText: "")

        // 2 subviews if not bulk Liquid
        XCTAssertEqual(stackView.subviews.count, 2)

        // checkNameLabel
        var nameLabel = try XCTUnwrap(stackView.subviews.first as? UILabel)
        nameLabel.checkLabel(text: ingredient.formattedName)

        var massLabel = try XCTUnwrap(stackView.subviews.last as? UILabel)
        massLabel.checkLabel(text: ingredient.formattedAmount)

        ingredient.type = .bulkLiquid
        ingredient.name = ""
        let scaleFactor = 2.0
        let tempText = "test"
        stackView = ingredient.stackView(scaleFactor: scaleFactor, tempText: tempText)
        XCTAssertEqual(stackView.subviews.count, 3)

        // check nameLabel still has the formatted Name if it is not empty
        nameLabel = try XCTUnwrap(stackView.subviews.first as? UILabel)
        nameLabel.checkLabel(text: ingredient.formattedName)

        let tempTextLabel = try XCTUnwrap(stackView.subviews[1] as? UILabel)
        tempTextLabel.checkLabel(text: tempText)

        massLabel = try XCTUnwrap(stackView.subviews.last as? UILabel)
        massLabel.checkLabel(text: ingredient.scaledFormattedAmount(with: scaleFactor))
    }

    func test_stepRow() throws {
        let appData = BackAppData.shared(includeTestingRecipe: true)
        var step = try XCTUnwrap(appData.allSteps.first)
        var stackview = step.vstack()

        XCTAssertEqual(stackview.subviews.count, 6)
        func firstRow() throws -> UIStackView { try XCTUnwrap(stackview.subviews.first as? UIStackView) }
        func primarySecondaryStack() throws -> UIStackView { try XCTUnwrap(firstRow().subviews.first as? UIStackView)}

        // primary Label contains the formatted name of the step
        func primaryLabel() throws -> UILabel { try XCTUnwrap(primarySecondaryStack().subviews.first as? UILabel) }
        try primaryLabel().checkLabel(text: step.formattedName, textStyle: .headline)

        //secondary Label contains the temp or the temp and duration if used for schedule
        func secondaryLabel() throws -> UILabel { try XCTUnwrap(primarySecondaryStack().subviews.last as? UILabel) }
        try secondaryLabel().checkLabel(text: step.formattedTemp(roomTemp: Standarts.roomTemp), textColor: .secondaryCellTextColor)

        // corner Label containing formatted Duration or date
        func cornerLabel() throws -> UILabel { try XCTUnwrap(firstRow().subviews.last as? UILabel)}
        try cornerLabel().checkLabel(text: step.formattedDuration, textColor: .secondaryCellTextColor)

        // test that ingredient rows exist
        for (index) in appData.ingredients(with: step.id!).indices {
            _ = try XCTUnwrap(stackview.subviews[index+1] as? UIStackView)
        }

        func notesLabel() throws -> UILabel { try XCTUnwrap(stackview.subviews.last as? UILabel)}
        let notes = "aneraneraneraneriauneritnertaudneruineduiareuirdaenuidraenuidraenuidraeuidraenuidreuidratuidtae"
        func testNotes(exists: Bool) throws {
            if exists {
                XCTAssertEqual(stackview.subviews.count, 7)
                try notesLabel().checkLabel(text: notes)
            } else {
                XCTAssertEqual(stackview.subviews.count, 6)
                XCTAssertNil(stackview.subviews.last as? UILabel)
            }
        }

        //test that notes dont exist
        try testNotes(exists: false)

        // test that notes exist
        step.notes = notes
        stackview = step.vstack()
        try testNotes(exists: true)

        step.notes = ""

        // new vstack with scale factor
        stackview = step.vstack(scaleFactor: 1)

        //nothing should change for primaryLabel
        try primaryLabel().checkLabel(text: step.formattedName, textStyle: .headline)

        //secondary Label now contains formattedDuration and formatted Temp
        try secondaryLabel().checkLabel(text: step.formattedDuration + ", " + step.formattedTemp(roomTemp: Standarts.roomTemp), textColor: .secondaryCellTextColor)

        // cornerLabel should now contain date and textColor should be primaryCellText
        try cornerLabel().checkLabel(text: appData.formattedStartDate(for: step, with: step.recipeId), textStyle: .body, textColor: .primaryCellTextColor)

        //test that notes dont exist
        try testNotes(exists: false)

        //check notes exist
        step.notes = notes
        stackview = step.vstack(scaleFactor: 1)
        try testNotes(exists: true)

        //check that they do not exist
        stackview = step.vstack(scaleFactor: 1, editing: true)
        try testNotes(exists: false)
    }
}


private extension UILabel {
    func checkLabel(text: String, textStyle: UIFont.TextStyle = .subheadline, textColor: UIColor? = .primaryCellTextColor) {
        XCTAssertEqual(self.text, text)
        XCTAssertEqual(self.font, .preferredFont(forTextStyle: textStyle))
        XCTAssertEqual(self.textColor, textColor)
    }
}
