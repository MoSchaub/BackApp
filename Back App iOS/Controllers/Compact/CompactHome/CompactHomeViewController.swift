//
//  CompactHomeViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import BakingRecipeCore
import BakingRecipeStrings

class CompactHomeViewController: UITableViewController {
    
    typealias DataSource = HomeDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection,TextItem>

    private(set) lazy var dataSource = makeDataSource()
    private var recipeStore: RecipeStore
    private lazy var documentPicker = UIDocumentPickerViewController(
        documentTypes: [kUTTypeJSON as String], in: .open
    )
    
    init(recipeStore: RecipeStore) {
        self.recipeStore = recipeStore
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    override func viewDidLoad() {
        registerCells()
        configureNavigationBar()
        self.tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.update(animated: false)
    }

}


import BakingRecipeFoundation

private extension CompactHomeViewController {
    private func registerCells() {
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: Strings.recipeCell)
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.plainCell)
    }
    
    private func configureNavigationBar() {
        title = Strings.appTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(presentAddRecipePopover))
    }
    
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        let recipe = Recipe(name: "", brotValues: [])
        let vc = RecipeDetailViewController(recipe: recipe, creating: true, saveRecipe: { recipe in
            self.recipeStore.save(recipe: recipe)
            DispatchQueue.main.async {
                self.dataSource.update(animated: false)
            }
        }, deleteRecipe: { _ in return false })
        let nv = UINavigationController(rootViewController: vc)
        present(nv, animated: true)
       }
}

private extension CompactHomeViewController {
    private func makeDataSource() -> DataSource {
        HomeDataSource(recipeStore: recipeStore, tableView: tableView)
    }
}

extension CompactHomeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return}
        
        if let recipeItem = item as? RecipeItem {
            navigateToRecipe(recipeItem: recipeItem)
        } else if item.text == Strings.roomTemperature {
            navigateToRoomTempPicker(item: item)
        } else if item.text == Strings.importFile {
            openImportFilePopover()
        } else if item.text == Strings.exportAll {
            openExportAllShareSheet(sender: tableView.cellForRow(at: indexPath)!)
        } else if item.text == Strings.about {
            navigateToAboutView()
        }
    }
    
    private func navigateToRecipe(recipeItem: RecipeItem) {
        if let recipe = recipeStore.allRecipes.first(where: { $0.id == recipeItem.id}) {
            let vc = RecipeDetailViewController(recipe: recipe, creating: false, saveRecipe: { recipe in
                self.recipeStore.update(recipe: recipe)
                DispatchQueue.main.async {
                    self.dataSource.update(animated: false)
                }
            }) { recipe in
                let result: Bool
                if self.splitViewController?.isCollapsed ?? false {
                    result = self.dataSource.deleteRecipe(recipe.id)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let _ = self.splitViewController?.viewControllers.popLast()
                    result = self.dataSource.deleteRecipe(recipe.id)
                    self.dataSource.update()
                }
                return result
            }
            splitViewController?.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        }
    }
    
    private func navigateToRoomTempPicker(item: TextItem) {
        let vc = RoomTempTableViewController(style: .insetGrouped)
        
        vc.recipeStore = recipeStore
        vc.updateTemp = { [self] temp in
            Settings.standardRoomTemperature = temp
            self.updateSettings()
        }
        splitViewController?.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
    }
    
    private func updateSettings() {
        DispatchQueue.global(qos: .background).async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteSections([.settings])
            snapshot.appendSections([.settings])
            snapshot.appendItems(self.recipeStore.settingsItems, toSection: .settings)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
    
    private func openImportFilePopover() {
        self.documentPicker.delegate = self
        // Present the document picker.
        self.present(documentPicker, animated: true, completion: deselectRow)
    }
    
    private func openExportAllShareSheet(sender: UIView) {
        let ac = UIActivityViewController(activityItems: [recipeStore.exportToURL()], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = sender
        present(ac,animated: true, completion: deselectRow)
    }
    
    private func navigateToAboutView() {
        let hostingController = UIHostingController(rootView: AboutView())
        splitViewController?.showDetailViewController(UINavigationController(rootViewController: hostingController), sender: self)
    }
    
    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension CompactHomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        //load recipes
        for url in urls {
            recipeStore.open(url)
        }
        
        //update cells
        self.dataSource.update(animated: true)
        
        //alert
        let alert = UIAlertController(title: recipeStore.inputAlertTitle, message: recipeStore.inputAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Alert_ActionOk, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }
}
