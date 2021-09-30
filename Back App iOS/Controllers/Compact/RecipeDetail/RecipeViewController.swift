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
import Combine

typealias RecipeDetailDataSource = UITableViewDiffableDataSource<RecipeDetailSection, Item>

class RecipeViewController: UITableViewController {

    //MARK: - Properties

    /// the diffable dataSource for this screen
    private var dataSource: RecipeDetailDataSource!

    /// all of the info this screen needs for displaying the cellls
    private var recipeDetailItem: BackAppData.RecipeDetailItem? {
        didSet {
            //make sure its not nil
            guard let recipeDetailItem = recipeDetailItem else {
                return
            }

            self.updateDataSource()
            self.configureNavbarItems()
            self.recipeName = recipeDetailItem.recipe.formattedName
        }
    }

    /// the name of the recipe used to display the navbarTitle
    private var recipeName: String {
        didSet {
            self.configureNavbarTitle()
        }
    }

    /// id of the recipe used to get the recipeDetailItem or a recipe binding
    private let recipeId: Int64

    /// storing the publisher that updates the recipeDetailItem when it changes in the database
    private var recipeInfoPublisher: AnyCancellable!

    /// edit recipe vc provided by the init used for pushing to the detail screen
    private let editVC: EditRecipeViewController

    //MARK: - Init

    init(recipeId: Int64, editVC: EditRecipeViewController, recipeName: String) {

        //properties
        self.recipeId = recipeId
        self.editVC = editVC
        self.recipeName = recipeName
        super.init(style: .insetGrouped)

        registerCells()
        self.configureDataSource()
        observeRecipeInfo()

        self.tableView.separatorStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        super.loadView()

        configureNavbarTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.splitViewController?.delegate = self
    }

    //MARK: - Helpers

    private func registerCells() {
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.timesCell)
        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.stepCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Strings.imageCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(InfoStripCell.self, forCellReuseIdentifier: Strings.infoStripCell)
    }


    //MARK: DataSource

    private func configureDataSource() {
        self.dataSource = RecipeDetailDataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            if let imageItem = item as? ImageItem {

                //image
                return ImageCell(reuseIdentifier: Strings.imageCell, data: imageItem.imageData)
            } else if let detailItem = item as? DetailItem {

                //detail items
                return DetailCell(text: detailItem.text, reuseIdentifier: Strings.detailCell)
            } else if let stripItem = item as? InfoStripItem {

                //infoStrip
                return InfoStripCell(infoStripItem: stripItem, reuseIdentifier: Strings.infoStripCell)
            } else if let stepItem = item as? StepItem {

                //steps
                return StepCell(step: stepItem.step, reuseIdentifier: Strings.stepCell, editMode: false)
            } else if let textItem = item as? TextItem {
                return CustomCell(text: textItem.text, reuseIdentifier: Strings.timesCell)
            } else {
                return UITableViewCell()
            }
        })
        dataSource.defaultRowAnimation = .fade
        self.tableView.dataSource = dataSource
    }

    private func updateDataSource() {
        guard let recipeDetailItem = recipeDetailItem else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<RecipeDetailSection, Item>()

        //attach the sections
        snapshot.appendSections([.imageControlStrip, .steps, .info])

        //image control strip
        let imageItem = ImageItem(imageData: recipeDetailItem.recipe.imageData)
        let startRecipeItem = DetailItem(name: Strings.startRecipe)
        let infoStripItem = recipeDetailItem.infoStripItem
        let timesItem = TextItem(text: recipeDetailItem.timesText)
        snapshot.appendItems([imageItem, startRecipeItem, infoStripItem, timesItem], toSection: .imageControlStrip)

        //steps
        snapshot.appendItems(recipeDetailItem.stepItems, toSection: .steps)

        //info
        if !recipeDetailItem.recipe.info.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            snapshot.appendItems([recipeDetailItem.recipe.infoItem], toSection: .info)
        }

        //apply the snapshot
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    //MARK: Observer
    private func observeRecipeInfo() {
        recipeInfoPublisher = BackAppData.shared.recipeInfoPublisher(for: recipeId)
            .sink(receiveCompletion: { _ in }) { recipeDetailItem in
                self.recipeDetailItem = recipeDetailItem
            }
    }

    // MARK: Navbar
    ///sets the title
    private func configureNavbarTitle() {
        self.title = recipeName
    }

    public func configureNavbarItems() {
        guard let recipeDetailItem = recipeDetailItem else {
            return
        }

        //create the items
        /// share item to share the recipe as a file
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))

        /// favourite item to add  the recipe to the favorites
        let favourite = UIBarButtonItem(image: UIImage(systemName: recipeDetailItem.recipe.isFavorite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))

        /// edit item to navigate to editRecipeVC
        let edit =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRecipe))

        //setup toolbar / navbar
        setUp3ItemToolbar(item1: share, item2: favourite, item3: edit)
    }

    //MARK: Navbar Helpers

    @objc private func shareRecipeFile(sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [BackAppData.shared.exportRecipesToFile(recipes: [self.recipeDetailItem!.recipe])], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }

    @objc private func favouriteRecipe() {
        var recipe = self.recipeDetailItem!.recipe
        BackAppData.shared.toggleFavorite(for: &recipe)
    }

    @objc private func editRecipe() {
        navigationController?.pushViewController(editVC, animated: true)
    }


    public func startRecipe() {
        let recipeBinding = Binding(get: {
            return BackAppData.shared.record(with: self.recipeId, of: Recipe.self)!
        }) { (newValue) in
            //here I need to modify the recipe
            try! BackAppData.shared.dbWriter.write { db in
                try newValue.update(db)
            }
        }
        let scheduleForm = ScheduleFormViewController(recipe: recipeBinding, appData: BackAppData.shared)

        navigationController?.pushViewController(scheduleForm, animated: true)
    }

    // MARK: - Row Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        if let detailItem = item as? DetailItem {
            if detailItem.text == Strings.startRecipe {
                startRecipe()
            }
        }
    }

    //MARK: - CellHeight

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

// MARK: Conformance to UISplitViewControllerDelegate
extension RecipeViewController: UISplitViewControllerDelegate {
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        // reload the navbar to switch between showing the toolbar and not showing the toolbar
        self.configureNavbarItems()
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        // reload the navbar to switch between showing the toolbar and not showing the toolbar
        self.configureNavbarItems()
    }
}
