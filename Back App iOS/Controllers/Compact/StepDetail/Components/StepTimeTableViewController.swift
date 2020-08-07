//
//  StepTimeTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipe

class StepTimeTableViewController: UITableViewController {

    // MARK: - Properties
    
    var step: Step! {
        willSet {
            if newValue != nil { if recipe != nil, recipeStore != nil {
                recipeStore.update(step: newValue, in: recipe)
                }
            }
        }
    }
    var recipe: Recipe!
    var recipeStore: RecipeStore!
    
    private var datePicker: UIDatePicker!
    
    // MARK: - Start functions

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        title = NSLocalizedString("duration", comment: "")
    }

    // MARK: - rows and sections

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }

    // MARK: - Cells
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timePicker")!

        cell.selectionStyle = .none
        
        datePicker = UIDatePicker(frame: .zero)
        cell.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
        
        datePicker.datePickerMode = .countDownTimer
        
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        DispatchQueue.main.async(execute: {
            self.datePicker.countDownDuration = self.step.time
        })
        return cell
    }
    
    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "timePicker")
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        step.time = sender.countDownDuration
    }

}
