//
//  RoomTempTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class RoomTempTableViewController: UITableViewController {
    
    var recipeStore: RecipeStore!
    var updateTemp: ((Int) -> ())!
    var picker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tempPicker")
        title = "Raumtemperatur"
    }

    // MARK: rows and sections

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // MARK: - Cell
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tempPicker", for: indexPath)
        configurePicker()
        cell.contentView.addSubview(picker)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
        picker.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -10).isActive = true
        picker.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.8).isActive = true

        return cell
    }
    
    private func configurePicker() {
        picker = UIPickerView(frame: .zero)
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(recipeStore.roomTemperature + 10, inComponent: 0, animated: false)
    }
}

extension RoomTempTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(row - 10)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTemp!(row - 10)
    }

}
