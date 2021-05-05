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
import BakingRecipeCells
import BakingRecipeFoundation
import BakingRecipeUIFoundation
import Combine

class CompactHomeViewController: UITableViewController {
    
    typealias DataSource = HomeDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection,TextItem>
    
    // MARK: Properties

    ///data source for the recipe
    private(set) lazy var dataSource = makeDataSource()
    
    /// appData storage interface
    private var appData: BackAppData
    
    /// wether a cell has been pressed
    private lazy var pressed = false
    
    /// for managing the theme
    private var themeManager: ThemeManager
    
    /// for picking documents
    private lazy var documentPicker = UIDocumentPickerViewController(
        documentTypes: [kUTTypeJSON as String], in: .open
    )
    
    /// set for storing publishers
    private var tokens = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    init(appData: BackAppData) {
        self.appData = appData
        self.themeManager = .default
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    deinit {
        //cancel listening to all publishers
        for token in tokens{
            token.cancel()
        }
    }
    
    // MARK: - Startup functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        configureNavigationBar()
        dataSource.update(animated: true)
        
        //attack publisher for navbar reload
        NotificationCenter.default.publisher(for: .homeNavBarShouldReload).sink { _ in
            self.configureNavigationBar()
        }.store(in: &tokens)
    }

}


private extension CompactHomeViewController {
    
    // MARK: - Cell Registration
    
    private func registerCells() {
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Strings.recipeCell)
    }
    
    // MARK: - NavigationBar
    
    @objc private func configureNavigationBar() {
        title = Strings.recipes
        navigationController?.navigationBar.prefersLargeTitles = true
       
        let settingsButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(navigateToSettings))
        let editButtonItem = self.editButtonItem
        editButtonItem.isEnabled = !self.appData.allRecipes.isEmpty
        navigationItem.leftBarButtonItems = [settingsButtonItem, editButtonItem]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddRecipePopover))
        let importButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.doc"), style: .plain, target: self, action: #selector(openImportFilePopover))
        navigationItem.rightBarButtonItems = [addButtonItem, importButtonItem]
    }
    
    ///present popover for creating new recipe
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        
        let uniqueId = self.appData.newId(for: Recipe.self)
        
        let newNumber = (appData.allRecipes.last?.number ?? -1) + 1
        
        // the new fresh recipe
        let recipe = Recipe.init(id: uniqueId, number: newNumber)
        
        // insert the new recipe
        guard appData.insert(recipe) else { return }
        
        // create the vc
        let vc = RecipeDetailViewController(recipeId: uniqueId, creating: true, appData: appData)
        
        // navigation Controller
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .fullScreen //to prevent data loss
        
        present(nv, animated: true)
       }
    
    @objc private func navigateToSettings() {
        let vc = SettingsViewController()
        
        // navigation Controller
        let nv = UINavigationController(rootViewController: vc)
        
        present(nv, animated: true)
    }
    
    @objc private func openImportFilePopover() {
        //set the delegate
        self.documentPicker.delegate = self
        
        // Present the document picker.
        self.present(documentPicker, animated: true, completion: deselectRow)
    }
    
}

private extension CompactHomeViewController {
    
    // MARK: - DataSource
    
    private func makeDataSource() -> DataSource {
        HomeDataSource(appData: appData, tableView: tableView)
    }
}

extension CompactHomeViewController {
    
    // MARK: - Cell Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !pressed else { return }
        pressed = true
        guard let recipeItem = dataSource.itemIdentifier(for: indexPath) else { return}
        
        navigateToRecipe(recipeItem: recipeItem)
        
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
    
    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

// MARK: - Document Picker

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
