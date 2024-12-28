// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BackAppCore

extension RecipeListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .utility).async {
            guard !self.pressed else { return }
            self.pressed = true
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return}

            self.delegate.navigateToRecipeDetail(from: self, with: item)

            self.pressed = false
        }
    }

    private func navigateToRecipe(_ item: BackAppData.RecipeListItem) {
        delegate.navigateToRecipeDetail(from: self, with: item)
    }

}
