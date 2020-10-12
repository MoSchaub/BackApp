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
import BakingRecipeItems
import BakingRecipeUIFoundation


class StepDetailViewController: UITableViewController {
    
    
    // MARK: - Properties
    
    /// the step whose details are shown
    private var step: Step {
        didSet {
            if oldValue != self.step {
                self.setupNavigationBar()
                if !creating {
                    self.saveStep(self.step)
                }
            }
        }
    }
    
    /// the recipe the step is in
    private let recipe: Recipe
    
    ///wether the user is currently creating a new step or editing an existing one
    private var creating: Bool
    
    
    /// typealias for the method
    typealias SaveStep = ((Step) -> ())
    
    /// method to save or update the step
    private var saveStep: SaveStep
    
    
    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    // MARK: - Initalizers
    
    init(step: Step, creating: Bool, recipe: Recipe, saveStep: @escaping SaveStep) {
        self.step = step
        self.creating = creating
        self.saveStep = saveStep
        self.recipe = recipe
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Startup functions
extension StepDetailViewController {
    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .none
        registerCells()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyInitialSnapshot(animated: false) //update the tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyInitialSnapshot()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == StepDetailSection.notes.rawValue {
            return 100
        }
        return UITableView.automaticDimension
    }
    
    // MARK: - Header
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == StepDetailSection.ingredients.rawValue {
            return super.customHeader(enabled: !self.step.ingredients.isEmpty, title: Strings.ingredients, frame: tableView.frame)
        } else {
            return nil
        }
    }

}

// MARK: - NavigationBar
private extension StepDetailViewController {
    
    /// sets up navigation bar title and items
    private func setupNavigationBar() {
        //title
        self.title = step.formattedName
        
        //large Title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //items
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addStep))
        }
    }
    
    /// adds the step and pops the top view controller on the navigation stack
    @objc private func addStep(_ sender: UIBarButtonItem) {
        saveStep(step)
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Cell Registraiton
private extension StepDetailViewController {
    
    /// registers the different Cell Types for later reuse
    private func registerCells() {
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)  //name textField
        
        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.notesCell) // notes
        
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.durationCell) //durationCell
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: Strings.timePickerCell) //expanded duration
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.tempCell) //tempCell
        tableView.register(TempPickerCell.self, forCellReuseIdentifier: Strings.tempPickerCell) //tempPicker
        
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.addIngredientCell) // add ingredient
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: Strings.substepCell) // substep
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: Strings.ingredientCell) // ingredients
    }
    
}

enum StepDetailSection: Int, CaseIterable{
    case name
    case notes
    case durationTemp
    case ingredients
    
    var headerTitle: String? {
        switch self {
        case .name: return Strings.name
        case .notes: return Strings.notes
        case .durationTemp: return nil
        case .ingredients: return nil // it uses a custom view
        }
    }
}

// MARK: - Cell Selection
extension StepDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) as? DetailItem else { return }
        
        if item is IngredientItem {
            navigateToIngredientDetail(id: item.id)
        } else if StepDetailSection.allCases[indexPath.section] == .ingredients, !(item is SubstepItem) {
            navigateToIngredientDetail(id: nil)
        }
    }
}

private extension StepDetailViewController {
    
