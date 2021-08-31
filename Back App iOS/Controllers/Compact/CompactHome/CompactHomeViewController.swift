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
        
        //attach publisher for navbar reload
        NotificationCenter.default.publisher(for: .homeNavBarShouldReload).sink { _ in
            self.configureNavigationBar()
        }.store(in: &tokens)
        
        //attach publisher for alert
        NotificationCenter.default.publisher(for: .alertShouldBePresented).sink { _ in
            self.presentImportAlert()
        }.store(in: &tokens)

        NotificationCenter.default.publisher(for: .homeShouldPopSplitVC).sink { _ in
            DispatchQueue.main.async {
                if self.splitViewController?.viewControllers.count ?? 2 > 1 {
                _ = self.splitViewController?.viewControllers.popLast()
                }
            }
        }.store(in: &tokens)
        
        #if !DEBUG
        //ask for room temp
        presentRoomTempSheet()
        #endif
    }
    
    override func loadView() {
        super.loadView()
        dataSource.update(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource.update(animated: false)
    }

}


private extension CompactHomeViewController {
    
    // MARK: - Cell Registration
    
    private func registerCells() {
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Strings.recipeCell)
    }
    
    // MARK: - NavigationBar
    
    @objc private func configureNavigationBar() {
        DispatchQueue.main.async { //force to main thread since ui is updated
            self.title = Strings.recipes
            self.navigationController?.navigationBar.prefersLargeTitles = true
            
            let settingsButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(self.navigateToSettings))
            let editButtonItem = self.editButtonItem
            editButtonItem.isEnabled = !self.appData.allRecipes.isEmpty
            self.isEditing = false 
            self.navigationItem.leftBarButtonItems = [settingsButtonItem, editButtonItem]
            
            let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.presentAddRecipePopover))
            let importButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.down.doc"), style: .plain, target: self, action: #selector(self.openImportFilePopover))
            self.navigationItem.rightBarButtonItems = [addButtonItem, importButtonItem]
        }
    }
    
    // MARK: - Room Temp Sheet
    private func presentRoomTempSheet() {
        let roomtempBinding = Binding {
            return Standarts.roomTemp
        } set: {
            Standarts.roomTemp = $0
        }
        
        let vc = UIHostingController(rootView: RoomTempPickerSheet(roomTemp: Binding { return 0.0} set: { _ in}, dissmiss: {}))
        
        let sheet = RoomTempPickerSheet(roomTemp: roomtempBinding) {
            vc.dismiss(animated: true)
        }

        vc.rootView = sheet

        // set the presentation style to automatic so it also works on regular horizontal size class aka mostly ipad
        vc.modalPresentationStyle = .automatic
        
        present(vc, animated: true)
    }
    
    // MARK: - Input Alert
    
    ///present the inputAlert
    private func presentImportAlert() {
        DispatchQueue.main.async { //force to main thread since this is ui code
            
            //create the alert
            let alert = UIAlertController(title: inputAlertTitle, message: inputAlertMessage, preferredStyle: .alert)
            
            //add the "ok" action/option/button
            alert.addAction(UIAlertAction(title: Strings.Alert_ActionOk, style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))
            
            //finally present it
            self.present(alert, animated: true)
        }
    }
    
    ///present popover for creating new recipe
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        
        let newNumber = (appData.allRecipes.last?.number ?? -1) + 1
        
        // the new fresh recipe
        var recipe = Recipe.init(number: newNumber)
        
        // insert the new recipe
        appData.save(&recipe)
        
        // create the vc
        let vc = EditRecipeViewController(recipeId: recipe.id!, creating: true, appData: appData)
        
        // navigation Controller
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .fullScreen //to prevent data loss

        present(nv, animated: true)
       }
    
    @objc private func navigateToSettings() {
        let vc = SettingsViewController(appData: appData)
        
        // navigation Controller
        let nv = UINavigationController(rootViewController: vc)
        
        self.splitViewController?.showDetailViewController(nv, sender: self)
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
        DispatchQueue.global(qos: .utility).async {
            guard !self.pressed else { return }
            self.pressed = true
            guard let recipeItem = self.dataSource.itemIdentifier(for: indexPath) else { return}
            
            self.navigateToRecipe(recipeItem: recipeItem)
            
            self.pressed = false
        }
    }

    // create an editRecipeVC to navigate to
    private func _editVC(recipeId: Int64) -> EditRecipeViewController {
        EditRecipeViewController(recipeId: recipeId, creating: false, appData: self.appData){
            //dismiss detail
            if self.splitViewController?.isCollapsed ?? false {
                //nosplitVc visible
                self.navigationController?.popViewController(animated: true)
            } else {
                //splitVc visible
                NotificationCenter.default.post(name: .homeShouldPopSplitVC, object: nil)
            }
        }
    }
    
    private func navigateToRecipe(recipeItem: RecipeItem) {
        
        // get the recipe from the database
        if let recipe = appData.record(with: Int64(recipeItem.id), of: Recipe.self) {
            
            DispatchQueue.main.async {
                
                let vc = RecipeViewController(recipeId: recipe.id!, appData: self.appData, editRecipeViewController: self._editVC(recipeId: recipe.id!))

                //push to the view controller
                let nv = UINavigationController(rootViewController: vc)
                self.splitViewController?.showDetailViewController(nv, sender: self)
            }
        }
    }
    
    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension Notification.Name {
    static var homeShouldPopSplitVC = Notification.Name.init("homeShouldPopSplitVC")
}

