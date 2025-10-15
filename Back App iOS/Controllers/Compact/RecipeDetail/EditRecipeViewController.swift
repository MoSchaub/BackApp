// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeStrings
import BackAppCore

class EditRecipeViewController: BackAppVC {

    // MARK: Properties

    // class for managing table creation and updates
    private(set) lazy var dataSource = makeDataSource()

    // queue for performing image compression
    private lazy var compressionQueue = OperationQueue()

    // for picking images
    private var imagePickerController: UIImagePickerController?

    // id of the recipe for pulling the recipe from the database
    private let recipeId: Int64

    // recipe pulled from teh database, updates the database on set
    private var recipe: Recipe {
        get {
            self.appData.record(with: recipeId) ?? Recipe.example.recipe
        }
        set {
            if newValue != self.recipe {
                appData.update(newValue) { _ in
                    self.updateNavBar()
                    if !self.recipeChanged, self.creating {
                        self.recipeChanged = true
                    }
                }
            }
        }
    }

    // wether swipe delete action is in progress
    private lazy var singleRowDeleteMode = false

    // wether the recipe is freshly created
    private var creating: Bool

    // wether the recipe already has been changed
    private var recipeChanged: Bool = false

    // func for dissmissing after pressing delete button
    private var dismissDetail: (() -> ())?

    //initializer
    init(recipeId: Int64, creating: Bool, appData: BackAppData, dismissDetail: (() -> ())? = nil ) {
        self.creating = creating
        self.recipeId = recipeId
        self.dismissDetail = dismissDetail
        super.init(appData: appData)

        //because a the controller is presented in a nav controller
        self.navigationController?.presentationController?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }

    override func updateDataSource(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<RecipeDetailSection, Item>()
        snapshot.appendSections(RecipeDetailSection.allCases)
        snapshot.appendItems([recipe.nameItem()], toSection: .name)
        snapshot.appendItems([recipe.imageItem, recipe.infoStripItem(appData: appData)], toSection: .imageControlStrip)
        snapshot.appendItems([recipe.amountItem()], toSection: .times)
        snapshot.appendItems(recipe.stepItems(appData: appData), toSection: .steps)
        snapshot.appendItems([DetailItem(name: Strings.addStep, detailLabel: "")],toSection: .steps)
        snapshot.appendItems([recipe.infoItem], toSection: .info)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - NavigationBar

    /// share item to share the recipe as a file
    func shareItem() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
    }

    /// favourite item to add  the recipe to the favorites
    private func favouriteItem() -> UIBarButtonItem {
        UIBarButtonItem(image: UIImage(systemName: recipe.isFavorite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))
    }

    /// delete item; deletes the recipe and dissmisses
    private func deleteItem() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
    }

    override func setRightBarButtonItems() {
        if creating {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.dissmiss))]
        } else {
            if UITraitCollection.current.horizontalSizeClass == .regular { // ipad and large iphone landscape

                // fill navbar with buttons
                self.navigationItem.rightBarButtonItems = [shareItem(), favouriteItem(), deleteItem()]
            } else { // normal iphone format and small ipad

                // do default stuff
                super.setRightBarButtonItems()
            }
        }
    }

    override func setLeftBarButtonItems() {
        if creating {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        }
    }

    override func setupToolbar() {
        if !creating {
            self.setUpItemToolbar(item1: shareItem(), item2: favouriteItem(), item3: deleteItem(), openSettings: {
                let settingsViewController = SettingsViewController(appData: self.appData)
                let nav = UINavigationController(rootViewController: settingsViewController)
                if #available(iOS 15.0, *) {
                    nav.sheetPresentationController?.detents = [.medium(), .large()]
                }
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)
            })
        }
    }

    override func updateNavBarTitle() {
        self.title = self.recipe.formattedName
    }

    // MARK: - Cell Registration
    override func registerCells() {
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Strings.imageCell)
        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.stepCell)
        tableView.register(InfoStripCell.self, forCellReuseIdentifier: Strings.infoStripCell)
        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.infoCell)
    }

    override func attachPublishers() {
        super.attachPublishers()
        NotificationCenter.default.publisher(for: .editRecipeShouldUpdate)
            .sink { _ in
                self.updateDataSource(animated: false)
            }
            .store(in: &tokens)
        NotificationCenter.default.publisher(for: .horizontalSizeClassDidChange)
            .sink { _ in
                self.updateNavBar()
            }
            .store(in: &tokens)
        Standarts.standartsChangedPublisher.sink { _ in
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadSections([.steps])
            self.dataSource.apply(snapshot)
        }.store(in: &tokens)
    }

}