    private func navigateToIngredientDetail(id: UUID?) {
        let ingredient = id == nil ? Ingredient(name: "", amount: 0, type: .other) : step.ingredients.first(where: { $0.id == id!.uuidString })!
        
        let vc = IngredientDetailViewController(ingredient: ingredient, creating: id == nil) { newValue in
            if id == nil {
                self.step.ingredients.append(newValue)
                DispatchQueue.main.async {
                    self.applyInitialSnapshot()
                }
            } else {
                self.step.ingredients[self.step.ingredients.firstIndex(matching: newValue)!] = newValue
                DispatchQueue.main.async {
                    self.applyInitialSnapshot()
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - DataSource and Snapshot
private extension StepDetailViewController {
    
    ///create the diffableDataSource
    func makeDiffableDataSource() -> StepDetailDataSource {
        
        func dequeueAndSetupDetailCell<Cell: CustomCell>(at indexPath: IndexPath, withIdentifier: String, with detailItem: DetailItem) -> Cell {
            let cell = tableView.dequeueReusableCell(withIdentifier: withIdentifier, for: indexPath) as! Cell
            cell.textLabel?.text = detailItem.text
            cell.detailTextLabel?.text = detailItem.detailLabel
            return cell
        }

        return StepDetailDataSource(tableView: tableView, step: Binding(get: { self.step}, set: { newStep in  self.step = newStep })) { (tableView, indexPath, item) -> UITableViewCell? in
            if let textFieldItem = item as? TextFieldItem {
                // notes or name
                
                if indexPath.section == StepDetailSection.name.rawValue, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell, for: indexPath) as? TextFieldCell{
                    //name
                    cell.textField.text = textFieldItem.text
                    cell.textField.placeholder = Strings.name
                    cell.textChanged = { text in
                        self.step.name = text
                    }
                    return cell
                } else {
                    // notes
                    return TextViewCell(
                        textContent: Binding(get: { self.step.notes }, set: { newText in  self.step.notes = newText }),
                        placeholder: Strings.notes,
                        reuseIdentifier: Strings.notesCell
                    )
                }
            } else if let detailItem = item as? DetailItem {
                if indexPath.section == StepDetailSection.durationTemp.rawValue {
                    //duration or temp
                    if detailItem.text == Strings.duration {
                        //duration
                        let cell = dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.durationCell, with: detailItem)
                        
                        return cell
                    } else {
                        //temp
                        let cell = dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.tempCell, with: detailItem)
                        
                        return cell
                    }
                } else if indexPath.section == StepDetailSection.ingredients.rawValue {
                    if detailItem is IngredientItem{
                        //ingredient
                        return dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.ingredientCell, with: detailItem)
                    } else if detailItem is SubstepItem {
                        // substep
                        return dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.substepCell, with: detailItem)
                    } else  {
                        // add ingredient
                        return dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.addIngredientCell, with: detailItem)
                    }
                }
            }
            return CustomCell()
        }
    }
    
    /// updates the whole list
    private func applyInitialSnapshot(animated: Bool = true) {
        self.dataSource.apply(createInitialSnapshot(), animatingDifferences: animated)
    }
    
    private func createInitialSnapshot() -> NSDiffableDataSourceSnapshot<StepDetailSection, Item> {
        
        // textfieldItem
        let nameItem = TextFieldItem(text: step.name)
        
        // notesTextFieldItem
        let notesItem = TextFieldItem(text: step.notes)
        
        // detailitem for duration
        let durationItem = DetailItem(name: Strings.duration, detailLabel: step.formattedTime)
        
        // detailItem for temp
        let tempItem = DetailItem(name: Strings.temperature, detailLabel: step.formattedTemp)
        
        let ingredientItems = step.ingredients.map { IngredientItem(id: UUID(uuidString: $0.id)!, name: $0.formattedName, detailLabel: $0.detailLabel(for: step))}
        let substepItems = step.subSteps.map { SubstepItem(id: $0.id, name: $0.formattedName, detailLabel: $0.totalFormattedAmount + " " + $0.formattedTemp)}
        let addIngredientItem = DetailItem(name: Strings.addIngredient)
        
        // create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<StepDetailSection, Item>() // create the snapshot
        snapshot.appendSections(StepDetailSection.allCases) //append sections
        
        // name Section
        snapshot.appendItems([nameItem], toSection: .name)
        
        // notes Seciton
        snapshot.appendItems([notesItem], toSection: .notes)
        
        // duration
        snapshot.appendItems([durationItem], toSection: .durationTemp)
        
        // temp
        snapshot.appendItems([tempItem], toSection: .durationTemp)
        
        // ingredients
        snapshot.appendItems(substepItems, toSection: .ingredients)
        snapshot.appendItems(ingredientItems, toSection: .ingredients)
        snapshot.appendItems([addIngredientItem], toSection: .ingredients)
        
        return snapshot
    }
    
}

fileprivate extension Ingredient {
    func detailLabel(for step: Step) -> String {
        self.formattedAmount + (self.type == .bulkLiquid ? " \(step.themperature(for: self, roomThemperature: Standarts.standardRoomTemperature))° C" : "")
    }
}

