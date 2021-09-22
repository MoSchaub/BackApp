//
//  RecipeViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 04.07.21.
//  Copyright © 2021 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BackAppCore
import BakingRecipeStrings

fileprivate typealias Section = RecipeDetailSection
fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, Item>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

class RecipeViewController: UITableViewController {
    
    // id of the recipe for pulling the recipe from the database
    private let recipeId: Int64
    
    // the recipe that is shown will be pulled from the database when the view appears or loads
    private var recipe: Recipe!
    
    //interface object for the database
    private var appData: BackAppData
    
    // class for managing table creation and updates
    private lazy var dataSource = makeDataSource()
    
    
    private var editVC: EditRecipeViewController
    
    public init(recipeId: Int64, appData: BackAppData, editRecipeViewController: EditRecipeViewController ) {
        self.recipeId = recipeId
        self.appData = appData
        self.editVC = editRecipeViewController
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecipeViewController {
    override func loadView() {
        super.loadView()
        self.recipe =  appData.record(with: recipeId, of: Recipe.self)!
        self.title = self.recipe.formattedName
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        self.tableView.separatorStyle = .none

        //declare conformance for landscape mode on large iphones and ipads
        self.splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recipe =  appData.record(with: recipeId, of: Recipe.self)!
        updateDataSource(animated: false)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        DispatchQueue.global(qos: .background).async {
            self.setUpNavigationBar()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = dataSource.itemIdentifier(for: indexPath), item is ImageItem {
            return 250
        } else if dataSource.itemIdentifier(for: indexPath) is InfoItem {
            return 100
        } else {
            return UITableView.automaticDimension
        }
    }
}

private extension RecipeViewController {
    func registerCells() {
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Strings.imageCell)
        tableView.register(InfoStripCell.self, forCellReuseIdentifier: Strings.infoStripCell)
        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.stepCell)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.infoCell)
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.textCell)
    }
    
    func setUpNavigationBar() {
        /// share item to share the recipe as a file
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))

        /// favourite item to add  the recipe to the favorites
        let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavorite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))

        /// edit item to navigate to editRecipeVC
        let edit =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRecipe))

        setUp3ItemToolbar(item1: share, item2: favourite, item3: edit)

        DispatchQueue.main.async {
            //title in any case
            self.title = self.recipe.formattedName
        }
    }
}

// MARK: Conformance to UISplitViewControllerDelegate
extension RecipeViewController: UISplitViewControllerDelegate {
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        // reload the navbar to switch between showing the toolbar and not showing the toolbar
        self.setUpNavigationBar()
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        // reload the navbar to switch between showing the toolbar and not showing the toolbar
        self.setUpNavigationBar()
    }
}

// MARK: helpers for navbarItems

private extension RecipeViewController {

    @objc private func favouriteRecipe(_ sender: UIBarButtonItem) {
        appData.toggleFavorite(for: &recipe)
    }

    @objc private func shareRecipeFile(sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [appData.exportRecipesToFile(recipes: [self.recipe])], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }
}

//MARK: - Datasource and Snapshot

private extension RecipeViewController {
    
    ///create the dataSource and create cells from the items
    func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            if let imageItem = item as? ImageItem {
                let imageCell = ImageCell(reuseIdentifier: Strings.imageCell, data: imageItem.imageData)
                return imageCell
            } else if let detailItem = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailCell {
                cell.textLabel?.text = detailItem.text
                cell.setup()
                return cell
            } else if let stripItem = item as? InfoStripItem, let infoStripCell = tableView.dequeueReusableCell(withIdentifier: Strings.infoStripCell, for: indexPath) as? InfoStripCell {
                infoStripCell.setUpCell(for: stripItem)
                return infoStripCell
            } else if let stepItem = item as? StepItem {
                let stepCell = StepCell(step: stepItem.step, appData: self.appData, reuseIdentifier: Strings.stepCell, editMode: false)
                return stepCell
            } else if let infoItem = item as? InfoItem {
                return TextViewCell(textContent: .constant(infoItem.text), placeholder: "", reuseIdentifier: Strings.infoCell, isEditable: false)
            } else if let textItem = item as? TextItem, let textCell = tableView.dequeueReusableCell(withIdentifier: Strings.textCell, for: indexPath) as? CustomCell {
                textCell.textLabel?.text = textItem.text
                return textCell
            }
            return CustomCell()
        }
    }
    /// create items, build a snapshot with them and apply the snapshot
    ///- Parameter animated: wether the differences should be animated
    func updateDataSource(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.imageControlStrip, .steps, .info])
        
        let imageItem = ImageItem(imageData: recipe.imageData)
        let startRecipeItem = DetailItem(name: Strings.startRecipe)
        let infoStripItem = recipe.infoStripItem(appData: appData)
        let timesItem = TextItem(text: recipe.timesTextWithIndivialMass(with: appData.totalAmount(for: recipeId))) // eg. 11 pieces à 12 g each
        snapshot.appendItems([imageItem, startRecipeItem, infoStripItem, timesItem], toSection: .imageControlStrip)
        
        snapshot.appendItems(recipe.stepItems(appData: appData), toSection: .steps)
        
        if recipe.info != "" {
            snapshot.appendItems([recipe.infoItem], toSection: .info)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension RecipeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if let detailItem = item as? DetailItem {
            if detailItem.text == Strings.startRecipe {
                startRecipe()
            }
        }
    }
}

private extension RecipeViewController {
    private func startRecipe() {
        let recipeBinding = Binding(get: {
            return self.appData.record(with: self.recipeId, of: Recipe.self)!
        }) { (newValue) in
            //here I need to modify the recipe
            self.appData.update(newValue)
        }
        let scheduleForm = ScheduleFormViewController(recipe: recipeBinding, appData: appData)
        
        navigationController?.pushViewController(scheduleForm, animated: true)
    }
    
    @objc private func editRecipe() {
        navigationController?.pushViewController(editVC, animated: true)
    }
}
