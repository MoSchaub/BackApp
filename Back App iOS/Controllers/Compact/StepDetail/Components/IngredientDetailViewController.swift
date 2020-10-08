//
//  IngredientDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeFoundation
import BakingRecipeStrings
import BakingRecipeCells

class IngredientDetailViewController: UITableViewController {
    
    // MARK: - Properties
    private var ingredient: Ingredient {
        didSet {
            DispatchQueue.main.async {
                self.setupNavigationBar()
            }
            update(oldValue: oldValue)
        }
    }

    var creating: Bool
    var saveIngredient: ((Ingredient) -> Void)
    
    private func update(oldValue: Ingredient) {
        DispatchQueue.global(qos: .background).async {
            if !self.creating, oldValue != self.ingredient {
                self.saveIngredient(self.ingredient)
            }
        }
    }
    
    var datePicker: UIDatePicker!
    
    init(ingredient: Ingredient, creating: Bool, saveIngredient: @escaping (Ingredient) -> ()) {
        self.ingredient = ingredient
        self.saveIngredient = saveIngredient
        self.creating = creating
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    // MARK: - Start functions
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        registerCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // MARK: - NavigationBar
    
    private func setupNavigationBar() {
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addIngredient))
        }
        title = self.ingredient.formattedName
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc private func addIngredient(_ sender: UIBarButtonItem) {
        saveIngredient(ingredient)
        navigationController?.popViewController(animated: true)
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
            return Strings.name
        } else if section == 1 {
            return Strings.amount
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
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)
        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell)
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.bulkLiquidCell)
    }
    
    private func makeNameCell() -> TextFieldCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell) as! TextFieldCell
        cell.textField.text = ingredient.name
        cell.textField.placeholder = Strings.name
        cell.selectionStyle = .none
        cell.textChanged = { text in
            self.ingredient.name = text
        }
        cell.backgroundColor = UIColor.backgroundColor
        return cell
    }
    
    private func makeAmountCell() -> AmountCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.amountCell) as! AmountCell
        cell.setUp(with: ingredient, format: format)
        return cell
    }
    
    private func format(amountText: String) -> String {
        guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "" }
        ingredient.amount = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        return ingredient.formatted(rest: amountText)
    }
    
    private func makeIsBulkLiquidCell() -> CustomCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.bulkLiquidCell) as! CustomCell
        
        let toggle = UISwitch(frame: .zero)
        
        toggle.setOn(ingredient.isBulkLiquid, animated: false)
        toggle.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        cell.accessoryView = toggle
        
        cell.textLabel?.text = Strings.bulkLiquid
        
        return cell
    }
    
    @objc private func toggleTapped(_ sender: UISwitch) {
        ingredient.isBulkLiquid = sender.isOn
    }
}
