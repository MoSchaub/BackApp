//
//  StepDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 27.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeStrings
import BakingRecipeCore
import BakingRecipeCells

class StepDetailViewController: UITableViewController {
    
    // MARK: - Properties
    private var step: Step {
        didSet {
            DispatchQueue.main.async {
                self.setupNavigationBar()
            }
            update(oldValue: oldValue)
        }
    }

    var creating: Bool
    var saveStep: ((Step) -> Void)
    let recipe: Recipe
    
    private func update(oldValue: Step) {
        DispatchQueue.global(qos: .background).async {
            if !self.creating, oldValue != self.step {
                self.saveStep(self.step)
            }
        }
    }
    
    var datePicker: UIDatePicker!
    
    init(step: Step, creating: Bool, recipe: Recipe, saveStep: @escaping (Step) -> ()) {
        self.step = step
        self.creating = creating
        self.saveStep = saveStep
        self.recipe = recipe
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    // MARK: - Start functions
    
    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .none
        registerCells()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // MARK: - navigationBarItems
    
    private func setupNavigationBar() {
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addStep))
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
        }
        title = step.formattedName
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc private func addStep(_ sender: UIBarButtonItem) {
        saveStep(step)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Sections and rows

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return step.ingredients.count + 1 + step.subSteps.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return Strings.name
        case 1: return Strings.notes
        case 2: return Strings.duration
        case 3: return Strings.temperature
        case 4: return Strings.ingredients
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 70
        }
        return UITableView.automaticDimension
    }

    // MARK: - Cells
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return makeNameCell()
        case 1: return makeNotesCell()
        case 2: return makeDurationCell()
        case 3: return makeTempCell()
        case 4:
            if indexPath.row - step.subSteps.count == step.ingredients.count {
                return makeAddIngredientCell()
            } else if indexPath.row < step.subSteps.count{
                return makeSubstepCell(at: indexPath)
            } else {
                return makeIngredientCell(at: indexPath)
            }
        default: return UITableViewCell()
        }
    }

    private func registerCells() {
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.notesCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.durationCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.tempCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.addIngredientCell)
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.substepCell)
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: Strings.ingredientCell)
    }

    private func makeNameCell() -> TextFieldCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell) as! TextFieldCell
        cell.textField.text = step.name
        cell.textField.placeholder = Strings.name
        cell.selectionStyle = .none
        cell.textChanged = { text in
            self.step.name = text
        }
        cell.backgroundColor = UIColor.backgroundColor
        return cell
    }
    
    private func makeNotesCell() -> TextViewCell {
        let cell = TextViewCell(textContent: Binding(get: {
            return self.step.notes
        }, set: { newValue in
            self.step.notes = newValue
        }), placeholder: Strings.notes, reuseIdentifier: Strings.notesCell)
        return cell
    }
    
    private func makeDurationCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.durationCell)!
        
        cell.textLabel?.text = step.formattedTime
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = UIColor.backgroundColor
        return cell
    }
    
    private func makeTempCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempCell)!
        cell.textLabel?.text = step.formattedTemp
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.backgroundColor
        
        return cell
    }
    
    private func makeIngredientCell(at indexPath: IndexPath) -> SubtitleCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.ingredientCell, for: indexPath) as! SubtitleCell
        let ingredient = step.ingredients[indexPath.row - step.subSteps.count]
        cell.textLabel?.text = ingredient.name
        cell.detailTextLabel?.text = ingredient.formattedAmount + (ingredient.type == .bulkLiquid ? " \(step.themperature(for: ingredient, roomThemperature: Settings.standardRoomTemperature))° C" : "")

        return cell
    }
    
    private func makeSubstepCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Strings.substepCell)
        cell.prepareForReuse()
        
        let substep = step.subSteps[indexPath.row]
        cell.textLabel?.text = substep.name
        cell.detailTextLabel?.text = substep.totalFormattedAmount + " " + substep.formattedTemp
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.backgroundColor
        
        return cell
    }
    
    private func makeAddIngredientCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.addIngredientCell)!
        
        cell.textLabel?.text = Strings.addIngredient
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.backgroundColor
        
        return cell
    }

    // MARK: delete and move
    
    //conditional deletion
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable
        indexPath.section == 4 && indexPath.row - step.subSteps.count != step.ingredients.count
    }

    //delete cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.row < step.subSteps.count {
                step.subSteps.remove(at: indexPath.row)
            } else {
                step.ingredients.remove(at: indexPath.row - step.subSteps.count)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // moving cells
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section == 4 else { tableView.reloadData(); return }
        guard destinationIndexPath.row < step.ingredients.count else { tableView.reloadData(); return }
        guard sourceIndexPath.row < step.ingredients.count else { tableView.reloadData(); return }
        let movedObject = step.ingredients[sourceIndexPath.row]
        step.ingredients.remove(at: sourceIndexPath.row)
        step.ingredients.insert(movedObject, at: destinationIndexPath.row)
    }

    //conditional moving
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        indexPath.section == 4 && indexPath.row > step.subSteps.count - 1 && indexPath.row != step.ingredients.count + step.subSteps.count
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            navigateToTimePicker(indexPath: indexPath)
        } else if indexPath.section == 3 {
            navigateToTempPicker(indexPath: indexPath)
        } else if indexPath.section == 4 {
            navigateToIngredientStepOrSubstep(indexPath: indexPath)
        }
    }
    
    private func navigateToIngredientStepOrSubstep(indexPath: IndexPath) {
            if indexPath.row - step.subSteps.count == step.ingredients.count {
                let stepsWithIngredients = recipe.steps.filter({ step1 in step1.ingredients.count != 0 && step1.id != self.step.id && !self.step.subSteps.contains(where: {step1.id == $0.id})})
                let stepsWithSubsteps = recipe.steps.filter({ step1 in step1.subSteps.count != 0 && step1.id != self.step.id && !self.step.subSteps.contains(where: { step1.id == $0.id})}).filter({ !stepsWithIngredients.contains($0)})
                if stepsWithIngredients.count > 0 || stepsWithSubsteps.count > 0{
                    let alert = UIAlertController(title: Strings.ingredientOrStep, message: nil, preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: Strings.newIngredient, style: .default, handler: { _ in
                        self.navigateToIngredientDetail(creating: true, indexPath: indexPath)
                    }))
                    alert.addAction(UIAlertAction(title: Strings.step, style: .default, handler: { _ in
                        self.showSubstepsActionSheet(possibleSubsteps: stepsWithIngredients + stepsWithSubsteps)
                    }))
                    alert.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
                    
                    present(alert, animated: true)
                } else {
                    navigateToIngredientDetail(creating: true, indexPath: indexPath)
                }
            } else if indexPath.row < step.subSteps.count{
                // do nothing
            } else {
                navigateToIngredientDetail(creating: false, indexPath: indexPath)
            }
    }
    
    private func navigateToTimePicker(indexPath: IndexPath) {
        let timePickerVC = StepTimeTableViewController(time: Binding(get: {
            return self.step.time
        }, set: { (newValue) in
            DispatchQueue.global(qos: .utility).async {
                if newValue != self.step.time {
                    self.step.time = newValue
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }))
        
        navigationController?.pushViewController(timePickerVC, animated: true)
    }
    
    private func navigateToTempPicker(indexPath: IndexPath) {
        let tempPickerVC = StepTempTableViewController(step: Binding(get: {
            return self.step
        }, set: { (newValue) in
            DispatchQueue.global(qos: .utility).async {
                self.step = newValue
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }))
        navigationController?.pushViewController(tempPickerVC, animated: true)
    }
    
    private func navigateToIngredientDetail(creating: Bool, indexPath: IndexPath) {
        let ingredient = creating ? Ingredient(name: "", amount: 0, type: .other) : step.ingredients[indexPath.row - step.subSteps.count]
        let ingredientDetailVC = IngredientDetailViewController(ingredient: ingredient, creating: creating) { ingredient in
            if creating {
                self.step.ingredients.append(ingredient)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.step.ingredients[indexPath.row - self.step.subSteps.count] = ingredient
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            
        }

        navigationController?.pushViewController(ingredientDetailVC, animated: true)
    }
    
    private func showSubstepsActionSheet(possibleSubsteps: [Step]) {
        let actionSheet = UIAlertController(title: Strings.selectStep, message: nil, preferredStyle: .actionSheet)
        
        for possibleSubstep in possibleSubsteps {
            actionSheet.addAction(UIAlertAction(title: possibleSubstep.formattedName, style: .default, handler: { _ in
                self.step.subSteps.append(possibleSubstep)
                self.tableView.reloadData()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }

}
