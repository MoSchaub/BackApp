//
//  RecipeDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 25.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import SwiftUI
import BakingRecipe

enum RecipeDetailSection: CaseIterable {
    case name, image, times, info, controlStrip, steps
}

class Item: Hashable {
    
    var id: UUID
    
    init(id: UUID = UUID()) {
        self.id = id
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


class TextFieldItem: TextItem {
    
    override init(id: UUID = UUID(), text: String) {
        super.init(id: id, text: text)
    }
}

class ImageItem: Item {
    var imageData: Data?
    
    init(id: UUID = UUID(), imageData: Data?) {
        self.imageData = imageData
        super.init(id: id)
    }
}

class AmountItem: TextItem {
    
    override init(id: UUID = UUID(), text: String) {
        super.init(id: id, text: text)
    }
}

class StepItem: Item {
    var step: Step
    
    init(id: UUID = UUID(), step: Step) {
        self.step = step
        super.init(id: id)
    }
}

class InfoStripItem: Item {
    var stepCount: Int
    var minuteCount: Int
    var ingredientCount: Int
    
    init(stepCount: Int, minuteCount: Int, ingredientCount: Int) {
        self.stepCount = stepCount
        self.minuteCount = minuteCount
        self.ingredientCount = ingredientCount
        super.init()
    }
}

class InfoItem: TextItem {
}

class RecipeDetailDataSource: UITableViewDiffableDataSource<RecipeDetailSection, Item> {
    
    @Binding var recipe: Recipe
    let creating: Bool
    
    init(recipe: Binding<Recipe>, creating: Bool, tableView: UITableView, nameChanged: @escaping (String) -> (), formatAmount: @escaping (String) -> (String)) {
        self._recipe = recipe
        self.creating = creating
        super.init(tableView: tableView) { (_, indexPath, item) -> UITableViewCell? in
            if let _ = item as? TextFieldItem, let cell = tableView.dequeueReusableCell(withIdentifier: "textField", for: indexPath) as? TextFieldTableViewCell {
                cell.textField.text = recipe.wrappedValue.name
                cell.textField.placeholder = NSLocalizedString("name", comment: "")
                cell.selectionStyle = .none
                cell.textChanged = nameChanged
                return cell
            } else if let imageItem = item as? ImageItem, let imageCell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageTableViewCell {
                imageCell.setup(imageData: imageItem.imageData)
                return imageCell
            } else if let _ = item as? AmountItem, let amountCell = tableView.dequeueReusableCell(withIdentifier: "times", for: indexPath) as? AmountTableViewCell{
                amountCell.setUp(with: recipe.wrappedValue.timesText, format: formatAmount)
                return amountCell
            } else if let infoItem = item as? InfoItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath)
                cell.textLabel?.text = infoItem.text
                return cell
            } else if indexPath.section == 4 {
                if let stripItem = item as? InfoStripItem, let infoStripCell = tableView.dequeueReusableCell(withIdentifier: "infoStrip", for: indexPath) as? InfoStripTableViewCell {
                    infoStripCell.setUpCell(for: stripItem)
                    return infoStripCell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath)
                    cell.textLabel?.text = NSLocalizedString("startRecipe", comment: "")
                    cell.accessoryType = .disclosureIndicator
                    cell.isUserInteractionEnabled = !creating
                    
                    return cell
                }
            } else if let stepItem = item as? StepItem {
                let stepCell = StepTableViewCell(style: .default, reuseIdentifier: "step")
                stepCell.setUpCell(for: stepItem.step)
                return stepCell
            }
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("name", comment: "")
        case 1: return NSLocalizedString("bild", comment: "")
        case 2: return NSLocalizedString("anzahl", comment: "")
        case 3: return "info"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        (itemIdentifier(for: indexPath) as? StepItem) != nil
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        itemIdentifier(for: indexPath) as? StepItem != nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let item = itemIdentifier(for: indexPath) as? StepItem {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                self.deleteStep(item.id)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row > recipe.steps.count else { reset(); return }
        guard destinationIndexPath.section == 0 else { reset(); return}
        guard recipe.steps.count > sourceIndexPath.row else { reset(); return }
        recipe.steps.move(fromOffsets: IndexSet(arrayLiteral: sourceIndexPath.row), toOffset: destinationIndexPath.row)
        reloadSteps()
    }
    
}

fileprivate extension Recipe {
    mutating func nameItem() -> TextFieldItem {
        TextFieldItem(text: name)
    }
    
    var imageItem: ImageItem {
        ImageItem(imageData: imageString)
    }
    
    mutating func amountItem() -> AmountItem {
        AmountItem(text: timesText)
    }
    
    var infoItem: InfoItem {
        InfoItem(text: self.info)
    }
    
    func controlStripItems(creating: Bool) -> [Item] {
        creating ? [InfoStripItem(stepCount: steps.count, minuteCount: totalTime, ingredientCount: numberOfIngredients)] : [InfoStripItem(stepCount: steps.count, minuteCount: totalTime, ingredientCount: numberOfIngredients), Item()]
    }
    
    var stepItems: [StepItem] {
        steps.map({ StepItem(id: $0.id, step: $0)})
    }
    
}

extension RecipeDetailDataSource {
    func update(animated: Bool) {
        var snapshot = self.snapshot()
        snapshot.appendSections(RecipeDetailSection.allCases)
        snapshot.appendItems([recipe.nameItem()], toSection: .name)
        snapshot.appendItems([recipe.imageItem], toSection: .image)
        snapshot.appendItems([recipe.amountItem()], toSection: .times)
        snapshot.appendItems([recipe.infoItem], toSection: .info)
        snapshot.appendItems(recipe.controlStripItems(creating: self.creating), toSection: .controlStrip)
        snapshot.appendItems(recipe.stepItems, toSection: .steps)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func reloadSteps() {
        var snapshot = self.snapshot()
        snapshot.reloadSections([.steps])
        self.apply(snapshot)
    }
    
    private func reset() {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        self.update(animated: false)
    }
    
    private func deleteStep(_ id: UUID) {
        if let index = recipe.steps.firstIndex(where: { $0.id == id }) {
            self.recipe.steps.remove(at: index)
        }
    }
}

class RecipeDetailViewController: UITableViewController {
    
