//
//  ViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UITableViewController {
    
    private var recipeStore = RecipeStore()
    
    // MARK: - Start functions
    
    override func loadView() {
        super.loadView()
        configureTableView()
        configureTitle()
        configureNavigationBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func configureTableView() {
        tableView  = UITableView(frame: tableView.frame, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
    }
    
    private func configureTitle() {
        title = "Back App"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureNavigationBarItems() {
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(presentAddRecipePopover))
    }
    
    // MARK: - rows and sections
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recipeStore.recipes.count
        } else {
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Recipes"
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 40
        }
    }
    
    // MARK: - Cells
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, recipeStore.recipes.count > indexPath.row{ //recipe section
            return recipeCell(at: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Raumthemperatur: \(recipeStore.roomThemperature)ºC"
            case 1:
                cell.textLabel?.text = "Rezepte aus Datei importieren"
            case 2:
                cell.textLabel?.text = "alle Rezepte exportieren"
            case 3:
                cell.textLabel?.text = "Über diese App"
            default:
                cell.textLabel?.text = "\(indexPath.row)"
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private func recipeCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = RecipeTableViewCell(style: .subtitle, reuseIdentifier: "recipe")
        let recipe = recipeStore.recipes[indexPath.row]
        cell.textLabel?.text = recipe.formattedName
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.text = recipe.formattedTotalTime
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .footnote)
        cell.accessoryType = .disclosureIndicator
        
        if let imageData = recipe.imageString {
            cell.imageView?.image = UIImage(data: imageData) ?? Images.photo
        } else {
            cell.imageView?.image = Images.photo
            cell.imageView?.tintColor = .label
        }
        return cell
    }
    
    // MARK: - Editing
    
    //delete recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.section == 0, recipeStore.recipes.count > indexPath.row {
            recipeStore.recipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // move recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section == 0 else { return }
        guard recipeStore.recipes.count > sourceIndexPath.row else { return }
        let movedObject = recipeStore.recipes[sourceIndexPath.row]
        recipeStore.recipes.remove(at: sourceIndexPath.row)
        recipeStore.recipes.insert(movedObject, at: destinationIndexPath.row)
    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, recipeStore.recipes.count > indexPath.row {
            // 1: try loading the "Detail" view controller and typecasting it to be RecipeDetailViewController
            let vc = RecipeDetailViewController(style: .insetGrouped)
            // 2: success! Set its recipe property
            vc.recipe = recipeStore.recipes[indexPath.row]
            vc.recipeStore = recipeStore
            
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            let row = indexPath.row
            if row == 0 {
                print("temp")
                // room temperaturePicker
            } else if row == 1 {
                print("import")
            } else if row == 2 {
                print("export")
            } else if row == 3 {
                print("about")
            }
            
        }
    }
    
    @objc private func presentAddRecipePopover(_ sender: UIBarButtonItem) {
        let vc = RecipeDetailViewController(style: .insetGrouped) // create vc
        vc.recipe = Recipe(name: "", brotValues: [], category: recipeStore.categories.first!) //create fresh recipe
        vc.recipeStore = RecipeStore(true)
        vc.recipeStore.roomThemperature = recipeStore.roomThemperature
        vc.recipeStore.categories = recipeStore.categories
        vc.creating = true
        vc.saveRecipe = { recipe in
            self.recipeStore.addRecipe(recipe: recipe)
            self.tableView.reloadData()
        }
        let nv = UINavigationController(rootViewController: vc)
        
        present(nv, animated: true)
    }


}

