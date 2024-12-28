// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore

protocol RecipeListViewDelegate {

    func navigateToSettings(from recipeListViewController: RecipeListViewController)

    func navigateToRecipeDetail(from recipeListViewController: RecipeListViewController, with: BackAppData.RecipeListItem)

    func presentNewRecipePopover(from recipeListViewController: RecipeListViewController)

    func presentRoomTempSheet(from recipeListViewController: RecipeListViewController)

    func presentImportAlert(from recipeListViewController: RecipeListViewController)

    func editRecipeViewController(for recipeId: Int64) -> EditRecipeViewController

}