// MARK: - DataSource

private extension EditRecipeViewController {
    /// create the dataSource for this VC and provide the recipe and various update fuctions
    private func makeDataSource() -> EditRecipeDataSource {
        let dataSource = EditRecipeDataSource(tableView: self.tableView) { tableView, indexPath, item in
            if let textFieldItem = item as? TextFieldItem {

                //name text field
                return TextFieldCell(text: textFieldItem.text, placeholder: Strings.name, reuseIdentifier: Strings.nameCell, textChanded: { self.recipe.name = $0 })
            } else if let imageItem = item as? ImageItem {

                //imageCell
                return ImageCell(reuseIdentifier: Strings.imageCell, data: imageItem.imageData)
            } else if let amountItem = item as? AmountItem {

                //amount cell
                return AmountCell(text: amountItem.text, reuseIdentifier: Strings.amountCell) { timesText in
                    guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return self.recipe.timesText}
                    self.recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
                    return self.recipe.timesText
                }
            } else if item is InfoItem{

                //info cell
                return TextViewCell(textContent: Binding(get: { self.recipe.info}, set: { self.recipe.info = $0; self.updateInfo(indexPath: indexPath) }), placeholder: Strings.info, reuseIdentifier: Strings.infoCell, isEditable: true)
            } else if let infoStripItem = item as? InfoStripItem {

                //infostrip
                return InfoStripCell(infoStripItem: infoStripItem, reuseIdentifier: Strings.infoStripCell)
            } else if let stepItem = item as? StepItem {

                // steps
                return StepCell(vstack: stepItem.step.vstack(editing: self.isEditing), reuseIdentifier: Strings.stepCell)
            } else if let detailItem = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailCell {

                // add step cell
                cell.textLabel?.text = detailItem.text
                cell.accessoryType = .disclosureIndicator

                // gray out the text if editMode enabled
                if self.isEditing {
                    cell.textLabel?.textColor = UIColor.secondaryCellTextColor
                } else {
                    cell.textLabel?.textColor = UIColor.primaryCellTextColor
                }
                return cell
            }
            return UITableViewCell()
        }
        dataSource.defaultRowAnimation = .none
        dataSource.recipeId = self.recipe.id

        return dataSource
    }

    private func updateInfo(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

}

// MARK: - Reload Steps when entering editMode
extension EditRecipeViewController {

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if self.singleRowDeleteMode { return }
        reloadStepSection()
    }

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.singleRowDeleteMode = true;
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.singleRowDeleteMode = false;
    }

    private func reloadStepSection() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.steps])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


// MARK: - Show Alert when Cancel was pressed and recipe modified to prevent data loss

extension EditRecipeViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        handleCancelButtonPress()
    }

    ///Presents an alert if the user is creating a new recipe and presses cancel if he really wants to cancel to prevent data loss else just dissmisses
    private func handleCancelButtonPress() {
        if creating, recipeChanged {
            //show alert
            showAlert()
        } else {

            // make sure the textFieldObserver is stopped
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell, cell.textField.isEditing {
                cell.textField.endEditing(true)
            }
            appData.delete(recipe)
            dissmiss()
        }
    }

    private func showAlert() {
        let alertVC = UIAlertController(title: Strings.Alert_ActionCancel, message: Strings.CancelRecipeMessage, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionDelete, style: .destructive) {_ in
            alertVC.dismiss(animated: false)
            self.appData.delete(self.recipe)
            self.dissmiss()
        })

        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionSave, style: .default) {_ in
            alertVC.dismiss(animated: false)
            self.dissmiss()
        })

        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel) { _ in
            alertVC.dismiss(animated: true)
        })

        self.navigationController?.present(alertVC, animated: true )
    }
}

