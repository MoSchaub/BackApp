//
//  TempPickerCell.swift
//  
//
//  Created by Moritz Schaub on 12.10.20.
//

import SwiftUI

public class TempPickerCell: CustomCell {
    
    ///currently selected Date
    @Binding private var temp: Int
    
    /// the datePicker displayed in the cell
    private lazy var tempPicker = UIPickerView(backgroundColor: UIColor.cellBackgroundColor!)
    
    public init(temp: Binding<Int>, reuseIdentifier: String?) {
        self._temp = temp
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        addSubview(tempPicker)
        self.configureTempPicker()
    }
}

private extension TempPickerCell {
    
    func configureTempPicker() {
        setUpTempPickerConstraints()
        tempPicker.dataSource = self
        tempPicker.delegate = self
        
        tempPicker.setValue(UIColor.primaryCellTextColor, forKeyPath: "textColor")
        
        tempPicker.selectRow(temp + 10, inComponent: 0, animated: false)
    }
    
    //sets constraints for picker
    private func setUpTempPickerConstraints() {
        tempPicker.fillSuperview()
    }
    
}

extension TempPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        60
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: "\(row - 10)", attributes: [NSAttributedString.Key.foregroundColor:UIColor.primaryCellTextColor!])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temp = row - 10
    }
    
}