    typealias SaveRecipe = ((Recipe) -> ())
    
    private lazy var dataSource = makeDataSource()
    
    private var recipe: Recipe {
        didSet {
            setUpNavigationBar()
            update()
        }
    }
    private var creating: Bool
    private var saveRecipe: SaveRecipe
    
    private func update() {
        if !creating {
            saveRecipe(self.recipe)
        }
    }
    
    init(recipe: Recipe, creating: Bool, saveRecipe: @escaping SaveRecipe) {
        self.recipe = recipe
        self.creating = creating
        self.saveRecipe = saveRecipe
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecipeDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setUpNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.update(animated: false)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

}

extension RecipeDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

private extension RecipeDetailViewController {
    private func makeDataSource() -> RecipeDetailDataSource {
        RecipeDetailDataSource(recipe: Binding(get: {
            return self.recipe
        }, set: { newValue in
            self.recipe = newValue
        }), creating: creating, tableView: tableView, nameChanged: { name in
            self.recipe.name = name
        }, formatAmount: { timesText in
            guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "1 stk" }
            self.recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
            return self.recipe.timesText
        })
    }
}

private extension RecipeDetailViewController {
    private func setUpNavigationBar() {
        if creating {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveRecipeWrapper))]
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        } else {
            let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavourite ? "star" : "star.fill"), style: .plain, target: self, action: #selector(favouriteRecipe))
            let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
            navigationItem.rightBarButtonItems = [favourite,share ]
        }
        title = recipe.formattedName
    }
    
    private func registerCells() {
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "detail")
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "image")
        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: "step")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textField")
        tableView.register(InfoStripTableViewCell.self, forCellReuseIdentifier: "infoStrip")
        tableView.register(AmountTableViewCell.self, forCellReuseIdentifier: "times")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
    }
}

private extension RecipeDetailViewController {
    
    @objc private func favouriteRecipe(_ sender: UIBarButtonItem) {
        recipe.isFavourite.toggle()
    }
    
    @objc private func shareRecipeFile() {
        let vc = UIActivityViewController(activityItems: [recipe.createFile()], applicationActivities: nil)
        
        present(vc, animated: true)
    }
    
    @objc private func saveRecipeWrapper() {
        if creating {
            saveRecipe(self.recipe)
            dissmiss()
        }
    }
    
    @objc private func cancel() {
        dissmiss()
    }
    
