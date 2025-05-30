// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest
import BakingRecipeFoundation
import BackAppCore
@testable import Back_App

class CellTests: XCTestCase {

    func test_ingredientRow() throws {

        var ingredient = try XCTUnwrap(Recipe.example.stepIngredients.first?.ingredients.first)
        let containerView = ingredient.stackView(scaleFactor: nil, tempText: "", even: false)
        var stackView = containerView.subviews.first as! UIStackView

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
        stackView = ingredient.stackView(scaleFactor: scaleFactor, tempText: tempText, even: false).subviews.first as! UIStackView
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
            _ = try XCTUnwrap(stackview.subviews[index+1].subviews.first as? UIStackView)
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
    
    func testStepRowShowingFormattedStartDate() throws {
        var complexExample = Recipe.complexExample(number: 0)
        let steps = try insert(recipeTransfer: &complexExample)
        
        for step in steps {
            let stepRow = step.vstack(scaleFactor: 1)
            let label = stepRow.subviews[0].subviews.last as! UILabel
            XCTAssertEqual(label.text, BackAppData.shared.formattedStartDate(for: step, with: complexExample.recipe.id!))
        }
    }
    
    func testStepRowTemp() throws {
        var complexExample = Recipe.complexExample(number: 0)
        let steps = try insert(recipeTransfer: &complexExample)
        
        for step in steps {
            let stepRow = step.vstack()
            let label = stepRow.subviews[safe: 0]?.subviews[safe: 0]?.subviews[safe: 1] as? UILabel
            XCTAssertEqual(label?.text, step.formattedTemp(roomTemp: Standarts.roomTemp))
        }
    }
    
    func testStepRowEndTemp() throws {
        var complexExample = Recipe.complexExample(number: 0)
        let steps = try insert(recipeTransfer: &complexExample)
        var step = steps.first
        step?.endTemp = 100
        BackAppData.shared.update(step!)
        XCTAssert(step?.endTempEnabled ?? false)
        XCTAssertEqual(step?.endTemp, 100)
        
        
        let stepRow = step?.vstack()
        let label = stepRow?.subviews[safe: 0]?.subviews[safe: 0]?.subviews[safe: 1] as? UILabel
        XCTAssertEqual(label?.text, step?.formattedEndTemp(roomTemp: Standarts.roomTemp))
    }
}

func insert(recipeTransfer: inout RecipeTransferType, complex: Bool = false) throws -> [Step] {
    var recipe = recipeTransfer.recipe
    let appData = BackAppData.shared(resetDatabase: true)

    appData.insert(&recipe)
    try XCTAssert(appData.databaseReader.read(recipe.exists))

    var previousStepId: Int64?

    _ = try recipeTransfer.stepIngredients.map {
        var step = $0.step
        step.recipeId = recipe.id!

        //check if there is any superstep id that is not nil. any superstep id is used as a notation to say that the step is suposed to be substep of the previously inserted step. This means the superstepid is not set if it was nil before.
        if !complex, step.superStepId != nil, let previousStepId = previousStepId {
            step.superStepId = previousStepId
        } else if complex, let superStepId = step.superStepId, let superStep = appData.steps(with: step.recipeId).first(where: { $0.number == superStepId }), let newId = superStep.id  { // check only steps of the recipe to improve efficiency and don't missmatch the superstep.
            step.superStepId = newId
        }
        appData.insert(&step)

        try XCTAssertTrue(appData.databaseReader.read(step.exists))

        let stepId = step.id!
        previousStepId = stepId

        for ingredient in $0.ingredients {
            var ingredient = ingredient
            ingredient.stepId = stepId
            appData.insert(&ingredient)
            try XCTAssert(appData.databaseReader.read(ingredient.exists))
        }
    }

    let steps = appData.steps(with: recipe.id!)
    recipeTransfer.recipe = recipe
    XCTAssertEqual(steps.count, recipeTransfer.stepIngredients.count)
    return steps
}


private extension UILabel {
    func checkLabel(text: String, textStyle: UIFont.TextStyle = .subheadline, textColor: UIColor? = .primaryCellTextColor) {
        XCTAssertEqual(self.text, text)
        XCTAssertEqual(self.font, .preferredFont(forTextStyle: textStyle))
        XCTAssertEqual(self.textColor, textColor)
    }
}
