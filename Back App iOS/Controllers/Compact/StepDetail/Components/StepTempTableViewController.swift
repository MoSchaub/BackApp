//
//  StepTempTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeStrings
import BakingRecipeCells
import BackAppCore

class StepTempTableViewController: UITableViewController {
    // MARK: - Properties
    
    @Binding private var step: Step
    
    private var datePicker: UIDatePicker!
    
    init(step: Binding<Step>) {
        self._step = step
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        title = Strings.temperature
    }
    
    // MARK: - rows and sections
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // MARK: - Cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        //case 0: return makeToggleCell()
        case 0: return pickerCell()
        default: return CustomCell()
        }
    }
    
    private func registerCells() {
        tableView.register(CustomCell.self, forCellReuseIdentifier: Strings.pickerCell)
    }
    
    private func pickerCell() -> CustomCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.pickerCell)! as! CustomCell
        
        configurePicker()
        cell.contentView.addSubview(picker)
        addPickerConstraints(cell: cell)
        
        return cell
    }
    
    private func configurePicker() {
        picker = UIPickerView(frame: .zero)
        picker.dataSource = self
        picker.delegate = self
        
        let pickerLabelProxy = UILabel.appearance(whenContainedInInstancesOf: [UIPickerView.self])
        pickerLabelProxy.textColorWorkaround = .cellTextColor
        
        let roomTemp = Standarts.standardRoomTemperature
        picker.selectRow(step.temperature ?? roomTemp + 10, inComponent: 0, animated: false)
    }
    
    private func addPickerConstraints(cell: UITableViewCell) {
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
        picker.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -10).isActive = true
        picker.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.8).isActive = true
    }
    
}

extension StepTempTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row - 10)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        step.temperature = row - 10
    }
    
}
