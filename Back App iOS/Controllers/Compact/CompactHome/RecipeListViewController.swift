//
//  RecipeListViewController.swift
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

class RecipeListViewController: UITableViewController {

    typealias DataSource = RecipeListDataSource
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

    private(set) lazy var searchController = makeSearchController()

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

        BackAppData.shared.recipeListPublisher
            .sink(receiveCompletion: { _ in}) { recipeListItems in
                self.editButtonItem.isEnabled = !recipeListItems.isEmpty
                self.configureNavigationBar()
            }
            .store(in: &tokens)

#if !DEBUG
        //ask for room temp
        presentRoomTempSheet()
#endif
    }

    override func loadView() {
        super.loadView()
        _ = dataSource
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.global(qos: .background).async {
#if DEBUG
            self.postRecipeListVCAvailable()
#endif
        }
    }

#if DEBUG
    private var triggerCounter = 0

    func postRecipeListVCAvailable() {
        DispatchQueue.main.async {
            if !triggering {
                self.triggerCounter += 1
                if self.triggerCounter == 1 {
                    NotificationCenter.default.post(name: .recipeListVCAvailable, object: nil)
                    triggering = true
                }
            }
        }
    }
#endif
}

#if DEBUG
var triggering = false

public extension NSNotification.Name {
    static var recipeListVCAvailable = NSNotification.Name.init(rawValue: "recipeListVCAvailable")
    static var recipeListNavbarDidLoad = NSNotification.Name.init(rawValue: "recipeListNavbarDidLoad")
}
#endif

extension RecipeListViewController {

    // MARK: - Cell Registration

    private func registerCells() {
        tableView.register(RecipeCell.self, forCellReuseIdentifier: Strings.recipeCell)
    }

    // MARK: - NavigationBar

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
        //create the vc
        let editRecipeVC = EditRecipeViewController(recipeId: try! appData.addBlankRecipe().id!, creating: true, appData: appData)

        //embed it in a navigation controller
        let nc = UINavigationController(rootViewController: editRecipeVC)
        nc.modalPresentationStyle = .fullScreen

        present(nc, animated: true)
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

private extension RecipeListViewController {

    // MARK: - DataSource

    private func makeDataSource() -> DataSource {
        RecipeListDataSource(tableView: tableView)
    }
}

extension RecipeListViewController {

    // MARK: - Cell Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .utility).async {
            guard !self.pressed else { return }
            self.pressed = true
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return}

            self.navigateToRecipe(item: item)

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

    private func navigateToRecipe(item: BackAppData.RecipeListItem) {
        DispatchQueue.main.async {
            let recipeId = item.recipe.id!
            let recipeVC = RecipeViewController(recipeId: recipeId, editVC: self._editVC(recipeId: recipeId), recipeName: item.recipe.formattedName)
            //push to the view controller
            let nc = UINavigationController(rootViewController: recipeVC)
            self.splitViewController?.showDetailViewController(nc, sender: self)
        }
    }

    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

// MARK: - SwipeActions

extension RecipeListViewController {
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Get current state from data source
        guard var recipe = dataSource.itemIdentifier(for: indexPath)?.recipe else { return nil }

        let title = recipe.isFavorite ? Strings.removeFavorite : Strings.addFavorite

        let toggleFavAction = UIContextualAction(style: .normal, title: title,
                                                 handler: { (action, view, completionHandler) in
            // Update data source when user taps action
            BackAppData.shared.toggleFavorite(for: &recipe)
            completionHandler(true)
        })

        toggleFavAction.image = UIImage(systemName: recipe.isFavorite ? "star.slash" : "star")
        toggleFavAction.backgroundColor = recipe.isFavorite ? .red : .systemYellow
        return UISwipeActionsConfiguration(actions: [toggleFavAction])
    }

}

// MARK: - Context Menu

extension RecipeListViewController {

    internal func contextMenu(indexPath: IndexPath) -> UIMenu? {
        guard let recipe = self.dataSource.itemIdentifier(for: indexPath)?.recipe else {
            return nil
        }

        // toggle favourite for the recipe
        let favourite = UIAction(title: recipe.isFavorite ? Strings.removeFavorite : Strings.addFavorite, image: UIImage(systemName: recipe.isFavorite ? "star.slash" : "star")) { action in
            var recipe = recipe
            self.appData.toggleFavorite(for: &recipe)
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
        }

        // pull up the share recipe sheet
        let share = UIAction(title: Strings.share, image: UIImage(systemName: "square.and.arrow.up")) { action in
            let vc = UIActivityViewController(activityItems: [self.appData.exportRecipesToFile(recipes: [recipe])], applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
            self.present(vc, animated: true)
        }

        // delete the recipe
        let delete = UIAction(title: Strings.Alert_ActionDelete, image: UIImage(systemName: "trash"), attributes: .destructive ) { action in
            self.appData.delete(recipe)
        }

        // jump to editRecipeVC
        let edit = UIAction(title: Strings.EditButton_Edit, image: UIImage(systemName: "pencil")) { action in
            let nv = UINavigationController(rootViewController: self._editVC(recipeId: recipe.id!))
            self.splitViewController?.showDetailViewController(nv, sender: self)
        }

        // jump to scheduleForm
        let start = UIAction(title: Strings.startRecipe, image: UIImage(systemName: "play")) { action in

            let scheduleFormVC = ScheduleFormViewController(recipe: try! self.appData.recordBinding(for: recipe), appData: self.appData)

            let nv = UINavigationController(rootViewController: scheduleFormVC)

            self.splitViewController?.showDetailViewController(nv, sender: self)
        }

        let dupeAction = UIAction(title: Strings.duplicate, image: UIImage(systemName: "square.on.square")) { action in
            recipe.duplicate(writer: self.appData.dbWriter)
        }

        return UIMenu(title: recipe.name, children: [start, edit, share, dupeAction, favourite, delete])
    }

    /// creates a contextMenu for the recipe Cell
    private func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration? {

        let actionProvider: UIContextMenuActionProvider = { (suggestedActions) in
            self.contextMenu(indexPath: indexPath)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenuConfig(at: indexPath)
    }
}

// MARK: - Document Picker

extension RecipeListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard urls.count == 1, let url = urls.first else { return }
        appData.open(url)
    }

}

// MARK: - Search
extension RecipeListViewController {

    func makeSearchController() -> UISearchController {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self.dataSource

        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }

}
