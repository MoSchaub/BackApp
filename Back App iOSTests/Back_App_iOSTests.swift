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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testScheduleFormHeaderColor() throws {
        let appData = BackAppData.shared(includeTestingRecipe: true)
        let recipeId = appData.allRecipes.first(where: { $0.name == Recipe.example.recipe.name})!.id!
        let recipeBinding = Binding {
            return appData.record(with: recipeId, of: Recipe.self)!
        } set: {
            appData.update($0)
        }

        
        let scheduleFormVC = ScheduleFormViewController(recipe: recipeBinding, appData: appData)
        
        
        scheduleFormVC.loadView()
        scheduleFormVC.viewDidLoad()
        if let cell = scheduleFormVC.dataSource.tableView(scheduleFormVC.tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as? CustomCell, let picker = cell.subviews.last! as? UISegmentedControl {
            scheduleFormVC.didSelectOption(sender: picker)
        }
    }

}