// MARK: - Context Menu

extension CompactHomeViewController {

    /// creates a contextMenu for the recipe Cell
    private func contextMenu(for recipe: Recipe, at indexPath: IndexPath) -> UIContextMenuConfiguration {
        let actionProvider: UIContextMenuActionProvider = { (suggestedActions) in

            // toggle favourite for the recipe
            let favourite = UIAction(title: recipe.isFavorite ? Strings.removeFavorite : Strings.addFavorite, image: UIImage(systemName: recipe.isFavorite ? "star.slash" : "star")) { action in
                var recipe = recipe
                recipe.isFavorite.toggle()
                self.appData.save(&recipe)
            }

            // pull up the share recipe sheet
            let share = UIAction(title: Strings.share, image: UIImage(systemName: "square.and.arrow.up")) { action in
                let vc = UIActivityViewController(activityItems: [self.appData.exportRecipesToFile(recipes: [recipe])], applicationActivities: nil)
                vc.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
                self.present(vc, animated: true)
            }

            // delete the recipe
            let delete = UIAction(title: Strings.Alert_ActionDelete, image: UIImage(systemName: "trash"), attributes: .destructive ) { action in
                self.dataSource.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            }

            // jump to editRecipeVC
            let edit = UIAction(title: Strings.EditButton_Edit, image: UIImage(systemName: "pencil")) { action in
                let nv = UINavigationController(rootViewController: self._editVC(recipeId: recipe.id!))
                self.splitViewController?.showDetailViewController(nv, sender: self)
            }

            // jump to scheduleForm
            let start = UIAction(title: Strings.startRecipe, image: UIImage(systemName: "arrowtriangle.right")) { action in
                let recipeBinding = Binding(get: {
                    return self.appData.record(with: recipe.id!, of: Recipe.self)!
                }) { (newValue) in
                    //here I need to modify the recipe
                    self.appData.update(newValue)
                }

                let scheduleFormVC = ScheduleFormViewController(recipe: recipeBinding, appData: self.appData)

                let nv = UINavigationController(rootViewController: scheduleFormVC)

                self.splitViewController?.showDetailViewController(nv, sender: self)
            }

            return UIMenu(title: recipe.name, children: [start, edit, favourite, share, delete])
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let item = dataSource.itemIdentifier(for: indexPath), let recipe = appData.record(with: Int64(item.id), of: Recipe.self) {
            return contextMenu(for: recipe, at: indexPath)
        } else { return nil }
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
    }
    
}
