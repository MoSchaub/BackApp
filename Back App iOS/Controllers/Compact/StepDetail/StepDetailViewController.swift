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
import BackAppCore
import BakingRecipeCells
import BakingRecipeItems
import BakingRecipeUIFoundation

class StepDetailViewController: UITableViewController {
    
    
    // MARK: - Properties
    
    private let stepId: Int
    
    private let theme: Theme
    
    /// the step whose details are shown
    private var step: Step {
        get {
            return appData.object(with: stepId, of: Step.self)!
        }
        
        set {
            if self.appData.update(newValue) {
                DispatchQueue.global(qos: .utility).async {
                    self.setupNavigationBar()
                }
            }
        }
    }

    /// table view dataSource
    private lazy var dataSource = makeDiffableDataSource()
    
    /// appData
    private var appData: BackAppData
    
    ///wether the datePickerCell is shown
    private var datePickerShown: Bool {
        !(self.dataSource.itemIdentifier(for: IndexPath(row: 1, section: StepDetailSection.durationTemp.rawValue)) is DetailItem)
    }
    
    ///wether the tempPicker is shown
    private var tempPickerShown: Bool {
        self.dataSource.itemIdentifier(for: IndexPath(row: self.datePickerShown ? 3 : 2, section: StepDetailSection.durationTemp.rawValue)) != nil
    }
    
    // MARK: - Initalizers
    
    init(stepId: Int, appData: BackAppData, theme: Theme) {
        self.appData = appData
        self.stepId = stepId
        self.theme = theme
        super.init(style: .insetGrouped)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Startup functions
extension StepDetailViewController {
    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .none
        registerCells()
        setupNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(updateListWrapper), name: .init("stepChanged"), object: nil)
    }
    
    @objc private func updateListWrapper(animated: Bool = false) {
        self.updateList(animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList(animated: false) //update the tableView
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
    
    // MARK:  Header
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == StepDetailSection.ingredients.rawValue {
            return super.customHeader(enabled: self.editButtonEnabled(), title: Strings.ingredients, frame: tableView.frame)
        } else {
            return nil
        }
    }
    
    private func editButtonEnabled() -> Bool {
        !appData.ingredients(with: step.id).isEmpty || !appData.substeps(for: step.id).isEmpty
    }

}

// MARK: - NavigationBar
private extension StepDetailViewController {
    
    /// sets up navigation bar title and items
    private func setupNavigationBar() {
        DispatchQueue.main.async {
            //title
            self.title = self.step.formattedName
            
            //large Title
            self.navigationController?.navigationBar.prefersLargeTitles = true
            
        }
    }
    
    /// adds the step and pops the top view controller on the navigation stack
    @objc private func addStep(_ sender: UIBarButtonItem) {
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
        tableView.register(TimePickerCell.self, forCellReuseIdentifier: Strings.timePickerCell) //expanded duration
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

            // navigate to existing ingredient
            navigateToIngredientDetail(id: item.id)
        } else if StepDetailSection.allCases[indexPath.section] == .ingredients, !(item is SubstepItem) { //add ingredient pressed

            //add ingredient or substep
            if appData.stepsWithIngredientsOrSupersteps(in: self.step.recipeId, without: self.stepId).count > 0{

                //action sheet let the user pick
                presentSubstepIngredientDecisionSheet(possibleSubsteps: appData.stepsWithIngredientsOrSupersteps(in: self.step.recipeId, without: self.stepId))

            } else {

                //no possible substeps so create new ingredient
                navigateToIngredientDetail(id: nil)
            }

        } else if StepDetailSection.allCases[indexPath.section] == .durationTemp {

            if item.text == Strings.duration {

                //duration cell tapped now expand the datePickerCell
                self.datePickerShown ? collapseDatePicker() : expandDatePicker(animated: false)
            } else if item.text == Strings.temperature {

                // temp cell tapped expand tempPicker Cell
                self.tempPickerShown ? collapseTempPicker() : expandTempPicker(animated: false)
            }
        } else if item is SubstepItem {
            
            let stepDetailVC = StepDetailViewController(stepId: item.id, appData: appData, theme: theme)
            
            //navigate to the controller
            navigationController?.pushViewController(stepDetailVC, animated: true)
        }
    }
    
