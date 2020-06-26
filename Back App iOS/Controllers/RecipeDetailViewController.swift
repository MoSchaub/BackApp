//
//  RecipeDetailViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 25.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UITableViewController {
    var recipe: Recipe! {
        willSet {
            if newValue != nil {
                recipeStore.update(recipe: newValue!)
                title = newValue.name
            }
        }
    }
    var recipeStore = RecipeStore()
    var creating = false 

    override func loadView() {
        super.loadView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 3
        case 3: return recipe?.steps.count ?? 0 + 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        //let row = indexPath.row
        if section == 0 {
            let cell: TextFieldTableViewCell
            cell = TextFieldTableViewCell(style: .default, reuseIdentifier: "textfield")
            cell.textField.text = recipe.name
            cell.textChanged = { name in
                self.recipe.name = name
            }
            
            
            return cell
        }
        return UITableViewCell()
    }
    

    
    // conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 3 ? true : false
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
