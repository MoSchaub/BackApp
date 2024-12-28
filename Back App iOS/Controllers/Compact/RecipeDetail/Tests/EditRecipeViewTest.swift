// Copyright © 2024 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing
@testable import Back_App
@preconcurrency import BackAppCore
import BakingRecipeFoundation


@MainActor struct EditRecipeViewTest {
    
    var sut: EditRecipeViewController
    
    init() {
        let appData = BackAppData.shared(includeTestingRecipe: true)
        let recipeId = appData.allRecipes.first(where: { $0.name == Recipe.example.recipe.name})!.id!
        sut = EditRecipeViewController(recipeId: recipeId, creating: false, appData: appData)
        
        self.sut.beginAppearanceTransition(true, animated: false)
    }

    @Test func testTableViewIsNotNill() throws {
        #expect(sut.tableView != nil)
    }
    
    @Test func testNumberOfRowsInSection() {
        #expect(sut.tableView.numberOfSections == 5, "TableView should have 5 sections after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 0) == 1, "TableView should have 1 row after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 1) == 2, "TableView should have 2 rows after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 2) == 1, "TableView should have 1 row after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 3) == 3, "TableView should have 3 rows after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 4) == 1, "TableView should have 1 row after initial data is loaded.")
    }

    @Test func testZeroMinutesBug() throws {
        let cell = try #require(sut.dataSource.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as? InfoStripCell)
        
        let hstack = try #require(cell.subviews[0].subviews[1] )
        let vstack = try #require(hstack.subviews[0])
        let label = try #require(vstack.subviews[0] as? UILabel)
        #expect(label.text == "20 minutes")
    }
}