// MARK: helpers for navbarItems

private extension EditRecipeViewController {

    @objc private func favouriteRecipe(_ sender: UIBarButtonItem) {
        recipe.isFavorite.toggle()
    }

    @objc private func shareRecipeFile(sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [appData.exportRecipesToFile(recipes: [self.recipe])], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }

    @objc private func cancel() {
        handleCancelButtonPress()
    }

    @objc private func deletePressed(sender: UIBarButtonItem) {
        let sheet = UIAlertController(preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: Strings.Alert_ActionDelete, style: .destructive, handler: { _ in
            sheet.dismiss(animated: true) {
                if !self.creating {
                    self.appData.delete(self.recipe)
                    self.dismissDetail!()
                }
            }
        }))

        sheet.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: { (_) in
            sheet.dismiss(animated: true)
        }))

        sheet.popoverPresentationController?.barButtonItem = sender

        present(sheet, animated: true)
    }

    @objc private func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension EditRecipeViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard RecipeDetailSection.allCases[section] == .steps else { return nil }
        let steps = appData.steps(with: recipe.id!)
        return customHeader(enabled: !steps.isEmpty, title: Strings.steps, frame: tableView.frame)
    }

}

// MARK: - Cell Selection

extension EditRecipeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            if item is ImageItem {
                imageTapped(sender: indexPath)
            } else if let stepItem = item as? StepItem {
                showStepDetail(id: Int64(stepItem.id))
            } else if let detailItem = item as? DetailItem {
                if detailItem.text == Strings.addStep {
                    showStepDetail(id: nil)
                }
            }
        }
    }
}

private extension EditRecipeViewController {
    private func imageTapped(sender: IndexPath) {
        if imagePickerController != nil {
            imagePickerController?.delegate = nil
            imagePickerController = nil
        }
        imagePickerController = UIImagePickerController()

        let alert = UIAlertController(title: Strings.image_alert_title, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: Strings.take_picture, style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, for: .camera)
            }))
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: Strings.select_image, style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, for: .photoLibrary)
            }))
        }

        alert.addAction(UIAlertAction(title: Strings.Alert_ActionRemove, style: .destructive, handler: { (_) in
            self.changeRecipeImage(to: nil)
        }))

        alert.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.cellForRow(at: indexPath)?.isSelected = false
            }
        }))

        alert.popoverPresentationController?.sourceView = tableView.cellForRow(at: sender)

        present(alert, animated: true)

    }

    // changes the image of an recipe
    private func changeRecipeImage(to image: UIImage?) {
        compressionQueue.cancelAllOperations()
        compressionQueue.addOperation {
            do {
                self.recipe.imageData  = try image?.fixOrientation().compressedDataToKb(value: 100)

                self.appData.update(self.recipe) { _ in DispatchQueue.main.async { self.updateDataSource(animated: false) }}
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func showStepDetail(id: Int64?) {
        var step = id == nil ? Step(recipeId: self.recipe.id!, number: 0) : appData.record(with: id!, of: Step.self)!

        // insert the new step
        if id == nil {

            step.number = (appData.notSubsteps(for: self.recipeId).last?.number ?? -1) + 1

            // insert it
            appData.insert(&step)

            self.recipeChanged = true
        }

        let stepDetailVC = StepDetailViewController(stepId: step.id!, appData: appData)

        //navigate to the conroller
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
}

extension EditRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentImagePicker(controller: UIImagePickerController, for source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source

        present(controller, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { //cant be private
        picker.dismiss(animated: true, completion: {
            self.terminate(picker)
        })
    }

    private func terminate(_ picker: UIImagePickerController) {
        picker.delegate = nil
        imagePickerController = nil
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // can't be private
        if let uiImage = info[.originalImage] as? UIImage {
            changeRecipeImage(to: uiImage)

            picker.dismiss(animated: true) {
                self.terminate(picker)
            }
        } else {
            imagePickerControllerDidCancel(picker)
        }
    }
}

