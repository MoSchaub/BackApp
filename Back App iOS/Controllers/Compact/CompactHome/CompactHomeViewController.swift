//
//  CompactHomeViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import BackAppCore
import BakingRecipeStrings
import BakingRecipeSections
import BakingRecipeItems
import BakingRecipeCells
import BakingRecipeFoundation
import BakingRecipeUIFoundation

class CompactHomeViewController: UITableViewController {
    
    typealias DataSource = HomeDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection,TextItem>

    private(set) lazy var dataSource = makeDataSource()
    
    private var appData: BackAppData
    
    private lazy var pressed = false
    
    private var themeManager: ThemeManager
    
    private lazy var documentPicker = UIDocumentPickerViewController(
        documentTypes: [kUTTypeJSON as String], in: .open
    )
    
    init(appData: BackAppData) {
        self.appData = appData
        self.themeManager = .default
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    override func viewDidLoad() {
        registerCells()
        configureNavigationBar()
        self.tableView.separatorStyle = .none
        
        //theme the splitvc
        splitViewController?.theme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.update(animated: false)
    }

}


import BakingRecipeFoundation

private extension CompactHomeViewController {
    private func registerCells() {
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Strings.recipeCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.plainCell)
    }
    
    private func configureNavigationBar() {
        title = Strings.appTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(presentAddRecipePopover))
    }
    
    ///present popover for creating new recipe
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        
        let uniqueId = self.appData.newId(for: Recipe.self)
        
        // the new fresh recipe
        let recipe = Recipe.init(id: uniqueId)
        
        // insert the new recipe
        guard appData.insert(recipe) else { return }
        
        // create the vc
        let vc = RecipeDetailViewController(recipeId: uniqueId, creating: true, appData: appData)
        
        // navigation Controller
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .fullScreen //to prevent data loss
        
        present(nv, animated: true)
       }
}

private extension CompactHomeViewController {
    private func makeDataSource() -> DataSource {
        HomeDataSource(appData: appData, tableView: tableView)
    }
}

extension CompactHomeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !pressed else { return }
        pressed = true
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
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.35) {
            self.pressed = false
        }
    }
    
    private func navigateToRecipe(recipeItem: RecipeItem) {
        
        // get the recipe from the database
        if let recipe = appData.object(with: recipeItem.id, of: Recipe.self) {
            
            //create the vc
            let vc = RecipeDetailViewController(recipeId: recipe.id, creating: false, appData: appData) {
                //dismiss detail
                if self.splitViewController?.isCollapsed ?? false {
                    //nosplitVc visible
                    self.navigationController?.popViewController(animated: true)
                } else {
                    //splitVc visible
                    _ = self.splitViewController?.viewControllers.popLast()
                }
            }
            
            //push to the view controller
            splitViewController?.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        }
    }
    
    private func navigateToRoomTempPicker(item: TextItem) {
        let vc = RoomTempTableViewController(style: .insetGrouped)
        
        vc.appData = appData
        vc.updateTemp = { [self] temp in
            Standarts.standardRoomTemperature = temp
            self.updateStandarts()
        }
        splitViewController?.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
    }
    
    private func updateStandarts() {
        DispatchQueue.global(qos: .background).async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteSections([.settings])
            snapshot.appendSections([.settings])
            snapshot.appendItems(self.appData.settingsItems, toSection: .settings)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
    
    private func openImportFilePopover() {
        //set the delegate
        self.documentPicker.delegate = self
        
        //theme the picker
        self.documentPicker.theme()
        
        // Present the document picker.
        self.present(documentPicker, animated: true, completion: deselectRow)
    }
    
    private func openExportAllShareSheet(sender: UIView) {
        let ac = UIActivityViewController(activityItems: [appData.exportAllRecipesToFile()], applicationActivities: nil)
        
        //theme the shareSheet
        ac.theme()
        
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
            appData.open(url)
        }
        
        //update cells
        self.dataSource.update(animated: true)
        
        //alert
        let alert = UIAlertController(title: appData.inputAlertTitle, message: appData.inputAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Alert_ActionOk, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }
}
