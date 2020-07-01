//
//  RecipeDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 25.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import SwiftUI

class RecipeDetailViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var imagePickerController: UIImagePickerController?
    
    var recipe: Recipe! {
        willSet {
            if newValue != nil {
                recipeStore.update(recipe: newValue!)
                title = newValue.formattedName
            }
        }
    }
    var recipeStore = RecipeStore()
    var creating = false
    var initializing = true
    var saveRecipe: ((Recipe) -> Void)?
    
    // MARK: - Startup functions

    override func loadView() {
        super.loadView()
        registerCells()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !initializing {
            self.recipe = recipeStore.recipes.first(where: { recipe.id == $0.id })
            tableView.reloadData()
        }
        initializing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recipeStore.save(recipe: recipe)
    }
    
    // MARK: - NavigaitonBarItems
    
    private func addNavigationBarItems() {
        if creating {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(saveRecipeWrapper))
            navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(dissmiss))
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    @objc private func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveRecipeWrapper() {
        if let saveRecipe = saveRecipe, creating {
            saveRecipe(recipe)
            dissmiss()
        }
    }

    // MARK: - Sections and rows

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return creating ? 1 : 2
        case 3: return (recipe?.steps.count ?? 0) + 1
        case 4: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("name", comment: "")
        case 1: return NSLocalizedString("bild", comment: "")
        case 3: return NSLocalizedString("schritte", comment: "")
        case 4: return NSLocalizedString("anzahl", comment: "")
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 200
        case 3:
            if indexPath.row == recipe.steps.count {
                return 40
            } else {
                return CGFloat(55 + recipe.steps[indexPath.row].ingredients.count * 18 + recipe.steps[indexPath.row].subSteps.count * 18)
            }
        default: return 40
        }
    }
    
    // MARK: - Cells
    
    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "image")
        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: "step")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textField")
        tableView.register(InfoStripTableViewCell.self, forCellReuseIdentifier: "infoStrip")
        tableView.register(AmountTableViewCell.self, forCellReuseIdentifier: "times")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0: return makeTextFieldCell()
        case 1: return makeImageViewCell()
        case 2:
            if row == 1 && !creating {
                return makeStartRecipeCell()
            } else {
                return makeInfoStripCell() //InfoStrip
            }
        case 3:
            if indexPath.row == recipe.steps.count {
                return makeNewStepCell()
            } else {
                return makeStepCell(forRowAt: indexPath)
            }
        case 4: return makeTimesCell()
            
        default: return UITableViewCell()
        }
    }
    

    private func makeTextFieldCell() -> TextFieldTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textField") as! TextFieldTableViewCell
        cell.textField.text = recipe.name
        cell.textField.placeholder = NSLocalizedString("name", comment: "")
        cell.selectionStyle = .none
        cell.textChanged = { name in
            self.recipe.name = name
        }
        return cell
    }
    
    private func makeImageViewCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "image") as! ImageTableViewCell
        if let imageData = recipe.imageString {
            cell.imageView?.image = UIImage(data: imageData) ?? Images.photo
        } else {
            cell.imageView?.image = Images.photo
            cell.imageView?.tintColor = .label
        }
       
        
        let upIconView = UIImageView(image: UIImage(systemName: "chevron.up"))
        upIconView.tintColor = .tertiaryLabel
        cell.accessoryView = upIconView
        
        return cell
    }
    
    
    
    private func makeInfoStripCell() -> InfoStripTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoStrip") as! InfoStripTableViewCell
        cell.setUpCell(for: recipe)
        
        return cell
    }
    
    private func makeStartRecipeCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plain")!
        cell.textLabel?.text = NSLocalizedString("startRecipe", comment: "")
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    private func makeStepCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = StepTableViewCell(style: .default, reuseIdentifier: "step")
        if recipe.steps.count > indexPath.row {
            cell.setUpCell(for: recipe.steps[indexPath.row], recipe: recipe, roomTemp: recipeStore.roomTemperature)
        }
        
        return cell
    }
    
    private func makeNewStepCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plain")!
        cell.textLabel?.text = NSLocalizedString("addStep", comment: "")
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func makeTimesCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "times") as! AmountTableViewCell
        cell.setUp(with: recipe, format: format)
        return cell
    }
    
    private func format(timesText: String) -> String {
        guard Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return "1 stk" }
        recipe.times = Decimal(floatLiteral: Double(timesText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0)
        return recipe.timesText
    }
    
    // MARK: - Editing

    // conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 3 && indexPath.row < recipe.steps.count ? true : false
    }

    //editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 3, let recipe = recipe, recipe.steps.count > indexPath.row {
            // Delete the row from the data source
            self.recipe!.steps.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard recipe != nil else { return }
        guard destinationIndexPath.section == 3 else { return }
        guard recipe!.steps.count > sourceIndexPath.row else { return }
        let movedObject = recipe!.steps[sourceIndexPath.row]
        recipe!.steps.remove(at: sourceIndexPath.row)
        recipe!.steps.insert(movedObject, at: destinationIndexPath.row)
    }

    // conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 3 ? true : false
    }
    
    // MARK: - Navigation and Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1: navigateToImagePicker()
        case 2:
            if indexPath.row == 1 {
                navigateToScheduleView()
            }
        case 3:
            if indexPath.row == recipe.steps.count {
                navigateToAddStepView()
            } else {
                navigateToStepDetail(at: indexPath)
            }
        default: print("test")
        }
    }
    
    
    
    private func navigateToScheduleView() {
        let recipeBinding = Binding(get: {
            return self.recipe!
        }) { (newValue) in
            self.recipe = newValue
        }
        let scheduleForm = ScheduleForm(recipe: recipeBinding, roomTemp: recipeStore.roomTemperature)
        let vc = UIHostingController(rootView: scheduleForm)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAddStepView() {
        let stepDetailVC = StepDetailViewController()
        stepDetailVC.recipeStore = RecipeStore(true)
        stepDetailVC.recipe = recipe
        stepDetailVC.step = Step(name: "", time: 60)
        stepDetailVC.creating = true
        stepDetailVC.saveStep = saveStep
        
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
    
    private func saveStep(step: Step, recipe: Recipe){
        recipeStore.save(step: step, to: recipe)
        tableView.reloadData()
    }
    
    private func navigateToStepDetail(at indexPath: IndexPath) {
        recipeStore = RecipeStore()
        recipeStore.save(recipe: recipe)
        let stepDetailVC = StepDetailViewController()
        stepDetailVC.recipeStore = recipeStore
        stepDetailVC.recipe = recipe
        stepDetailVC.step = recipe.steps[indexPath.row]
        
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
    
    private func presentImagePicker(controller: UIImagePickerController, for source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        
        present(controller, animated: true)
    }
    
    private func navigateToImagePicker() {
        if imagePickerController != nil {
            imagePickerController?.delegate = nil
            imagePickerController = nil
        }
        imagePickerController = UIImagePickerController()
        
        let alert = UIAlertController(title: "Tesnt", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "aufnehmen", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, for: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "auswählen", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, for: .photoLibrary)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Bild entfernen", style: .destructive, handler: { (_) in
            self.recipe.imageString = nil
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel))
        
        present(alert, animated: true)
        
    }

}

// MARK: - ImagePicker

extension RecipeDetailViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
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
            recipe.imageString = uiImage.jpegData(compressionQuality: 0.3)
            tableView.reloadData()
            
            picker.dismiss(animated: true) {
                self.terminate(picker)
            }
        } else {
            imagePickerControllerDidCancel(picker)
        }
    }
    
}
