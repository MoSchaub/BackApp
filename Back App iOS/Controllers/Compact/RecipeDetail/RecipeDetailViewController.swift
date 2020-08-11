//
//  RecipeDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 25.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

class RecipeDetailViewController: UITableViewController {
    
    typealias SaveRecipe = ((Recipe) -> ())
    
    private lazy var dataSource = makeDataSource()
    
    private var imagePickerController: UIImagePickerController?
    
    private var recipe: Recipe {
        didSet {
            setUpNavigationBar()
            update(oldValue: oldValue)
        }
    }
    private var creating: Bool
    private var saveRecipe: SaveRecipe
    
    private func update(oldValue: Recipe) {
        DispatchQueue.global(qos: .utility).async {
            if !self.creating, oldValue != self.recipe {
                self.saveRecipe(self.recipe)
            }
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
            let favourite = UIBarButtonItem(image: UIImage(systemName: recipe.isFavourite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(favouriteRecipe))
            let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareRecipeFile))
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItems = [favourite,share ]
            }
        }
        DispatchQueue.main.async {
            self.title = self.recipe.formattedName
        }
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
        let frame = tableView.frame
        
        let editButton = UIButton(frame: CGRect(x: frame.size.width - 60, y: 10, width: 50, height: 30))
        editButton.setAttributedTitle(attributedTitleForEditButton(), for: .normal)
        editButton.addTarget(self, action: #selector(toggleEditMode(sender:)), for: .touchDown)
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 30))
        let attributes = [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor : UIColor.secondaryLabel,
        ]
        titleLabel.attributedText = NSAttributedString(string: "Schritte".uppercased(), attributes: attributes)
        
        let stackView = UIStackView(frame: CGRect(x: 5, y: 0, width: frame.size.width - 10, height: frame.size.height))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(editButton)
        
        return stackView
    }
    
    private func attributedTitleForEditButton() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: .current),
            .foregroundColor : UIColor.link
        ]
        let titleString = isEditing ? "Fertig" : "Bearbeiten"
        return NSAttributedString(string: titleString, attributes: attributes)
    }
    
    @objc private func toggleEditMode(sender: UIButton) {
        setEditing(!isEditing, animated: true)
        sender.setAttributedTitle(attributedTitleForEditButton(), for: .normal)
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

extension RecipeDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            if item is ImageItem {
                imageTapped()
            } else if let stepItem = item as? StepItem {
                showStepDetail(id: stepItem.id)
            } else if let detailItem = item as? DetailItem {
                if detailItem.text == NSLocalizedString("startRecipe", comment: "") {
                    startRecipe()
                } else if detailItem.text == "Schritt hinzufügen" {
                    addStep()
                }
            }
        }
    }
}

private extension RecipeDetailViewController {
    private func imageTapped() {
        if imagePickerController != nil {
            imagePickerController?.delegate = nil
            imagePickerController = nil
        }
        imagePickerController = UIImagePickerController()
        
        let alert = UIAlertController(title: "Bild auswählen, bearbeiten, oder aktuelles Bild entfernen", message: nil, preferredStyle: .actionSheet)
        
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
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.cellForRow(at: indexPath)?.isSelected = false
            }
        }))
        
        present(alert, animated: true)
        
    }
    
    private func showStepDetail(id: UUID) {
        if let step = recipe.steps.first(where: { $0.id == id }) {
            let stepDetailVC = StepDetailViewController(step: step, creating: false, recipe: recipe) { step in
                if let index = self.recipe.steps.firstIndex(where: { $0.id == step.id }) {
                    self.recipe.steps[index] = step
                    self.dataSource.update(animated: false)
                }
            }
            navigationController?.pushViewController(stepDetailVC, animated: true)
        }
    }
    
    private func startRecipe() {
        let roomTemp = UserDefaults.standard.integer(forKey: "roomTemp")
        let recipeBinding = Binding(get: {
            return self.recipe
        }) { (newValue) in
            self.recipe = newValue
        }
        let scheduleForm = ScheduleForm(recipe: recipeBinding, roomTemp: roomTemp)
        let vc = UIHostingController(rootView: scheduleForm)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addStep() {
        let step = Step(name: "", time: 60)
        let stepDetailVC = StepDetailViewController(step: step, creating: true, recipe: recipe) { step in
            self.recipe.steps.append(step)
            DispatchQueue.main.async {
                self.dataSource.update(animated: false)
            }
        }
        
        navigationController?.pushViewController(stepDetailVC, animated: true)
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
