// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BakingRecipeStrings

extension RecipeListViewController {

    /// Whether the list is shown as the sidebar of the split view (iPad, unfolded iPhone Duo).
    ///
    /// The sidebar is too narrow for the title next to the gear, Edit and + buttons,
    /// so it only keeps + in the bar and moves Edit and Settings into the overflow menu (iOS 16+).
    var usesSidebarNavigationBar: Bool {
        guard #available(iOS 16.0, *) else { return false }
        return splitViewController?.traitCollection.horizontalSizeClass == .regular
    }

    @objc func configureNavigationBar(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { //force to main thread since ui is updated
            self.title = Strings.recipes
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .automatic

            let addButtonItem = self.makeAddButtonItem()

            if #available(iOS 16.0, *), self.usesSidebarNavigationBar {
                self.navigationItem.leftBarButtonItems = nil
                // while editing, Done has to stay reachable in the bar
                self.navigationItem.rightBarButtonItems = self.isEditing ? [self.editButtonItem] : [addButtonItem]
                self.navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { completion in
                    completion(self.overflowMenuItems())
                }
            } else {
                if #available(iOS 16.0, *) {
                    self.navigationItem.additionalOverflowItems = nil
                }

                //left / leading
                self.navigationItem.leftBarButtonItems = [self.makeSettingsButtonItem()]

                //trailing
                // while editing, the system Done item ends editing
                let editItem = self.isEditing ? self.editButtonItem : self.makeEditButtonItem()
                self.navigationItem.rightBarButtonItems = [addButtonItem, .flexible, editItem]
            }

            // search
            self.navigationItem.searchController = self.searchController
            // The search filters this list, so keep it in the sidebar (HIG: "Include search at the top of
            // the sidebar when filtering content or navigation there"). Allowing external integration
            // let the split view move it to the empty detail column, where it wasn't shown at all.
            if #available(iOS 26.0, *) {
                self.navigationItem.searchBarPlacementAllowsExternalIntegration = false
            }

            if let completion = completion {
                completion()
            }
        }
    }

    private func makeSettingsButtonItem() -> UIBarButtonItem {
        let settingsButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(self.navigateToSettings))
        settingsButtonItem.title = Strings.settings
        settingsButtonItem.accessibilityIdentifier = AccessibilityID.settingsButton
        return settingsButtonItem
    }

    /// The pencil that starts editing the list.
    ///
    /// A symbol instead of the text-only system Edit item, which stays in a horizontal bar
    /// instead of moving into the vertical bar on iPhone Duo.
    private func makeEditButtonItem() -> UIBarButtonItem {
        let editButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(self.startEditing))
        editButtonItem.title = Strings.EditButton_Edit
        editButtonItem.isEnabled = self.editButtonItem.isEnabled
        editButtonItem.accessibilityIdentifier = AccessibilityID.editRecipeListAction
        return editButtonItem
    }

    @objc private func startEditing() {
        setEditing(true, animated: true)
    }

    /// The + button, which adds a recipe and offers importing one from a file in its menu
    private func makeAddButtonItem() -> UIBarButtonItem {
        let importAction = UIAction(title: Strings.importFile) { action in
            self.openImportFilePopover()
        }
        var addButtonItem: UIBarButtonItem!
        let addAction = UIAction(title: Strings.addRecipe, image: UIImage(systemName: "plus")) { _ in
            self.presentAddRecipePopover(addButtonItem)
        }
        addButtonItem = UIBarButtonItem(title: Strings.addRecipe, image: UIImage(systemName: "plus"), primaryAction: addAction, menu: UIMenu(children: [addAction, importAction]))
        addButtonItem.accessibilityIdentifier = AccessibilityID.addRecipeButton
        return addButtonItem
    }

    /// Edit and Settings, shown in the system overflow menu of the sidebar
    private func overflowMenuItems() -> [UIMenuElement] {
        let editAction = UIAction(title: Strings.EditButton_Edit, image: UIImage(systemName: "pencil")) { _ in
            self.setEditing(true, animated: true)
        }
        editAction.accessibilityIdentifier = AccessibilityID.editRecipeListAction
        if !self.editButtonItem.isEnabled {
            editAction.attributes = .disabled
        }

        let settingsAction = UIAction(title: Strings.settings, image: UIImage(systemName: "gear")) { _ in
            self.navigateToSettings()
        }
        settingsAction.accessibilityIdentifier = AccessibilityID.settingsButton

        return [editAction, settingsAction]
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

#if DEBUG
extension RecipeListViewController {
    @objc func _test_openImportFilePopover() {
        // Forward to the real implementation so tests can invoke via selector
        self.openImportFilePopover()
    }
}
#endif
