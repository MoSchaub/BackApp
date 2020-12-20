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
import BakingRecipeSections

class IngredientDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// the details are of this ingredient
    private var ingredient: Ingredient {
        didSet {
            if oldValue != ingredient {
                self.setupNavigationBar()
                self.saveIngredient(self.ingredient)
            }
            
        }
    }
    
    ///wether the typeSection is expanded
    private var typeSectionExpanded: Bool {
        self.dataSource.itemIdentifier(for: IndexPath(row: 1, section: 2)) != nil
    }
    
    /// method to update the recipe when it changes
    private var saveIngredient: ((Ingredient) -> Void)
    
    
    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    
    // MARK: - Initializers
    
    init(ingredient: Ingredient, saveIngredient: @escaping (Ingredient) -> () ) {
        self.ingredient = ingredient
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
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList(animated: false)
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


// MARK: - DataSource and Snapshot
private extension IngredientDetailViewController {
    
    ///create the diffableDataSource
    func makeDiffableDataSource() -> IngredientDetailDataSource {
    
        /// format func for amountCell
        func format(amountText: String) -> String {
            guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return self.ingredient.formattedAmount }
            ingredient.mass = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            return ingredient.formatted(rest: amountText)
        }
        return IngredientDetailDataSource(tableView: tableView) { (tableView, indexPath, textItem) -> UITableViewCell? in
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
                if self.typeSectionExpanded {
                    cell.detailTextLabel?.textColor = .red
                } else {
                    cell.detailTextLabel?.textColor = .secondaryColor
                }
                return cell
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: Strings.plainCell, for: indexPath) as? CustomCell {
                cell.textLabel?.text = textItem.text
                return cell
            } else {
                return CustomCell()
            }
        }
    }
    
    /// updates the whole list
    private func updateList(animated: Bool = true) {
        self.dataSource.apply(createInitialSnapshot(), animatingDifferences: animated)
    }
    
    private func createInitialSnapshot() -> NSDiffableDataSourceSnapshot<IngredientDetailSection, TextItem> {
        
        /// textfieldItem
        let nameItem = TextFieldItem(text: ingredient.name)
        
        /// amountTextFieldItem
        let amountItem = AmountItem(text: ingredient.formattedAmount)
        
        /// detailitem for type cell
        let typeItem = typeSectionHeader()
        
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
        
        return snapshot
    }
    
    private func typeSectionHeader() -> DetailItem {
        return DetailItem(name: Strings.type, detailLabel: ingredient.type.name)
    }
    
}


// MARK: - Type Selection
extension IngredientDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSource.itemIdentifier(for: indexPath) is DetailItem {
            typeSectionExpanded ? collapseTypeSection() : expandTypeSection()
        } else if let textItem = dataSource.itemIdentifier(for: indexPath), typeSectionExpanded,
                  let index = Ingredient.Style.allCases.map({ $0.name}).firstIndex(of: textItem.text),
                  Ingredient.Style.allCases.count > index{
            let newType = Ingredient.Style.allCases[index]
            self.ingredient.type = newType
            
            self.reloadTypeHeader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.collapseTypeSection()
            }
        }
    }
    
    private func typeSectionItems() -> [TextItem] {
        return Ingredient.Style.allCases.map { TextItem(text: $0.name)}
    }
    
    private func expandTypeSection(animated: Bool = true) {
        if !typeSectionExpanded {

            var snapshot = dataSource.snapshot()
            
            let items = typeSectionItems()
            snapshot.appendItems(items, toSection: .type)
            
            self.dataSource.apply(snapshot, animatingDifferences: animated)
            
            self.reloadTypeSection()
        }
    }
    
    private func collapseTypeSection() {
        if typeSectionExpanded {
            
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .type).filter { $0.text != Strings.type})
            self.dataSource.apply(snapshot)
            
            self.reloadTypeSection()

        }
    }
    
    /// reload type section
    private func reloadTypeSection() {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            
            snapshot.reloadSections([.name])
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    /// reload first cell in typeSection
    private func reloadTypeHeader() {
        updateList(animated: false)
        self.expandTypeSection(animated: false)
    }
}


// MARK: - Section headers
fileprivate class IngredientDetailDataSource: UITableViewDiffableDataSource< IngredientDetailSection, TextItem> {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return Strings.name
        case 1: return Strings.amount
        default:
            return ""
        }
    }
}
