//
//  RecipeLIstViewDelegate.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 13.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import BackAppCore

protocol RecipeListViewDelegate {

    func navigateToSettings(from recipeListViewController: RecipeListViewController)

    func navigateToRecipeDetail(from recipeListViewController: RecipeListViewController, with: BackAppData.RecipeListItem)

    func presentNewRecipePopover(from recipeListViewController: RecipeListViewController)

    func presentRoomTempSheet(from recipeListViewController: RecipeListViewController)

    func presentImportAlert(from recipeListViewController: RecipeListViewController)

    func editRecipeViewController(for recipeId: Int64) -> EditRecipeViewController

}