    /// presents an actionsheet asking the user if he wants to add a substep or a new ingredient
    private func presentSubstepIngredientDecisionSheet(possibleSubsteps: [Step]) {
        let alert = UIAlertController(title: Strings.ingredientOrStep, message: nil, preferredStyle: .actionSheet)
        
        //option 1 create new ingredient
        alert.addAction(UIAlertAction(title: Strings.newIngredient, style: .default, handler: { _ in
            self.navigateToIngredientDetail(id: nil)
        }))
        
        //option 2 add substep
        alert.addAction(UIAlertAction(title: Strings.step, style: .default, handler: { _ in
            self.showSubstepsActionSheet(possibleSubsteps: possibleSubsteps)
        }))
        
        //cancel
        alert.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
            
        present(alert, animated: true)
    }
    
    /// shows a selection for different substeps and adds it to the current step
    private func showSubstepsActionSheet(possibleSubsteps: [Step]) {
        let actionSheet = UIAlertController(title: Strings.selectStep, message: nil, preferredStyle: .actionSheet)
        
        for possibleSubstep in possibleSubsteps {
            actionSheet.addAction(UIAlertAction(title: possibleSubstep.formattedName, style: .default, handler: { _ in
                var newSubstep = possibleSubstep
                newSubstep.superStepId = self.step.id
                
                if self.appData.update(newSubstep) {
                    self.updateList(animated: false)
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
}

private extension StepDetailViewController {
    
    /// navigate to an ingredient with a given id
    /// - Note: if id is nil it creates a new one
    private func navigateToIngredientDetail(id: Int?) {
        let newId = appData.newId(for: Ingredient.self)
        
        let ingredient = id == nil ? Ingredient(stepId: self.stepId, id: newId, name: "", amount: 0, type: .other) : appData.object(with: id!, of: Ingredient.self)!

        if id == nil {
            guard appData.insert(ingredient) else { return }
        }
        let vc = IngredientDetailViewController(ingredient: ingredient) { newValue in
            if self.appData.update(newValue) {
                DispatchQueue.main.async {
                    self.updateList(animated: false)
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Expanding Cells
private extension StepDetailViewController {
    
    // MARK: DatePicker
    
    private func collapseDatePicker() {
        if datePickerShown {
            
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems([snapshot.itemIdentifiers(inSection: .durationTemp).first(where: { !($0 is DetailItem) })!])
            self.dataSource.apply(snapshot, animatingDifferences: false)
            
            reloadDurationTempSection()

        }
    }
    
    private func expandDatePicker(animated: Bool) {
        if !datePickerShown {
            
            dataSource.apply(createUpdatedSnapshot(shouldShowDatePicker: true), animatingDifferences: animated)
            
            reloadDurationTempSection()
        }
    }
    
    
    // MARK: TempPicker
    
    private func collapseTempPicker() {
        if tempPickerShown {
            
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems([snapshot.itemIdentifiers(inSection: .durationTemp).last(where: { !($0 is DetailItem) })!])
            self.dataSource.apply(snapshot, animatingDifferences: false)
            
            reloadDurationTempSection()

        }
    }
    
    private func expandTempPicker(animated: Bool) {
        if !tempPickerShown {
            
            dataSource.apply(createUpdatedSnapshot(shouldShowTempPicker: true), animatingDifferences: animated)
            
            reloadDurationTempSection()
        }
    }
    
    private func reloadDurationTempSection() {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            
            snapshot.reloadSections([.durationTemp])
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
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
        
        // MARK: Creating Cells

        return StepDetailDataSource(tableView: tableView, step: Binding(get: { self.step }, set: { newStep in  self.step = newStep })) { (tableView, indexPath, item) -> UITableViewCell? in
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
                        cell.detailTextLabel?.textColor = self.datePickerShown ? .tintColor : .secondaryCellTextColor
                        return cell
                    } else {
                        //temp
                        let cell = dequeueAndSetupDetailCell(at: indexPath, withIdentifier: Strings.tempCell, with: detailItem)
                        cell.detailTextLabel?.textColor = self.tempPickerShown ? .tintColor : .secondaryCellTextColor
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
            } else if self.datePickerShown, indexPath.row == 1{
                return TimePickerCell(stepId: self.stepId, appData: self.appData, theme: self.theme, reuseIdentifier: Strings.timePickerCell)
            } else if self.tempPickerShown, indexPath.row > 1 {
                return TempPickerCell(temp: Binding(get: { self.step.temperature ?? Standarts.standardRoomTemperature}, set: { self.step.temperature = $0; self.updateList(animated: false) }), reuseIdentifier: Strings.tempPickerCell)
            }
            return CustomCell()
        }
    }
    
    // MARK: Snapshot
    
    /// creates the initial list
    private func applyInitialSnapshot(animated: Bool = true) {
        self.dataSource.apply(createInitialSnapshot(), animatingDifferences: animated)
    }
    
    private func updateList(animated: Bool = true) {
        self.dataSource.apply(createUpdatedSnapshot(), animatingDifferences: animated)
    }
    
    private func snapshotBase() -> NSDiffableDataSourceSnapshot<StepDetailSection, Item> {
        
        // textfieldItem
        let nameItem = TextFieldItem(text: step.name)
        
        // notesTextFieldItem
        let notesItem = TextFieldItem(text: step.notes)

        let ingredientItems = appData.ingredients(with: step.id).map{ IngredientItem(id: $0.id, name: $0.name, detailLabel: $0.detailLabel(for: step)) }
        let substepItems = appData.substeps(for: step.id).map { SubstepItem(id: $0.id, name: $0.formattedName, detailLabel: appData.totalFormattedMass(for: step.id) + " " + $0.formattedTemp(roomTemp: Standarts.standardRoomTemperature) )}
        let addIngredientItem = DetailItem(name: Strings.addIngredient)
        
        // create the snapshot
        var snapshot = NSDiffableDataSourceSnapshot<StepDetailSection, Item>() // create the snapshot
        snapshot.appendSections(StepDetailSection.allCases) //append sections
        
        // name Section
        snapshot.appendItems([nameItem], toSection: .name)
        
        // notes Seciton
        snapshot.appendItems([notesItem], toSection: .notes)
        
        // ingredients
        snapshot.appendItems(substepItems, toSection: .ingredients)
        snapshot.appendItems(ingredientItems, toSection: .ingredients)
        snapshot.appendItems([addIngredientItem], toSection: .ingredients)

        return snapshot
    }
    
    private func createUpdatedSnapshot(shouldShowDatePicker: Bool = false, shouldShowTempPicker: Bool = false) -> NSDiffableDataSourceSnapshot<StepDetailSection, Item> {
        var snapshot = snapshotBase()
        
        // durationTemp
        var items: [Item] = [durationItem]
        if datePickerShown || shouldShowDatePicker {
            items.append(Item())
        }
        
        items.append(tempItem)
        if tempPickerShown || shouldShowTempPicker {
            items.append(Item())
        }
        
        snapshot.appendItems(items, toSection: .durationTemp)
        

        
        return snapshot
    }
    
    /// detailItem for duration
    private var durationItem: DetailItem {
        DetailItem(name: Strings.duration, detailLabel: step.formattedDuration )
    }
    
    /// detailItem for temp
    private var tempItem: DetailItem {
        DetailItem(name: Strings.temperature, detailLabel: step.formattedTemp(roomTemp: Standarts.standardRoomTemperature))
    }
    
    private func createInitialSnapshot() -> NSDiffableDataSourceSnapshot<StepDetailSection, Item> {
        
        var snapshot = snapshotBase()
        
        // durationTemp
        snapshot.appendItems([durationItem, tempItem], toSection: .durationTemp)
        
        return snapshot
    }
    
}

fileprivate extension Ingredient {
    func detailLabel(for step: Step) -> String {
        self.formattedAmount + " " + (self.type == .bulkLiquid ? "\(BackAppData().temperature(for: self, roomTemp: Standarts.standardRoomTemperature))° C" : "")
    }
}

fileprivate class StepDetailDataSource: UITableViewDiffableDataSource<StepDetailSection, Item> {
    
    @Binding var step: Step
    
    private lazy var appData = BackAppData()
    
    init(tableView: UITableView, step: Binding<Step>,
         cellProvider: @escaping UITableViewDiffableDataSource<StepDetailSection, Item>.CellProvider) {
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
            
            //delete ingredient
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            
            apply(snapshot, animatingDifferences: true) {
                if let ingredient = self.appData.object(with: item.id, of: Ingredient.self) {
                    _ = self.appData.delete(ingredient)
                }
            }
        } else if item is SubstepItem {
            
            //delete substep
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            
            apply(snapshot, animatingDifferences: true) {
                if var substep = self.appData.object(with: item.id, of: Step.self) {
                    substep.superStepId = nil
                    _ = self.appData.update(substep)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self.itemIdentifier(for: indexPath) is IngredientItem || self.itemIdentifier(for: indexPath) is SubstepItem
    }

//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        self.itemIdentifier(for: indexPath) is IngredientItem
//    }
//
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard (itemIdentifier(for: sourceIndexPath) as? IngredientItem) != nil else { return }
//        guard (itemIdentifier(for: destinationIndexPath) as? IngredientItem) != nil else { return }
//
//        let ingredientToMove = step.ingredients.remove(at: sourceIndexPath.row)
//        step.ingredients.insert(ingredientToMove, at: destinationIndexPath.row)
//    }
}
