//
//  IngredientDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeFoundation
import BakingRecipeCells
import BakingRecipeStrings
import BakingRecipeItems

class IngredientDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// the details are of this ingredient
    private var ingredient: Ingredient {
        didSet {
            if oldValue != ingredient {
                self.setupNavigationBar()
                if !self.creating {
                    self.saveIngredient(self.ingredient)
                }
            }
            
        }
    }
    
    /// wether the user is creating a new ingredient or editing an existing one
    /// - Note: true means is creating a new one
    private var creating: Bool
    
    /// method to update the recipe when it changes
    private var saveIngredient: ((Ingredient) -> Void)
    
    
    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    
    // MARK: - Initializers
    
    init(ingredient: Ingredient, creating: Bool, saveIngredient: @escaping (Ingredient) -> () ) {
        self.ingredient = ingredient
        self.creating = creating
        self.saveIngredient = saveIngredient
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Startup methods
extension IngredientDetailViewController {
    
    override func loadView() {
        super.loadView()
        registerCells()
        setupNavigationBar()
        updateList()
    }
    
}

// MARK: - NavigationBar
private extension IngredientDetailViewController {
    
    /// sets up navigation bar title and items
    private func setupNavigationBar() {
        //title
        self.title = ingredient.formattedName
        
        //large Title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //items
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addIngredient))
        }
    }
    
    /// adds the ingredient and pops the top view controller on the navigation stack
    @objc private func addIngredient(_ sender: UIBarButtonItem) {
        saveIngredient(ingredient)
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Cell Registraiton
private extension IngredientDetailViewController {
    
    /// registers the different Cell Types for later reuse
    private func registerCells() {
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)  //name textField
        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell) //amount Cell
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.IngredientTypeCell) // typeCell wich type
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.plainCell) // for options for type
    }
    
}

enum IngredientDetailSection: CaseIterable {
    case name, amount, type
}

// MARK: - DataSource and Snapshot
private extension IngredientDetailViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<IngredientDetailSection, TextItem>
    
    ///create the diffableDataSource
    func makeDiffableDataSource() -> DataSource {
    
        /// format func for amountCell
        func format(amountText: String) -> String {
            guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "" }
            ingredient.amount = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            return ingredient.formatted(rest: amountText)
        }
        return DataSource(tableView: tableView) { (tableView, indexPath, textItem) -> UITableViewCell? in
            if let textFieldItem = textItem as? TextFieldItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell, for: indexPath) as? TextFieldCell {
                cell.textField.text = textFieldItem.text
                cell.textField.placeholder = Strings.name
                cell.textChanged = { text in
                    self.ingredient.name = text
                }
                return cell
            } else if textItem is AmountItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.amountCell, for: indexPath) as? AmountCell {
                cell.setUp(with: self.ingredient, format: format)
                return cell
            } else if let detailItem = textItem as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.IngredientTypeCell, for: indexPath) as? DetailCell {
                cell.textLabel?.text = detailItem.text
                cell.detailTextLabel?.text = detailItem.detailLabel
                return cell
            } else {
                return CustomCell()
            }
        }
    }
    
    /// updates the whole list
    private func updateList(animated: Bool = true) {
        
        /// textfieldItem
        let nameItem = TextFieldItem(text: ingredient.name)
        
        /// amountTextFieldItem
        let amountItem = AmountItem(text: ingredient.formattedAmount)
        
        /// detailitem for type cell
        let typeItem = DetailItem(name: Strings.type, detailLabel: ingredient.type.name)
        
        /// create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<IngredientDetailSection, TextItem>() // create the snapshot
        snapshot.appendSections(IngredientDetailSection.allCases) //append sections
        
        /// name Section
        snapshot.appendItems([nameItem], toSection: .name)
        
        /// amount Seciton
        snapshot.appendItems([amountItem], toSection: .amount)
        
        /// type Seciton
        // - TODO: append additional Items when cell is expanded
        snapshot.appendItems([typeItem], toSection: .type)
        
        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }
    

    
}

//import UIKit
//import BakingRecipeFoundation
//import BakingRecipeStrings
//import BakingRecipeCells
//
//class IngredientDetailViewController: UITableViewController {
//
//    // MARK: - Properties
//    private var ingredient: Ingredient {
//        didSet {
//            DispatchQueue.main.async {
//                self.setupNavigationBar()
//            }
//            update(oldValue: oldValue)
//        }
//    }
//
//    var creating: Bool
//    var saveIngredient: ((Ingredient) -> Void)
//
//    private func update(oldValue: Ingredient) {
//        DispatchQueue.global(qos: .background).async {
//            if !self.creating, oldValue != self.ingredient {
//                self.saveIngredient(self.ingredient)
//            }
//        }
//    }
//
//    init(ingredient: Ingredient, creating: Bool, saveIngredient: @escaping (Ingredient) -> ()) {
//        self.ingredient = ingredient
//        self.saveIngredient = saveIngredient
//        self.creating = creating
//        super.init(style: .insetGrouped)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError(Strings.init_coder_not_implemented)
//    }
//
//    // MARK: - Start functions
//
//    override func loadView() {
//        super.loadView()
//        self.tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
//        registerCells()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBar()
//    }
//
//    // MARK: - NavigationBar
//
//    private func setupNavigationBar() {
//        if creating {
//            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addIngredient))
//        }
//        title = self.ingredient.formattedName
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }
//
//    @objc private func addIngredient(_ sender: UIBarButtonItem) {
//        saveIngredient(ingredient)
//        navigationController?.popViewController(animated: true)
//    }
//
//    // MARK: - Rows and Sections
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return Strings.name
//        } else if section == 1 {
//            return Strings.amount
//        } else {
//            return nil
//        }
//    }
//
//    // MARK: - Cells
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            return makeNameCell()
//        } else if indexPath.section == 1 {
//            return makeAmountCell()
//        } else {
//            return makeTypeCell()
//        }
//    }
//
//    private func registerCells() {
//        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)
//        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell)
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.bulkLiquidCell)
//    }
//
//    private func makeNameCell() -> TextFieldCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell) as! TextFieldCell
//        cell.textField.text = ingredient.name
//        cell.textField.placeholder = Strings.name
//        cell.selectionStyle = .none
//        cell.textChanged = { text in
//            self.ingredient.name = text
//        }
//        cell.backgroundColor = UIColor.backgroundColor
//        return cell
//    }
//
//    private func makeAmountCell() -> AmountCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.amountCell) as! AmountCell
//        cell.setUp(with: ingredient, format: format)
//        return cell
//    }
//
//    private func format(amountText: String) -> String {
//        guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "" }
//        ingredient.amount = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
//        return ingredient.formatted(rest: amountText)
//    }
//
//    private func makeTypeCell() -> DetailCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.bulkLiquidCell) as! DetailCell
//
//        cell.textLabel?.text = Strings.type
//        cell.detailTextLabel?.text = ingredient.type.name
//        cell.accessoryType = .none
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 2 { // make sure its in the type section
//            // - TODO: navigate to List for Picking type
//        }
//    }
//
//}