    private func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

import LBTATools

extension RecipeDetailViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 5 else { return nil }
        let hostingController = UIHostingController(rootView: HStack {
            Text("Schritte")
            Spacer()
            Button(action: {
                self.isEditing.toggle()
            }) {
                Text(isEditing ? "Fertig" : "Bearbeiten")
            }
        }
        .padding(.horizontal)
        )
//        view.addSubview(hostingController.view)
//        hostingController.view.fillSuperview()
        return hostingController.view
    }
}

private extension Recipe {
    func createFile() -> URL {
        let url = getDocumentsDirectory().appendingPathComponent("\(self.formattedName).bakingAppRecipe")
        DispatchQueue.global(qos: .userInitiated).async {
            if let encoded = try? JSONEncoder().encode(self.neutralizedForExport()) {
                do {
                    try encoded.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
        return url
    }
}
    
//    // MARK: - Properties
//
//    private var imagePickerController: UIImagePickerController?
//
//    var recipe: Recipe! {
//        willSet {
//            if newValue != nil {
//                recipeStore.update(recipe: newValue!)
//                title = newValue.formattedName
//            }
//        }
//        didSet {
//            if recipe != nil {
//                addNavigationBarItems()
//            }
//        }
//    }
//    var recipeStore = RecipeStore()
//    var creating = false
//    var saveRecipe: ((Recipe) -> Void)?
//
//    var cancelling = false
//
//    // MARK: - Startup functions
//
//    override func loadView() {
//        super.loadView()
//        registerCells()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addNavigationBarItems()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.recipe = recipeStore.recipes.first(where: { recipe?.id == $0.id }) ?? Recipe(name: "", brotValues: [])
//        tableView.reloadData()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if !cancelling {
//            recipeStore.save(recipe: recipe)
//        }
//    }
//
//    // MARK: - NavigaitonBarItems
//
//    private func addNavigationBarItems() {
//        if creating {
//            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveRecipeWrapper))]
//            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
//        } else {
//            let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavourite ? "star" : "star.fill"), style: .plain, target: self, action: #selector(favouriteRecipe))
//            let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
//            navigationItem.rightBarButtonItems = [favourite,share ]
//        }
//    }
//    @objc private func shareRecipeFile() {
//        let vc = UIActivityViewController(activityItems: [self.createRecipeFile()], applicationActivities: nil)
//
//        present(vc,animated: true)
//    }
//
//
//    private func createRecipeFile() -> URL {
//        let url = getDocumentsDirectory().appendingPathComponent("\(recipe.formattedName).bakingAppRecipe")
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let encoded = try? JSONEncoder().encode(self.recipe.neutralizedForExport()) {
//                do {
//                    try encoded.write(to: url)
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        return url
//    }
//
//    @objc private func favouriteRecipe() {
//        recipe.isFavourite.toggle()
//    }
//
//    @objc private func cancel() {
//        if let index = recipeStore.recipes.firstIndex(of: recipe) {
//            recipeStore.deleteRecipe(at: index)
//        }
//        cancelling = true
//        dissmiss()
//    }
//
//    private func dissmiss() {
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
//
//    @objc private func saveRecipeWrapper() {
//        if let saveRecipe = saveRecipe, creating {
//            saveRecipe(recipe)
//            dissmiss()
//        }
//    }
//
//    // MARK: - Sections and rows
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 5
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0: return 1
//        case 1: return 1
//        case 2: return creating ? 1 : 2
//        case 3: return (recipe?.steps.count ?? 0) + 1
//        case 4: return 1
//        default: return 0
//        }
//    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 3 {
//            let frame = tableView.frame
//
//            let editButton = UIButton(frame: CGRect(x: frame.size.width - 60, y: 10, width: 50, height: 30))
//            editButton.setAttributedTitle(attributedTitleForEditButton(), for: .normal)
//            editButton.addTarget(self, action: #selector(toggleEditMode(sender:)), for: .touchDown)
//
//            let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 30))
//            let attributes = [
//                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote),
//                .foregroundColor : UIColor.secondaryLabel,
//            ]
//            titleLabel.attributedText = NSAttributedString(string: "Schritte".uppercased(), attributes: attributes)
//
//            let stackView = UIStackView(frame: CGRect(x: 5, y: 0, width: frame.size.width - 10, height: frame.size.height))
//            stackView.addArrangedSubview(titleLabel)
//            stackView.addArrangedSubview(editButton)
//
//            return stackView
//        } else { return nil }
//    }
//
//    private func attributedTitleForEditButton() -> NSAttributedString {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font : UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: .current),
//            .foregroundColor : UIColor.link
//        ]
//        let titleString = isEditing ? "Fertig" : "Bearbeiten"
//        return NSAttributedString(string: titleString, attributes: attributes)
//    }
//
//    @objc private func toggleEditMode(sender: UIButton) {
//        setEditing(!isEditing, animated: true)
//        sender.setAttributedTitle(attributedTitleForEditButton(), for: .normal)
//    }
//
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0: return NSLocalizedString("name", comment: "")
//        case 1: return NSLocalizedString("bild", comment: "")
//        case 4: return NSLocalizedString("anzahl", comment: "")
//        default: return nil
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 1: return 200
//        case 3:
//            if indexPath.row == recipe.steps.count {
//                return 40
//            } else {
//                return CGFloat(55 + recipe.steps[indexPath.row].ingredients.count * 18 + recipe.steps[indexPath.row].subSteps.count * 18 + (recipe.steps[indexPath.row].notes.isEmpty ? 0 : 36))
//            }
//        default: return 40
//        }
//    }
//
//    // MARK: - Cells
//
//    private func registerCells() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
//        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "image")
//        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: "step")
//        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textField")
//        tableView.register(InfoStripTableViewCell.self, forCellReuseIdentifier: "infoStrip")
//        tableView.register(AmountTableViewCell.self, forCellReuseIdentifier: "times")
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let section = indexPath.section
//        let row = indexPath.row
//        switch section {
//        case 0: return makeTextFieldCell()
//        case 1: return makeImageViewCell()
//        case 2:
//            if row == 1 && !creating {
//                return makeStartRecipeCell()
//            } else {
//                return makeInfoStripCell() //InfoStrip
//            }
//        case 3:
//            if indexPath.row == recipe.steps.count {
//                return makeNewStepCell()
//            } else {
//                return makeStepCell(forRowAt: indexPath)
//            }
//        case 4: return makeTimesCell()
//
//        default: return UITableViewCell()
//        }
//    }
//
//
//    private func makeTextFieldCell() -> TextFieldTableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "textField") as! TextFieldTableViewCell
//        cell.textField.text = recipe.name
//        cell.textField.placeholder = NSLocalizedString("name", comment: "")
//        cell.selectionStyle = .none
//        cell.textChanged = { name in
//            self.recipe.name = name
//        }
//        return cell
//    }
//
//    private func makeImageViewCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "image") as! ImageTableViewCell
//        cell.setImage(fromData: recipe.imageString, placeholder: Images.largePhoto)
//
//        let upIconView = UIImageView(image: UIImage(systemName: "chevron.up"))
//        upIconView.tintColor = .tertiaryLabel
//        cell.accessoryView = upIconView
//
//        return cell
//    }
//
//
//
//    private func makeInfoStripCell() -> InfoStripTableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "infoStrip") as! InfoStripTableViewCell
//        cell.setUpCell(for: recipe)
//
//        return cell
//    }
//
//    private func makeStartRecipeCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "plain")!
//        cell.textLabel?.text = NSLocalizedString("startRecipe", comment: "")
//        cell.accessoryType = .disclosureIndicator
//
//        return cell
//    }
//
//    private func makeStepCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = StepTableViewCell(style: .default, reuseIdentifier: "step")
//        if recipe.steps.count > indexPath.row {
//            cell.setUpCell(for: recipe.steps[indexPath.row], recipe: recipe, roomTemp: recipeStore.roomTemperature)
//        }
//
//        return cell
//    }
//
//    private func makeNewStepCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "plain")!
//        cell.textLabel?.text = NSLocalizedString("addStep", comment: "")
//        cell.accessoryType = .disclosureIndicator
//
//        return cell
//    }
//
//    private func makeTimesCell() -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "times") as! AmountTableViewCell
//        cell.setUp(with: recipe, format: format)
//        return cell
//    }
//
//    private func format(timesText: String) -> String {
//        guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "1 stk" }
//        recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
//        return recipe.timesText
//    }
//
//    // MARK: - Editing
//
//    // conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        indexPath.section == 3 && indexPath.row < recipe.steps.count ? true : false
//    }
//
//    //editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete, indexPath.section == 3, let recipe = recipe, recipe.steps.count > indexPath.row {
//            // Delete the row from the data source
//            self.recipe!.steps.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard recipe != nil else { return }
//        guard destinationIndexPath.section == 3 else { tableView.reloadData(); return }
//        guard destinationIndexPath.row < recipe.steps.count else { tableView.reloadData(); return }
//        guard sourceIndexPath.row < recipe!.steps.count else { tableView.reloadData(); return }
//        let movedObject = recipe!.steps[sourceIndexPath.row]
//        recipe!.steps.remove(at: sourceIndexPath.row)
//        recipe!.steps.insert(movedObject, at: destinationIndexPath.row)
//    }
//
//    // conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        indexPath.section == 3 ? true : false
//    }
//
//    // MARK: - Navigation and Selection
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch indexPath.section {
//        case 1: navigateToImagePicker()
//        case 2:
//            if indexPath.row == 1 {
//                navigateToScheduleView()
//            }
//        case 3:
//            if indexPath.row == recipe.steps.count {
//                navigateToAddStepView()
//            } else {
//                navigateToStepDetail(at: indexPath)
//            }
//        default: let _ = "test"
//        }
//    }
//
//
//
//    private func navigateToScheduleView() {
//        let recipeBinding = Binding(get: {
//            return self.recipe!
//        }) { (newValue) in
//            self.recipe = newValue
//        }
//        let scheduleForm = ScheduleForm(recipe: recipeBinding, roomTemp: recipeStore.roomTemperature)
//        let vc = UIHostingController(rootView: scheduleForm)
//
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    private func navigateToAddStepView() {
//        let stepDetailVC = StepDetailViewController()
//        stepDetailVC.recipeStore = recipeStore
//        stepDetailVC.recipe = recipe
//        stepDetailVC.step = Step(name: "", time: 60)
//        stepDetailVC.creating = true
//        stepDetailVC.saveStep = saveStep
//
//        navigationController?.pushViewController(stepDetailVC, animated: true)
//    }
//
//    private func saveStep(step: Step, recipe: Recipe){
//        recipeStore.save(step: step, to: recipe)
//        tableView.reloadData()
//    }
//
//    private func navigateToStepDetail(at indexPath: IndexPath) {
//        recipeStore = RecipeStore()
//        recipeStore.save(recipe: recipe)
//        let stepDetailVC = StepDetailViewController()
//        stepDetailVC.recipeStore = recipeStore
//        stepDetailVC.recipe = recipe
//        stepDetailVC.step = recipe.steps[indexPath.row]
//
//        navigationController?.pushViewController(stepDetailVC, animated: true)
//    }
//
//    private func presentImagePicker(controller: UIImagePickerController, for source: UIImagePickerController.SourceType) {
//        controller.delegate = self
//        controller.sourceType = source
//
//        present(controller, animated: true)
//    }
//
//    private func navigateToImagePicker() {
//        if imagePickerController != nil {
//            imagePickerController?.delegate = nil
//            imagePickerController = nil
//        }
//        imagePickerController = UIImagePickerController()
//
//        let alert = UIAlertController(title: "Tesnt", message: nil, preferredStyle: .actionSheet)
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alert.addAction(UIAlertAction(title: "aufnehmen", style: .default, handler: { (_) in
//                self.presentImagePicker(controller: self.imagePickerController!, for: .camera)
//            }))
//        }
//
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            alert.addAction(UIAlertAction(title: "auswählen", style: .default, handler: { (_) in
//                self.presentImagePicker(controller: self.imagePickerController!, for: .photoLibrary)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Bild entfernen", style: .destructive, handler: { (_) in
//            self.recipe.imageString = nil
//            self.tableView.reloadData()
//        }))
//        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (_) in
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                self.tableView.cellForRow(at: indexPath)?.isSelected = false
//            }
//        }))
//
//        present(alert, animated: true)
//
//    }
//
//}
//
//// MARK: - ImagePicker
//
//extension RecipeDetailViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { //cant be private
//        picker.dismiss(animated: true, completion: {
//            self.terminate(picker)
//        })
//    }
//
//    private func terminate(_ picker: UIImagePickerController) {
//        picker.delegate = nil
//        imagePickerController = nil
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // can't be private
//        if let uiImage = info[.originalImage] as? UIImage {
//            recipe.imageString = uiImage.jpegData(compressionQuality: 0.3)
//            tableView.reloadData()
//
//            picker.dismiss(animated: true) {
//                self.terminate(picker)
//            }
//        } else {
//            imagePickerControllerDidCancel(picker)
//        }
//    }
//
//}
