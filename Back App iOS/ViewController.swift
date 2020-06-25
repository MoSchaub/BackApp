//
//  ViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var recipeStore = RecipeStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Back App"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recipeStore.recipes.count
        } else {
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Rezepte"
        } else {
            return "other"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, recipeStore.recipes.count > indexPath.row{
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath)
            let recipe = recipeStore.recipes[indexPath.row]
            cell.textLabel?.text = recipe.name
            cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
            if let imageData = recipe.imageString {
                cell.imageView?.image = UIImage(data: imageData)
            } else {
                cell.imageView?.image = UIImage(named: "bread")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "other", for: indexPath)
            cell.textLabel?.text = "\(indexPath.row)"
            return cell
        }
    }
    
    //deleting and moving recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete ,indexPath.section == 0, recipeStore.recipes.count > indexPath.row{
            recipeStore.recipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section == 0 else { return }
        guard recipeStore.recipes.count > sourceIndexPath.row else { return }
        let movedObject = recipeStore.recipes[sourceIndexPath.row]
        recipeStore.recipes.remove(at: sourceIndexPath.row)
        recipeStore.recipes.insert(movedObject, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }
    
    


}

