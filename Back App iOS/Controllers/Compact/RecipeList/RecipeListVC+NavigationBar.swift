//
//  RecipeListViewController+NavigationBar.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 13.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeStrings

extension RecipeListViewController {
    @objc func configureNavigationBar(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { //force to main thread since ui is updated
            self.title = Strings.recipes
            self.navigationController?.navigationBar.prefersLargeTitles = true

            //left / leading
            let settingsButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(self.navigateToSettings))
            let editButtonItem = self.editButtonItem
            self.navigationItem.leftBarButtonItems = [settingsButtonItem, editButtonItem]

            //trailing
            if #available(iOS 14.0, *) {
                let importAction = UIAction(title: Strings.importFile) { action in
                    self.openImportFilePopover()
                }
                let addAction = UIAction(title: Strings.addRecipe, image: UIImage(systemName: "plus")) { _ in
                    self.presentAddRecipePopover(self.navigationItem.rightBarButtonItem!)
                }

                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.addRecipe, image: UIImage(systemName: "plus"), primaryAction: addAction, menu: UIMenu(children: [addAction, importAction]))
            } else {
                let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.presentAddRecipePopover))
                let importButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.down.doc"), style: .plain, target: self, action: #selector(self.openImportFilePopover))
                self.navigationItem.rightBarButtonItems = [addButtonItem, importButtonItem]
            }
            self.navigationItem.searchController = self.searchController

            if let completion = completion {
                completion()
            }
        }
    }

    @objc private func navigateToSettings() {
        delegate.navigateToSettings(from: self)
    }

    @objc private func openImportFilePopover() {
        //set the delegate
        self.documentPicker.delegate = self

        // Present the document picker.
        self.present(documentPicker, animated: true, completion: deselectRow)
    }

    ///present popover for creating new recipe
    @objc internal func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        delegate.presentNewRecipePopover(from: self)
        //create the vc
        
    }
}

