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
    }
    
    func setUpNavigationBar() {
        DispatchQueue.main.async {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editRecipe))
            self.title = self.recipe.formattedName
        }
    }
}


private extension RecipeViewController {
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
                return TextViewCell(textContent: Binding(get: {
                    infoItem.text
                }, set: { _ in }), placeholder: "", reuseIdentifier: Strings.infoCell, editMode: false)
            }
            return CustomCell()
        }
    }
    
    func updateDataSource(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.imageControlStrip, .steps, .info])
        
        let imageItem = ImageItem(imageData: recipe.imageData)
        let startRecipeItem = DetailItem(name: Strings.startRecipe)
        snapshot.appendItems([imageItem, startRecipeItem, recipe.infoStripItem(appData: appData)], toSection: .imageControlStrip)
        
        snapshot.appendItems(recipe.stepItems(appData: appData), toSection: .steps)
        
        snapshot.appendItems([recipe.infoItem], toSection: .info)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension RecipeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if let detailItem = item as? DetailItem {
            if detailItem.text == Strings.startRecipe {
                //TODO: Start recipe
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
