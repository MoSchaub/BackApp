////
////  RecipeDetailViewController.swift
////  Back App iOS
////
////  Created by Moritz Schaub on 25.06.20.
////  Copyright © 2020 Moritz Schaub. All rights reserved.
////
//
//import SwiftUI
//import BakingRecipeFoundation
//import BakingRecipeUIFoundation
//import BakingRecipeItems
//import BakingRecipeStrings
//import BakingRecipeSections
//import BakingRecipeCells
//
//class RecipeDetailViewController: UITableViewController {
//    
//    typealias SaveRecipe = ((Recipe) -> ())
//    typealias DeleteRecipe = ((Recipe) -> Bool)
//    
//    private lazy var dataSource = makeDataSource()
//    
//    private var imagePickerController: UIImagePickerController?
//    
//    private var recipe: Recipe {
//        didSet {
//            DispatchQueue.global(qos: .utility).async {
//                if oldValue != self.recipe {
//                    if oldValue.formattedName != self.recipe.formattedName {
//                        self.setUpNavigationBar()
//                    }
//                    if oldValue.isFavourite != self.recipe.isFavourite {
//                        self.setUpNavigationBar()
//                    }
//                    if !self.creating, oldValue != self.recipe {
//                        self.saveRecipe(self.recipe)
//                    } else if !self.recipeChanged, self.creating{
//                        self.recipeChanged = true
//                    }
//                }
//            }
//        }
//    }
//    private var creating: Bool
//    private var recipeChanged: Bool = false
//    private var saveRecipe: SaveRecipe
//    private var deleteRecipe: DeleteRecipe
//    
//    init(recipe: Recipe, creating: Bool, saveRecipe: @escaping SaveRecipe, deleteRecipe: @escaping DeleteRecipe) {
//        self.recipe = recipe
//        self.creating = creating
//        self.saveRecipe = saveRecipe
//        self.deleteRecipe = deleteRecipe
//        super.init(style: .insetGrouped)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError(Strings.init_coder_not_implemented)
//    }
//}
//
//extension RecipeDetailViewController {
//    override func loadView() {
//        super.loadView()
//        setUpNavigationBar()
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        registerCells()
//        self.tableView.separatorStyle = .none
//        
//        //because a the controller is presented in a nav controller
//        self.navigationController?.presentationController?.delegate = self
//        self.splitViewController?.delegate = self
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        dataSource.update(animated: false)
//        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 250
//    }
//    
//}
//
//extension RecipeDetailViewController: UISplitViewControllerDelegate {
//    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
//        self.setUpNavigationBar()
//    }
//    
//    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
//        self.setUpNavigationBar()
//    }
//}
//
//// MARK: - Show Alert when Cancel was pressed and recipe modified to prevent data loss
//
//extension RecipeDetailViewController: UIAdaptivePresentationControllerDelegate {
//    
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        handleCancelButtonPress()
//    }
//    
//    ///Presents an alert if the user is creating a new recipe and presses cancel if he really wants to cancel to prevent data loss else just dissmisses
//    private func handleCancelButtonPress() {
//        if creating, recipeChanged {
//            //show alert
//            showAlert()
//        } else {
//            dissmiss()
//        }
//    }
//    
//    private func showAlert() {
//        let alertVC = UIAlertController(title: Strings.Alert_ActionCancel, message: Strings.CancelRecipeMessage, preferredStyle: .alert)
//        
//        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionDelete, style: .destructive) {_ in
//            alertVC.dismiss(animated: false)
//            self.dissmiss()
//        })
//        
//        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionSave, style: .default) {_ in
//            alertVC.dismiss(animated: false)
//            self.saveRecipeWrapper()
//        })
//        
//        alertVC.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel) { _ in
//            alertVC.dismiss(animated: true)
//        })
//        
//        self.navigationController?.present(alertVC, animated: true )
//    }
//    
//}
//
//
//
//private extension RecipeDetailViewController {
//    private func makeDataSource() -> RecipeDetailDataSource {
//        RecipeDetailDataSource(recipe: Binding(get: {
//            return self.recipe
//        }, set: { newValue in
//            self.recipe = newValue
//        }), creating: creating, tableView: tableView, nameChanged: { name in
//            self.recipe.name = name
//        }, formatAmount: { timesText in
//            guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return self.recipe.timesText}
//            self.recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
//            return self.recipe.timesText
//        }, updateInfo: { info in
//            self.recipe.info = info
//        })
//    }
//}
//
//private extension RecipeDetailViewController {
//    private func setUpNavigationBar() {
//        
//        if creating {
//            DispatchQueue.main.async {
//                //set the items
//                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveRecipeWrapper))]
//                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
//                
//            }
//        } else {
//            
//            //create the items
//            let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavourite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))
//            let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
//            let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
//            
//            DispatchQueue.main.async {
//                if UITraitCollection.current.horizontalSizeClass == .regular {
//                    //navbar f
//                    self.navigationItem.rightBarButtonItems = [favourite, delete]
//                    self.navigationItem.leftBarButtonItem = share
//                    
//                    self.navigationController?.setToolbarHidden(true, animated: true)
//                } else {
//                    
//                    self.navigationItem.rightBarButtonItems = []
//                    self.navigationItem.leftBarButtonItems = []
//                    
//                    // flexible space item
//                    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//                    
//                    //create the toolbar
//                    self.navigationController?.setToolbarHidden(false, animated: true)
//                    self.setToolbarItems([share, flexible, favourite, flexible, delete], animated: true)
//                }
//            }
//        }
//        DispatchQueue.main.async {
//            self.title = self.recipe.formattedName
//        }
//            
//    }
//    
//    private func registerCells() {
//        tableView.register(DetailCell.self, forCellReuseIdentifier: Strings.detailCell)
//        tableView.register(ImageCell.self, forCellReuseIdentifier: Strings.imageCell)
//        tableView.register(StepCell.self, forCellReuseIdentifier: Strings.stepCell)
//        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Strings.textFieldCell)
//        tableView.register(InfoStripCell.self, forCellReuseIdentifier: Strings.infoStripCell)
//        tableView.register(AmountCell.self, forCellReuseIdentifier: Strings.amountCell)
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.plainCell)
//        tableView.register(TextViewCell.self, forCellReuseIdentifier: Strings.infoCell)
//    }
//}
//
//private extension RecipeDetailViewController {
//    
//    @objc private func favouriteRecipe(_ sender: UIBarButtonItem) {
//        recipe.isFavourite.toggle()
//    }
//    
//    @objc private func shareRecipeFile(sender: UIBarButtonItem) {
//        let vc = UIActivityViewController(activityItems: [recipe.createFile()], applicationActivities: nil)
//        vc.popoverPresentationController?.barButtonItem = sender
//        present(vc, animated: true)
//    }
//    
//    @objc private func saveRecipeWrapper() {
//        if creating {
//            saveRecipe(self.recipe)
//            dissmiss()
//        }
//    }
//    
//    @objc private func cancel() {
//        //dissmiss()
//        handleCancelButtonPress()
//    }
//    
//    @objc private func deleteRecipeWrapper() {
//        navigationController?.popToRootViewController(animated: true)
//        if !creating, self.deleteRecipe(recipe) {
//            navigationController?.popToRootViewController(animated: true)
//        }
//    }
//    
//    @objc private func deletePressed(sender: UIBarButtonItem) {
//        let sheet = UIAlertController(preferredStyle: .actionSheet)
//        
//        sheet.addAction(UIAlertAction(title: Strings.Alert_ActionDelete, style: .destructive, handler: { _ in
//            sheet.dismiss(animated: true) {
//                self.deleteRecipeWrapper()
//            }
//        }))
//        
//        sheet.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: { (_) in
//            sheet.dismiss(animated: true)
//        }))
//        
//        sheet.popoverPresentationController?.barButtonItem = sender
//        
//        present(sheet, animated: true)
//    }
//    
//    private func dissmiss() {
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
//}
//
//
//extension RecipeDetailViewController {
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard RecipeDetailSection.allCases[section] == .steps else { return nil }
//        return customHeader(enabled: !self.recipe.steps.isEmpty, title: Strings.steps, frame: tableView.frame)
//    }
//
//    
//}
//
//extension RecipeDetailViewController {
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let item = dataSource.itemIdentifier(for: indexPath) {
//            if item is ImageItem {
//                imageTapped(sender: indexPath)
//            } else if let stepItem = item as? StepItem {
//                showStepDetail(id: stepItem.id)
//            } else if let detailItem = item as? DetailItem {
//                if detailItem.text == Strings.startRecipe {
//                    startRecipe()
//                } else if detailItem.text == Strings.addStep {
//                    showStepDetail(id: nil)
//                }
//            }
//        }
//    }
//}
//
//private extension RecipeDetailViewController {
//    private func imageTapped(sender: IndexPath) {
//        if imagePickerController != nil {
//            imagePickerController?.delegate = nil
//            imagePickerController = nil
//        }
//        imagePickerController = UIImagePickerController()
//        
//        let alert = UIAlertController(title: Strings.image_alert_title, message: nil, preferredStyle: .actionSheet)
//        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alert.addAction(UIAlertAction(title: Strings.take_picture, style: .default, handler: { (_) in
//                self.presentImagePicker(controller: self.imagePickerController!, for: .camera)
//            }))
//        }
//        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            alert.addAction(UIAlertAction(title: Strings.select_image, style: .default, handler: { (_) in
//                self.presentImagePicker(controller: self.imagePickerController!, for: .photoLibrary)
//            }))
//        }
//        
//        alert.addAction(UIAlertAction(title: Strings.Alert_ActionRemove, style: .destructive, handler: { (_) in
//            self.recipe.imageString = nil
//            self.dataSource.update(animated: false)
//        }))
//        alert.addAction(UIAlertAction(title: Strings.Alert_ActionCancel, style: .cancel, handler: { (_) in
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                self.tableView.cellForRow(at: indexPath)?.isSelected = false
//            }
//        }))
//        
//        alert.popoverPresentationController?.sourceView = tableView.cellForRow(at: sender)
//        
//        present(alert, animated: true)
//        
//    }
//    
//    private func showStepDetail(id: UUID?) {
//        let step = id == nil ? Step(time: 60) : recipe.steps.first(where: { $0.id == id })!
//        
//        // create new step
//        if id == nil {
//            self.recipe.steps.append(step)
//        }
//        
//        let stepDetailVC = StepDetailViewController(step: Binding(get: { self.recipe.steps.first(where: { $0.id == step.id })! }, set: { newStep in
//            if let index = self.recipe.steps.firstIndex(where: { $0.id == newStep.id }) {
//                self.recipe.steps[index] = newStep
//                self.dataSource.update(animated: false)
//            }
//        }), recipe: Binding<Recipe>(get: { self.recipe }, set: { newRecipe in
//            if newRecipe != self.recipe {
//                self.recipe = newRecipe
//                self.dataSource.update(animated: false)
//            }
//        }))
//        
//        //navigate to the controller
//        navigationController?.pushViewController(stepDetailVC, animated: true)
//    }
//    
//    private func startRecipe() {
//        let recipeBinding = Binding(get: {
//            return self.recipe
//        }) { (newValue) in
//            self.recipe = newValue
//        }
//        let scheduleForm = ScheduleFormViewController(recipe: recipeBinding)
//        
//        navigationController?.pushViewController(scheduleForm, animated: true)
//    }
//}
//
//extension RecipeDetailViewController {
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let _ = dataSource.itemIdentifier(for: indexPath) as? InfoItem {
//            return 80
//        } else if let _ = dataSource.itemIdentifier(for: indexPath) as? ImageItem {
//            return 250
//        }
//        return UITableView.automaticDimension
//    }
//}
//
//extension RecipeDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    private func presentImagePicker(controller: UIImagePickerController, for source: UIImagePickerController.SourceType) {
//        controller.delegate = self
//        controller.sourceType = source
//        
//        present(controller, animated: true)
//    }
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
//            self.dataSource.update(animated: false)
//            
//            picker.dismiss(animated: true) {
//                self.terminate(picker)
//            }
//        } else {
//            imagePickerControllerDidCancel(picker)
//        }
//    }
//}
