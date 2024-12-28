// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BackAppCore
import BakingRecipeStrings

extension RecipeListCoordinator {
    func presentNewRecipePopover(from recipeListViewController: RecipeListViewController) {
        DispatchQueue.main.async {
            do {
                let recipeId = try self.delegate.appData.addBlankRecipe().id!
                let editRecipeViewController = EditRecipeViewController(
                    recipeId: recipeId, creating: true, appData: self.delegate.appData)

                let navigationController = UINavigationController(rootViewController: editRecipeViewController)
                navigationController.modalPresentationStyle = .fullScreen

                recipeListViewController.present(navigationController, animated: true)
            } catch {
                print(error)
            }
        }
    }

    func presentRoomTempSheet(from recipeListViewController: RecipeListViewController) {
        let roomTempBinding = Binding {
            return Standarts.roomTemp
        } set: {
            Standarts.roomTemp = $0
        }

        let hostingController = UIHostingController(rootView: RoomTempPickerSheet(roomTemp: Binding { return 0.0} set: { _ in}, dissmiss: {}))

        let roomTempSheet = RoomTempPickerSheet(roomTemp: roomTempBinding) {
            hostingController.dismiss(animated: true)
        }

        hostingController.rootView = roomTempSheet

        recipeListViewController.present(hostingController, animated: true)
    }

    func presentImportAlert(from recipeListViewController: RecipeListViewController) {
        DispatchQueue.main.async { //force to main thread since this is ui code

            //create the alert
            let alert = UIAlertController(title: inputAlertTitle, message: inputAlertMessage, preferredStyle: .alert)

            //add the "ok" action/option/button
            alert.addAction(UIAlertAction(title: Strings.Alert_ActionOk, style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))

            //finally present it
            recipeListViewController.present(alert, animated: true)
        }
    }
}
