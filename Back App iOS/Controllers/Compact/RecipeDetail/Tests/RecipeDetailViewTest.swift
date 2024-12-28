// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing
@testable import Back_App
@preconcurrency import BackAppCore
import BakingRecipeFoundation
import BakingRecipeUIFoundation

struct RecipeDetailViewTest {
    
    var sut: RecipeDetailViewController!
    
    init() async throws {
        self.sut = try await setUpSut()
        
        //sut.beginAppearanceTransition(true, animated: false)
    }
    
    func setUpSut() async throws -> RecipeDetailViewController? {
        try await MainActor.run {
            let appData = BackAppData.shared(includeTestingRecipe: true)
            let recipe = try #require(appData.allRecipes.first(where: { $0.name == Recipe.example.recipe.name }))
            let recipeId = try #require(recipe.id)
            let editVC = EditRecipeViewController(recipeId: recipeId, creating: false, appData: appData)
            return RecipeDetailViewController(recipeId: recipeId, editVC: editVC, recipeName: recipe.name)
        }
    }

    @Test func testTableViewIsNotNill() async throws {
        await #expect(sut.tableView != nil)
    }
    
    @Test func testNumberOfRowsInSection() async {
        await MainActor.run{
            #expect(sut.tableView.numberOfSections == 3, "TableView should have 2 sections after initial data is loaded.")
            #expect(sut.tableView.numberOfRows(inSection: 0) == 4, "TableView should have 1 row after initial data is loaded.")
            #expect(sut.tableView.numberOfRows(inSection: 1) == 2, "TableView should have 2 rows after initial data is loaded.")
            #expect(sut.tableView.numberOfRows(inSection: 2) == 0, "TableView should have 1 row after initial data is loaded.")
        }
    }
    
    @Test func testInfoStrip() async throws {
        try await MainActor.run {
            let cell = try #require(sut.dataSource.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as? InfoStripCell)
            
            let hstack = try #require(cell.subviews[0].subviews[1] )
            let vstack = try #require(hstack.subviews[0])
            let label = try #require(vstack.subviews[0] as? UILabel)
            #expect(label.text == "20 minutes")
        }
    }

}
