// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  TempPickerCell.swift
//  
//
//  Created by Moritz Schaub on 12.10.20.
//

import SwiftUI
import BackAppCore

public protocol TempPickerCellDelegate: AnyObject {
    
    func tempPickerCell(_ cell: TempPickerCell, didChangeValue value: Double)
    
    func startValue(for cell: TempPickerCell) -> Double
    
}

public class TempPickerCell: CustomCell {

    public var id: String? = nil
    
    ///currently selected temperature
    private var temp: Double = 20.0 {
        didSet {
            delegate?.tempPickerCell(self, didChangeValue: temp)
        }
    }
    
    open weak var delegate: TempPickerCellDelegate? {
        didSet {
            self.setupCell()
        }
    }
    
    /// the datePicker displayed in the cell
    private lazy var tempPicker = makeTempPicker()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}

private extension TempPickerCell {
    
    func makeTempPicker() -> UIPickerView {
        UIPickerView(backgroundColor: UIColor.cellBackgroundColor!)
    }
    
    func configureTempPicker() {
        addSubview(tempPicker)
        
        tempPicker.dataSource = self
        tempPicker.delegate = self
        
        setUpTempPickerConstraints()
        updatePicker()
    }
    
    //sets constraints for picker
    private func setUpTempPickerConstraints() {
        tempPicker.fillSuperview()
    }
    
    private func setupCell() {
        self.selectionStyle = .none
        configureTempPicker()
    }
    
}

extension TempPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc private func updatePicker() {
        tempPicker.selectRow(Int(delegate?.startValue(for: self) ?? Standarts.roomTemp) + 10, inComponent: 0, animated: false)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        60
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: Measurement(value: Double(row - 10), unit: UnitTemperature.celsius).localizedValue, attributes: [.foregroundColor : UIColor.primaryCellTextColor!])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temp = Double(row - 10)
    }
    
}
