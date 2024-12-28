// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing
@testable import Back_App
@preconcurrency import BackAppCore
import BakingRecipeFoundation
import SwiftUI

@MainActor struct Back_App_iOSTests{
    
    var sut: ScheduleFormViewController
    
    @MainActor init() {
        let appData = BackAppData.shared(includeTestingRecipe: true)
        let recipeId = appData.allRecipes.first(where: { $0.name == Recipe.example.recipe.name})!.id!
        let recipeBinding = Binding {
            return appData.record(with: recipeId, of: Recipe.self)!
        } set: {
            appData.update($0)
        }

        sut = ScheduleFormViewController(recipe: recipeBinding, appData: appData)
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
    }
    
    @Test func testTableViewIsNotNil() {
        #expect(sut.tableView != nil, "The table view shoud be initialized")
    }
    
    @Test func testNumberOfRowsInSection() {
            // Expecting 2 rows based on the initial data provided in the viewDidLoad snapshot
        #expect(sut.tableView.numberOfSections == 2)
        #expect(sut.tableView.numberOfRows(inSection: 0) == 1, "TableView should have 1 row after initial data is loaded.")
        #expect(sut.tableView.numberOfRows(inSection: 1) == 2, "TableView should have 2 rows after initial data is loaded.")
    }
    
    @Test func testScheduleFormHeaderColor() {
        let cell = sut.dataSource.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as! CustomCell
        let picker = cell.subviews.last! as! UISegmentedControl
        
        sut.didSelectOption(sender: picker)
        #expect(picker.backgroundColor == UIColor.cellBackgroundColor)
        
    }

}
