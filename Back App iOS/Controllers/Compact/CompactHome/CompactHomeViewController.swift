//
//  CompactHomeViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import MobileCoreServices

class HomeDataSource: UITableViewDiffableDataSource<HomeSection,TextItem> {
    // storage object for recipes
    var recipeStore: RecipeStore

    init(recipeStore: RecipeStore, tableView: UITableView) {
        self.recipeStore = recipeStore
        
        super.init(tableView: tableView) { (_, indexPath, homeItem) -> UITableViewCell? in
            // Configuring cells
            if let recipeItem = homeItem as? RecipeItem, let recipeCell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath) as? RecipeTableViewCell { //recipeCell
                recipeCell.setUp(cellData: .init(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData))
                recipeCell.accessoryType = .disclosureIndicator
                
                return recipeCell
            } else if let detailItem = homeItem as? DetailItem { // Detail Cell (RoomTemp und About)
                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath)
                cell.textLabel?.text = detailItem.text
                cell.detailTextLabel?.text = detailItem.detailLabel
                cell.accessoryType = .disclosureIndicator

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath) //plain cells
                cell.textLabel?.text = homeItem.text
                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.up"))
                cell.accessoryView?.tintColor = .tertiaryLabel
                
                return cell
            }
        }
        //update(animated: false)
    }
    
    /// updates and rerenders the tableview
    func update(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, TextItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(recipeStore.recipeItems, toSection: .recipes)
        snapshot.appendItems(recipeStore.settingsItems, toSection: .settings)
        self.apply(snapshot, animatingDifferences: animated)
    }
    
    func reloadRecipes() {
        var snapshot = self.snapshot()
        snapshot.reloadSections([.recipes])
        self.apply(snapshot)
    }
    
    /// resetting tableview used for reordering
    private func reset() {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        self.update(animated: false)
    }
    
    
    /// deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 0, let item = itemIdentifier(for: indexPath) {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                self.deleteRecipe(item.id)
            }
        }
    }
    
    private func deleteRecipe(_ id: UUID) {
        if let index = recipeStore.recipes.firstIndex(where: { $0.id == id }) {
            self.recipeStore.deleteRecipe(at: index)
        }
    }
    
    // moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row > recipeStore.recipes.count else { reset(); return }
        guard destinationIndexPath.section == 0 else { reset(); return}
        guard recipeStore.recipes.count > sourceIndexPath.row else { reset(); return }
        recipeStore.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
        reloadRecipes()
    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if itemIdentifier(for: indexPath) as? RecipeItem != nil {
            return true
        } else {return false}
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }

}

class DetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CompactHomeViewController: UITableViewController {
    
    typealias DataSource = HomeDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeSection,TextItem>
    
    private lazy var dataSource = makeDataSource()
    private var recipeStore: RecipeStore
    private lazy var documentPicker = UIDocumentPickerViewController(
        documentTypes: [kUTTypeJSON as String], in: .open
    )
    
    init(recipeStore: RecipeStore) {
        self.recipeStore = recipeStore
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        registerCells()
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.update(animated: false)
    }

}

import BakingRecipe

private extension CompactHomeViewController {
    private func registerCells() {
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: "recipe")
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "detail")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
    }
    
    private func configureNavigationBar() {
        title = NSLocalizedString("appTitle", comment: "apptitle")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(presentAddRecipePopover))
    }
    
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        let recipe = Recipe(name: "", brotValues: [])
        let vc = RecipeDetailViewController(recipe: recipe, creating: true) { recipe in
            self.recipeStore.save(recipe: recipe)
            DispatchQueue.main.async {
                self.dataSource.reloadRecipes()
            }
        }
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
        } else if item.text == NSLocalizedString("raumtemperatur", comment: "") {
            navigateToRoomTempPicker(item: item)
        } else if item.text == NSLocalizedString("importFile", comment: "") {
            openImportFilePopover()
        } else if item.text == NSLocalizedString("exportAll", comment: "") {
            openExportAllShareSheet()
        } else if item.text == NSLocalizedString("about", comment: "") {
            navigateToAboutView()
        }
    }
    
    private func navigateToRecipe(recipeItem: RecipeItem) {
        if let recipe = recipeStore.recipes.first(where: { $0.id == recipeItem.id}) {
            let vc = RecipeDetailViewController(recipe: recipe, creating: false) { recipe in
                self.recipeStore.update(recipe: recipe)
                DispatchQueue.main.async {
                     self.dataSource.update(animated: false)
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func navigateToRoomTempPicker(item: TextItem) {
        let vc = RoomTempTableViewController(style: .insetGrouped)
        
        vc.recipeStore = recipeStore
        vc.updateTemp = { [self] temp in
            self.recipeStore.roomTemperature = temp
            self.updateSettings()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateSettings() {
        DispatchQueue.global(qos: .background).async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteSections([.settings])
            snapshot.appendSections([.settings])
            snapshot.appendItems(self.recipeStore.settingsItems, toSection: .settings)
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot)
            }
        }
    }
    
    private func openImportFilePopover() {
        self.documentPicker.delegate = self
        // Present the document picker.
        self.present(documentPicker, animated: true, completion: deselectRow)
    }
    
    private func openExportAllShareSheet() {
        present(UIActivityViewController(activityItems: [recipeStore.exportToUrl()], applicationActivities: nil),animated: true, completion: deselectRow)
    }
    
    private func navigateToAboutView() {
        navigationController?.pushViewController(UIHostingController(rootView: AboutView()), animated: true)
    }
    
    private func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension CompactHomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            recipeStore.open(url)
        }
        
        let alert = UIAlertController(title: recipeStore.inputAlertTitle, message: recipeStore.inputAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true)
            if alert.title == "Erfolg" {
                self.dataSource.update(animated: true)
            }
        }))
        
        present(alert, animated: true)
    }
}