fileprivate class StepDetailDataSource: UITableViewDiffableDataSource<StepDetailSection, Item> {
    
    @Binding var step: Step
    
    init(tableView: UITableView, step: Binding<Step>, cellProvider: @escaping UITableViewDiffableDataSource<StepDetailSection, Item>.CellProvider) {
        self._step = step
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        StepDetailSection.allCases.map { $0.headerTitle }[section]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let item = itemIdentifier(for: indexPath) else { return }
        if item is IngredientItem {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            
            apply(snapshot, animatingDifferences: true) {
                self.deleteIngredient(id: item.id)
            }
        } else if item is SubstepItem {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            
            apply(snapshot, animatingDifferences: true) {
                self.removeSubstep(id: item.id)
            }
        }
    }
    
    private func deleteIngredient(id: UUID) {
        if let ingredientIndex = step.ingredients.firstIndex(where: { $0.id == id.uuidString}) , ingredientIndex < step.ingredients.count {
            _ = step.ingredients.remove(at: ingredientIndex)
        }
    }
    
    private func removeSubstep(id: UUID) {
        if let index = step.subSteps.firstIndex(where: { $0.id == id }), index < step.subSteps.count {
            _ = step.subSteps.remove(at: index)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self.itemIdentifier(for: indexPath) is IngredientItem
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        self.itemIdentifier(for: indexPath) is IngredientItem
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard (itemIdentifier(for: sourceIndexPath) as? IngredientItem) != nil else { return }
        guard (itemIdentifier(for: destinationIndexPath) as? IngredientItem) != nil else { return }

        let ingredientToMove = step.ingredients.remove(at: sourceIndexPath.row)
        step.ingredients.insert(ingredientToMove, at: destinationIndexPath.row)
    }
}



//class StepDetailViewController: UITableViewController {
//
//    // MARK: - Properties
//    private var step: Step {
//        didSet {
//            DispatchQueue.main.async {
//                self.setupNavigationBar()
//            }
//            update(oldValue: oldValue)
//        }
//    }
//
//    var creating: Bool
//    var saveStep: ((Step) -> Void)
//    let recipe: Recipe
//
//    private func update(oldValue: Step) {
//        DispatchQueue.global(qos: .background).async {
//            if !self.creating, oldValue != self.step {
//                self.saveStep(self.step)
//            }
//        }
//    }
//
//    var datePicker: UIDatePicker!
//
//    init(step: Step, creating: Bool, recipe: Recipe, saveStep: @escaping (Step) -> ()) {
//        self.step = step
//        self.creating = creating
//        self.saveStep = saveStep
//        self.recipe = recipe
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
//        tableView.separatorStyle = .none
//        registerCells()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBar()
//    }
//
//    // MARK: - navigationBarItems
//
//    private func setupNavigationBar() {
//        if creating {
//            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(addStep))
//        } else {
//            navigationItem.rightBarButtonItem = editButtonItem
//        }
//        title = step.formattedName
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }
//
//    @objc private func addStep(_ sender: UIBarButtonItem) {
//        saveStep(step)
//        navigationController?.popViewController(animated: true)
//    }
//
//    // MARK: - Sections and rows
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 5
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 4 {
//            return step.ingredients.count + 1 + step.subSteps.count
//        } else {
//            return 1
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0: return Strings.name
//        case 1: return Strings.notes
//        case 2: return Strings.duration
//        case 3: return Strings.temperature
//        case 4: return Strings.ingredients
//        default: return ""
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 1 {
//            return 70
//        }
//        return UITableView.automaticDimension
//    }
//
//    // MARK: - Cells
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0: return makeNameCell()
//        case 1: return makeNotesCell()
//        case 2: return makeDurationCell()
//        case 3: return makeTempCell()
//        case 4:
//            if indexPath.row - step.subSteps.count == step.ingredients.count {
//                return makeAddIngredientCell()
//            } else if indexPath.row < step.subSteps.count{
//                return makeSubstepCell(at: indexPath)
//            } else {
//                return makeIngredientCell(at: indexPath)
//            }
//        default: return UITableViewCell()
//        }
//    }
//
//    private func registerCells() {
//        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.nameCell)
//        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.notesCell)
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.durationCell)
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.tempCell)
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.addIngredientCell)
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.substepCell)
//        tableView.register(SubtitleCell.self, forCellReuseIdentifier: Strings.ingredientCell)
//    }
//
//    private func makeNameCell() -> TextFieldCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.nameCell) as! TextFieldCell
//        cell.textField.text = step.name
//        cell.textField.placeholder = Strings.name
//        cell.selectionStyle = .none
//        cell.textChanged = { text in
//            self.step.name = text
//        }
//        cell.backgroundColor = UIColor.backgroundColor
//        return cell
//    }
//
//    private func makeNotesCell() -> TextViewCell {
//        let cell = TextViewCell(textContent: Binding(get: {
//            return self.step.notes
//        }, set: { newValue in
//            self.step.notes = newValue
//        }), placeholder: Strings.notes, reuseIdentifier: Strings.notesCell)
//        return cell
//    }
//
//    private func makeDurationCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.durationCell)!
//
//        cell.textLabel?.text = step.formattedTime
//        cell.accessoryType = .disclosureIndicator
//
//        cell.backgroundColor = UIColor.backgroundColor
//        return cell
//    }
//
//    private func makeTempCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempCell)!
//        cell.textLabel?.text = step.formattedTemp
//        cell.accessoryType = .disclosureIndicator
//        cell.backgroundColor = UIColor.backgroundColor
//
//        return cell
//    }
//
//    private func makeIngredientCell(at indexPath: IndexPath) -> SubtitleCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.ingredientCell, for: indexPath) as! SubtitleCell
//        let ingredient = step.ingredients[indexPath.row - step.subSteps.count]
//        cell.textLabel?.text = ingredient.name
//        cell.detailTextLabel?.text = ingredient.formattedAmount + (ingredient.type == .bulkLiquid ? " \(step.themperature(for: ingredient, roomThemperature: Standarts.standardRoomTemperature))° C" : "")
//
//        return cell
//    }
//
//    private func makeSubstepCell(at indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Strings.substepCell)
//        cell.prepareForReuse()
//
//        let substep = step.subSteps[indexPath.row]
//        cell.textLabel?.text = substep.name
//        cell.detailTextLabel?.text = substep.totalFormattedAmount + " " + substep.formattedTemp
//        cell.accessoryType = .disclosureIndicator
//        cell.backgroundColor = UIColor.backgroundColor
//
//        return cell
//    }
//
//    private func makeAddIngredientCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.addIngredientCell)!
//
//        cell.textLabel?.text = Strings.addIngredient
//        cell.accessoryType = .disclosureIndicator
//        cell.backgroundColor = UIColor.backgroundColor
//
//        return cell
//    }
//
//    // MARK: delete and move
//
//    //conditional deletion
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable
//        indexPath.section == 4 && indexPath.row - step.subSteps.count != step.ingredients.count
//    }
//
//    //delete cells
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            if indexPath.row < step.subSteps.count {
//                step.subSteps.remove(at: indexPath.row)
//            } else {
//                step.ingredients.remove(at: indexPath.row - step.subSteps.count)
//            }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
//
//    // moving cells
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard destinationIndexPath.section == 4 else { tableView.reloadData(); return }
//        guard destinationIndexPath.row < step.ingredients.count else { tableView.reloadData(); return }
//        guard sourceIndexPath.row < step.ingredients.count else { tableView.reloadData(); return }
//        let movedObject = step.ingredients[sourceIndexPath.row]
//        step.ingredients.remove(at: sourceIndexPath.row)
//        step.ingredients.insert(movedObject, at: destinationIndexPath.row)
//    }
//
//    //conditional moving
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        indexPath.section == 4 && indexPath.row > step.subSteps.count - 1 && indexPath.row != step.ingredients.count + step.subSteps.count
//    }
//
//    // MARK: - Navigation
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 2 {
//            navigateToTimePicker(indexPath: indexPath)
//        } else if indexPath.section == 3 {
//            navigateToTempPicker(indexPath: indexPath)
//        } else if indexPath.section == 4 {
//            navigateToIngredientStepOrSubstep(indexPath: indexPath)
//        }
//    }
//
//    private func navigateToIngredientStepOrSubstep(indexPath: IndexPath) {
//            if indexPath.row - step.subSteps.count == step.ingredients.count {
//                let stepsWithIngredients = recipe.steps.filter({ step1 in step1.ingredients.count != 0 && step1.id != self.step.id && !self.step.subSteps.contains(where: {step1.id == $0.id})})
//                let stepsWithSubsteps = recipe.steps.filter({ step1 in step1.subSteps.count != 0 && step1.id != self.step.id && !self.step.subSteps.contains(where: { step1.id == $0.id})}).filter({ !stepsWithIngredients.contains($0)})
//                if stepsWithIngredients.count > 0 || stepsWithSubsteps.count > 0{
//                    let alert = UIAlertController(title: Strings.ingredientOrStep, message: nil, preferredStyle: .actionSheet)
//
//                    alert.addAction(UIAlertAction(title: Strings.newIngredient, style: .default, handler: { _ in
//                        self.navigateToIngredientDetail(creating: true, indexPath: indexPath)
//                    }))
//                    alert.addAction(UIAlertAction(title: Strings.step, style: .default, handler: { _ in
//                        self.showSubstepsActionSheet(possibleSubsteps: stepsWithIngredients + stepsWithSubsteps)
//                    }))
//                    alert.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
//
//                    present(alert, animated: true)
//                } else {
//                    navigateToIngredientDetail(creating: true, indexPath: indexPath)
//                }
//            } else if indexPath.row < step.subSteps.count{
//                // do nothing
//            } else {
//                navigateToIngredientDetail(creating: false, indexPath: indexPath)
//            }
//    }
//
//    private func navigateToTimePicker(indexPath: IndexPath) {
//        let timePickerVC = StepTimeTableViewController(time: Binding(get: {
//            return self.step.time
//        }, set: { (newValue) in
//            DispatchQueue.global(qos: .utility).async {
//                if newValue != self.step.time {
//                    self.step.time = newValue
//                    DispatchQueue.main.async {
//                        self.tableView.reloadRows(at: [indexPath], with: .none)
//                    }
//                }
//            }
//        }))
//
//        navigationController?.pushViewController(timePickerVC, animated: true)
//    }
//
//    private func navigateToTempPicker(indexPath: IndexPath) {
//        let tempPickerVC = StepTempTableViewController(step: Binding(get: {
//            return self.step
//        }, set: { (newValue) in
//            DispatchQueue.global(qos: .utility).async {
//                self.step = newValue
//                DispatchQueue.main.async {
//                    self.tableView.reloadRows(at: [indexPath], with: .none)
//                }
//            }
//        }))
//        navigationController?.pushViewController(tempPickerVC, animated: true)
//    }
//
//    private func navigateToIngredientDetail(creating: Bool, indexPath: IndexPath) {
//        let ingredient = creating ? Ingredient(name: "", amount: 0, type: .other) : step.ingredients[indexPath.row - step.subSteps.count]
//        let ingredientDetailVC = IngredientDetailViewController(ingredient: ingredient, creating: creating) { ingredient in
//            if creating {
//                self.step.ingredients.append(ingredient)
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            } else {
//                self.step.ingredients[indexPath.row - self.step.subSteps.count] = ingredient
//                DispatchQueue.main.async {
//                    self.tableView.reloadRows(at: [indexPath], with: .none)
//                }
//            }
//
//        }
//
//        navigationController?.pushViewController(ingredientDetailVC, animated: true)
//    }
//
//    private func showSubstepsActionSheet(possibleSubsteps: [Step]) {
//        let actionSheet = UIAlertController(title: Strings.selectStep, message: nil, preferredStyle: .actionSheet)
//
//        for possibleSubstep in possibleSubsteps {
//            actionSheet.addAction(UIAlertAction(title: possibleSubstep.formattedName, style: .default, handler: { _ in
//                self.step.subSteps.append(possibleSubstep)
//                self.tableView.reloadData()
//            }))
//        }
//
//        actionSheet.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
//
//        present(actionSheet, animated: true)
//    }
//
//}
