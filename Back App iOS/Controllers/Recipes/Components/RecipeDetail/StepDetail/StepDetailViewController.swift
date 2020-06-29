//
//  StepDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 27.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

class StepDetailViewController: UITableViewController {
    
    // MARK: - Properties
    var step: Step! {
        willSet {
            if newValue != nil { if recipe != nil, recipeStore != nil {
                recipeStore.update(step: newValue, in: recipe)
                }
                title = newValue.formattedName
            }
        }
    }
    var recipe: Recipe!
    
    var recipeStore: RecipeStore!
    
    var initializing = true
    var creating = false
    var saveStep: ((Step, Recipe) -> Void)?
    
    var datePicker: UIDatePicker!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !initializing {
            self.step = recipeStore.stepForUpdate(oldStep: step, in: recipe)
            tableView.reloadData()
        }
        initializing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if creating {
            recipeStore.save(recipe: recipe)
            recipeStore.save(step: step, to: recipe)
        }
    }
    
    // MARK: - navigationBarItems
    
    private func addNavigationBarItems() {
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addStep))
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    @objc private func addStep(_ sender: UIBarButtonItem) {
        if creating, let saveStep = saveStep {
            saveStep(step, recipe)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Sections and rows

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return step.ingredients.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Notizen"
        case 2: return "Dauer"
        case 3: return "Temperatur"
        case 4: return "Zutaten"
        default: return ""
        }
    }

    // MARK: - Cells
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return makeNameCell()
        case 1: return makeNotesCell()
        case 2: return makeDurationCell()
        case 3: return makeTempCell()
        case 4:
            if indexPath.row == step.ingredients.count {
                return makeAddIngredientCell()
            } else {
                return makeIngredientCell(at: indexPath)
            }
        default: return UITableViewCell()
        }
    }

    private func registerCells() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "name")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "notes")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "duration")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "temp")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addIngredient")
    }

    private func makeNameCell() -> TextFieldTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "name") as! TextFieldTableViewCell
        cell.textField.text = step.name
        cell.textField.placeholder = "Name"
        cell.selectionStyle = .none
        cell.textChanged = { text in
            self.step.name = text
        }
        return cell
    }
    
    private func makeNotesCell() -> TextFieldTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notes") as! TextFieldTableViewCell
        cell.textField.text = step.notes
        cell.textField.placeholder = "Notizen"
        cell.selectionStyle = .none
        cell.textChanged = { text in
            self.step.notes = text
        }
        return cell
    }
    
    private func makeDurationCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "duration")!
        
        cell.textLabel?.text = step.formattedTime
        cell.accessoryType = .disclosureIndicator
            
        return cell
    }
    
    private func makeTempCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "temp")!
        cell.textLabel?.text = step.formattedTemp
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func makeIngredientCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ingredient")
        cell.prepareForReuse()
        
        let ingredient = step.ingredients[indexPath.row]
        cell.textLabel?.text = ingredient.name
        cell.detailTextLabel?.text = ingredient.formattedAmount + (ingredient.isBulkLiquid ? " \(step.themperature(for: ingredient, roomThemperature: recipeStore.roomTemperature))° C" : "")
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func makeAddIngredientCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addIngredient")!
        
        cell.textLabel?.text = "Zutat hinzufügen"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    // MARK: delete and move
    
    //conditional deletion
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        indexPath.section == 4 && indexPath.row < step.ingredients.count
    }

    //delete cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            step.ingredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // moving cells
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section == 4 else { return }
        guard sourceIndexPath.row < step.ingredients.count else { return }
        let movedObject = step.ingredients[sourceIndexPath.row]
        step.ingredients.remove(at: sourceIndexPath.row)
        step.ingredients.insert(movedObject, at: destinationIndexPath.row)
    }

    //conditional moving
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        indexPath.section == 4 && indexPath.row < step.ingredients.count
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            navigateToTimePicker()
        } else if indexPath.section == 3 {
            navigateToTempPicker()
        } else if indexPath.section == 4 {
            navigateToIngredientDetail(creating: indexPath.row >= step.ingredients.count, indexPath: indexPath)
        }
    }
    
    private func navigateToTimePicker() {
        let timePickerVC = StepTimeTableViewController(style: .insetGrouped)
        timePickerVC.recipeStore = recipeStore
        timePickerVC.recipe = recipe
        timePickerVC.step = step
        
        navigationController?.pushViewController(timePickerVC, animated: true)
    }
    
    private func navigateToTempPicker() {
        let tempPickerVC = StepTempTableViewController(style: .insetGrouped)
        tempPickerVC.recipeStore = recipeStore
        tempPickerVC.recipe = recipe
        tempPickerVC.step = step
        
        navigationController?.pushViewController(tempPickerVC, animated: true)
    }
    
    private func navigateToIngredientDetail(creating: Bool, indexPath: IndexPath) {
        let ingredientDetailVC = IngredientDetailViewController()
        
        ingredientDetailVC.recipeStore = recipeStore
        ingredientDetailVC.step = step
        ingredientDetailVC.ingredient = creating ? Ingredient(name: "", amount: 0) : step.ingredients[indexPath.row]
        ingredientDetailVC.creating = creating
        
        if creating {
            ingredientDetailVC.saveIngredient = save
        }
        
        navigationController?.pushViewController(ingredientDetailVC, animated: true)
    }
    
    private func save(ingredient: Ingredient, step: Step){
        recipeStore.add(ingredient: ingredient, step: step)
        tableView.reloadData()
    }

}