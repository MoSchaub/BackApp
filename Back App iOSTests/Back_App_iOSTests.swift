//
//  Back_App_iOSTests.swift
//  Back App iOSTests
//
//  Created by Moritz Schaub on 02.07.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest
@testable import Back_App
import BackAppCore
import BakingRecipeFoundation
import SwiftUI

class Back_App_iOSTests: XCTestCase {
    
    var sut: ScheduleFormViewController!

    override func setUpWithError() throws {
        let appData = BackAppData.shared(includeTestingRecipe: true)
        let recipeId = appData.allRecipes.first(where: { $0.name == Recipe.example.recipe.name})!.id!
        let recipeBinding = Binding {
            return appData.record(with: recipeId, of: Recipe.self)!
        } set: {
            appData.update($0)
        }

        
        sut = ScheduleFormViewController(recipe: recipeBinding, appData: appData)
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testTableViewIsNotNil() throws {
        XCTAssertNotNil(sut.tableView, "The table view shoud be initialized")
    }
    
    func testNumberOfRowsInSection() {
            // Expecting 2 rows based on the initial data provided in the viewDidLoad snapshot
        XCTAssertEqual(sut.tableView.numberOfSections, 2)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1, "TableView should have 1 row after initial data is loaded.")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 1), 2, "TableView should have 2 rows after initial data is loaded.")
    }
    
    
    
    func testScheduleFormHeaderColor() throws {
        let cell = sut.dataSource.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as! CustomCell
        let picker = cell.subviews.last! as! UISegmentedControl
        
        sut.didSelectOption(sender: picker)
        XCTAssertEqual(picker.backgroundColor, UIColor.cellBackgroundColor)
        
    }

}
