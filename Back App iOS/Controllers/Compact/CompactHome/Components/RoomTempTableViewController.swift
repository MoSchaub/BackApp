//
//  RoomTempTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeStrings
import BackAppCore
import BakingRecipeCells

class RoomTempTableViewController: UITableViewController {
    
    var appData: BackAppData!
    var updateTemp: ((Int) -> ())!
    var picker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.tempPickerCell)
        title = Strings.roomTemperature
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CustomCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.tempPickerCell, for: indexPath) as! CustomCell
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
        
        picker.selectRow(Standarts.roomTemp + 10, inComponent: 0, animated: false)
    }
}

extension RoomTempTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        60
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: String((row - 10)), attributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryCellTextColor!])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTemp!(row - 10)
    }

}
