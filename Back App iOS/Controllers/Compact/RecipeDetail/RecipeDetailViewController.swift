//
//  RecipeDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 25.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeUIFoundation
import BakingRecipeStrings
import BakingRecipeCells
import BackAppCore

class RecipeDetailViewController: UITableViewController {
    
    // MARK: Properties
    
    // class for managing table creation and updates
    private lazy var dataSource = makeDataSource()
    
    //interface object for the database
    private var appData: BackAppData
    
    // for picking images
    private var imagePickerController: UIImagePickerController?
    
    // id of the recipe for pulling the recipe from the database
    private let recipeId: Int64
    
    // recipe pulled from the database updates the database on set
    private var recipe: Recipe {
        get {
            self.appData.record(with: recipeId) ?? Recipe.example.recipe
        }
        set {
            if newValue != self.recipe {
                appData.update(newValue) { _ in
                    self.setUpNavigationBar()
                    if !self.recipeChanged, self.creating{
                        self.recipeChanged = true
                    }
                }
            }
        }
    }

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
        self.appData = appData
        self.dismissDetail = dismissDetail
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
}

// MARK: - Update and Load View

extension RecipeDetailViewController {
    override func loadView() {
        super.loadView()
        setUpNavigationBar()
        self.title = self.recipe.formattedName
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        self.tableView.separatorStyle = .none
        
        //because a the controller is presented in a nav controller
        self.navigationController?.presentationController?.delegate = self
        self.splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.update(animated: false)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        self.setUpNavigationBar()
    }
    
}

extension RecipeDetailViewController: UISplitViewControllerDelegate {
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        self.setUpNavigationBar()
    }
    
    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        self.setUpNavigationBar()
    }
}

// MARK: - Show Alert when Cancel was pressed and recipe modified to prevent data loss

extension RecipeDetailViewController: UIAdaptivePresentationControllerDelegate {
    
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
            if appData.delete(recipe) {
                dissmiss()
            }
        }
    }
    
    private func showAlert() {
        let alertVC = UIAlertController(title: Strings.Alert_ActionCancel, message: Strings.CancelRecipeMessage, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionDelete, style: .destructive) {_ in
            alertVC.dismiss(animated: false)
            if self.appData.delete(self.recipe) {
                self.dissmiss()
            }
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

// MARK: - DataSource

private extension RecipeDetailViewController {
    /// create the dataSource for this VC and provide the recipe and various update fuctions
    private func makeDataSource() -> RecipeDetailDataSource {
        RecipeDetailDataSource(
            recipe: Binding(get: {
                return self.recipe
            }, set: { newValue in
                DispatchQueue.global(qos: .userInteractive).async {
                    self.recipe = newValue
                }
            }),
            creating: creating, appData: appData, tableView: tableView,
            nameChanged: { newName in
                self.recipe.name = newName
            },
            formatAmount: { timesText in
                guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return self.recipe.timesText}
                self.recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
                return self.recipe.timesText
            },
            updateInfo: { newInfo in
                    self.recipe.info = newInfo
            }
        )
    }
}

// MARK: - NavigationBar

private extension RecipeDetailViewController {
    private func setUpNavigationBar() {
        
        if creating {
            DispatchQueue.main.async {
                //set the items
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.dissmiss))]
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
                
            }
        } else {
            
            //create the items
            let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavorite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))
            let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
            let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
            
            DispatchQueue.main.async {
                if UITraitCollection.current.horizontalSizeClass == .regular {
                    //navbar f
                    self.navigationItem.rightBarButtonItems = [favourite, delete]
                    self.navigationItem.leftBarButtonItem = share
                    
                    self.navigationController?.setToolbarHidden(true, animated: true)
                } else {
                    
                    self.navigationItem.rightBarButtonItems = []
                    self.navigationItem.leftBarButtonItems = []
                    
                    // flexible space item
                    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    
                    //create the toolbar
                    self.navigationController?.setToolbarHidden(false, animated: true)
                    self.setToolbarItems([share, flexible, favourite, flexible, delete], animated: true)
                }
            }
        }
        DispatchQueue.main.async {
            self.title = self.recipe.formattedName
        }
            
    }
    
    // MARK: Cell registration
    
    private func registerCells() {
        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
        tableView.register(ImageCell.self, forCellReuseIdentifier: Strings.imageCell)
        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.stepCell)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.textFieldCell)
        tableView.register(InfoStripCell.self, forCellReuseIdentifier: Strings.infoStripCell)
        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.plainCell)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.infoCell)
    }
}

// MARK: helpers for navbarItems

private extension RecipeDetailViewController {
    
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
                if !self.creating, self.appData.delete(self.recipe) {
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
        NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
    }
}


extension RecipeDetailViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard RecipeDetailSection.allCases[section] == .steps else { return nil }
        let steps = appData.steps(with: recipe.id!)
        return customHeader(enabled: !steps.isEmpty, title: Strings.steps, frame: tableView.frame)
    }

    
}

// MARK: - Cell Selection

extension RecipeDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            if item is ImageItem {
                imageTapped(sender: indexPath)
            } else if let stepItem = item as? StepItem {
                showStepDetail(id: Int64(stepItem.id))
            } else if let detailItem = item as? DetailItem {
                if detailItem.text == Strings.startRecipe {
                    startRecipe()
                } else if detailItem.text == Strings.addStep {
                    showStepDetail(id: nil)
                }
            }
        }
    }
}

private extension RecipeDetailViewController {
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
        self.recipe.imageData = image?.jpegData(compressionQuality: 0.3)
        self.appData.update(recipe) { _ in self.dataSource.update(animated: false) }
    }
    
    private func showStepDetail(id: Int64?) {
        var step = id == nil ? Step(recipeId: self.recipe.id!, number: 0) : appData.record(with: id!, of: Step.self)!

        // insert the new step
        if id == nil {
            
            step.number = (appData.notSubsteps(for: self.recipeId).last?.number ?? -1) + 1

            // insert it
            appData.save(&step)
                
            self.recipeChanged = true
        }
        
        let stepDetailVC = StepDetailViewController(stepId: step.id!, appData: appData)
        
        //navigate to the conroller
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
    
    private func startRecipe() {
        let recipeBinding = Binding(get: {
            return self.recipe
        }) { (newValue) in
            self.recipe = newValue
        }
        let scheduleForm = ScheduleFormViewController(recipe: recipeBinding, appData: appData)

        navigationController?.pushViewController(scheduleForm, animated: true)
    }
}

extension RecipeDetailViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = dataSource.itemIdentifier(for: indexPath) as? InfoItem {
            return 80
        } else if let _ = dataSource.itemIdentifier(for: indexPath) as? ImageItem {
            return 250
        }
        return UITableView.automaticDimension
    }
}

extension RecipeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
