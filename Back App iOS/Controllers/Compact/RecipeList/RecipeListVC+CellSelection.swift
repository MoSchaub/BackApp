// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BackAppCore

extension RecipeListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // UIKit calls this on the main actor; the data source must only be read there
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate.navigateToRecipeDetail(from: self, with: item)
    }

    private func navigateToRecipe(_ item: BackAppData.RecipeListItem) {
        delegate.navigateToRecipeDetail(from: self, with: item)
    }

}
