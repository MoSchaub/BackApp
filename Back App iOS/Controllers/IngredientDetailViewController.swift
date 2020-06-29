//
//  IngredientDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class IngredientDetailViewController: UITableViewController {
    
    // MARK: - Properties
    var ingredient: Ingredient! {
        willSet {
            if newValue != nil {
                recipeStore.update(ingredient: newValue, step: step)
                title = newValue.formattedName
            }
        }
    }
    var step: Step!
    
    var recipeStore: RecipeStore!
    
    var initializing = true
    var creating = false
    var saveIngredient: ((Ingredient, Step) -> Void)?
    
    // MARK: - Start functions
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        registerCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBarItems()
    }
    
    // MARK: - NavigationBarItems
    
    private func addNavigationBarItems() {
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addIngredient))
        }
    }
    
    @objc private func addIngredient(_ sender: UIBarButtonItem) {
        if let saveIngredient = saveIngredient {
            saveIngredient(ingredient, step)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Rows and Sections

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Name"
        } else if section == 1 {
            return "Menge"
        } else {
            return nil
        }
    }
    
    // MARK: - Cells

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return makeNameCell()
        } else if indexPath.section == 1 {
            return makeAmountCell()
        } else {
            return makeIsBulkLiquidCell()
        }
    }
    
    private func registerCells() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "name")
        tableView.register(AmountTableViewCell.self, forCellReuseIdentifier: "menge")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "isBulkLiquid")
    }
    
    private func makeNameCell() -> TextFieldTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "name") as! TextFieldTableViewCell
        cell.textField.text = ingredient.name
        cell.textField.placeholder = "Name"
        cell.selectionStyle = .none
        cell.textChanged = { text in
            self.ingredient.name = text
        }
        return cell
    }
    
    private func makeAmountCell() -> AmountTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menge") as! AmountTableViewCell
        cell.setUp(with: ingredient, format: format)
        return cell
    }
    
    private func format(amountText: String) -> String {
        guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "" }
        ingredient.amount = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        return ingredient.formatted(rest: amountText)
    }
    
    private func makeIsBulkLiquidCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "isBulkLiquid")!
        
        let toggle = UISwitch(frame: .zero)
        
        toggle.setOn(ingredient.isBulkLiquid, animated: false)
        toggle.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        cell.selectionStyle = .none
        cell.accessoryView = toggle
        
        cell.textLabel?.text = "Schüttflüssigkeit"
        
        return cell
    }
    
    @objc private func toggleTapped(_ sender: UISwitch) {
        ingredient.isBulkLiquid = sender.isOn
        //tableView.reloadData()
    }
}
