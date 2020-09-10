//
//  StepTempTableViewController.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

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
//        if indexPath.section == 1 {
//            return 200
//        } else {
//            return 40
//        }
        return 200
    }

    // MARK: - Cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        //case 0: return makeToggleCell()
        case 0: return pickerCell()
        default: return UITableViewCell()
        }
    }
    
    private func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.toggleCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Strings.pickerCell)
    }
    
    private func makeToggleCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.toggleCell)!
        let toggle = UISwitch(frame: .zero)
        
        toggle.setOn(step.isDynamicTemperature, animated: false)
        toggle.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        cell.selectionStyle = .none
        cell.accessoryView = toggle
        
        cell.textLabel?.text = Strings.dynamicTemp
        cell.backgroundColor = UIColor(named: Strings.backgroundColorName)!
        
        return cell
    }
    
    @objc private func toggleTapped(_ sender: UISwitch) {
        step.isDynamicTemperature = sender.isOn
        picker.reloadAllComponents()
    }
    
    private func pickerCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Strings.pickerCell)!
        
        configurePicker()
        cell.contentView.addSubview(picker)
        addPickerConstraints(cell: cell)
        cell.backgroundColor = UIColor(named: Strings.backgroundColorName)!
        
        return cell
    }
    
    private func configurePicker() {
        picker = UIPickerView(frame: .zero)
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(step.temperature + 10, inComponent: 0, animated: false)
        if step.isDynamicTemperature {
            picker.selectRow(step.secondTemp + 10 , inComponent: 1, animated: false)
        }
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
//        if step.isDynamicTemperature {
//            if component == 0 {
//                return "\(Strings.start): \(row - 10)"
//            } else {
//                return "\(Strings.end): \(row - 10)"
//            }
//        } else {
        return "\(row - 10)"
//        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 0 {
            step.temperature = row - 10
//        } else if component == 1 {
//            step.secondTemp = row - 10
//        }
    }

}
