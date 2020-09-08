//
//  DecimalCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 05.09.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import LBTATools

class DecimalCell: UITableViewCell {
    
    @Binding private var value: Decimal?
    var textField: UITextField
    var standartValue: Decimal
    private var formatter: NumberFormatter {
        let nv = NumberFormatter()
        nv.numberStyle = .decimal
        return nv
    }

    init(decimal: Binding<Decimal?>, reuseIdentifier: String?, standartValue: Decimal) {
        self._value = decimal
        self.textField = UITextField(frame: .zero)
        self.standartValue = standartValue
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpTextView()
        selectionStyle = .none
        self.textField.text = formatter.string(for: standartValue)!
    }
    
    private func setUpTextView() {
        addSubview(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingchange), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        textField.tintColor = .red
        textField.placeholder = Strings.amountCellPlaceholder2
        
        setTextFieldConstraints()
        textField.becomeFirstResponder()
    }
    
    private func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }

}


extension DecimalCell: UITextFieldDelegate {
    
    @objc private func editingchange() {
        // When the field is in focus we replace the field's contents
        // with a plain unformatted number. When not in focus, the field
        // is treated as a label and shows the formatted value.
        if textField.isFirstResponder {
        } else {
        let f = self.formatter
            let newValue = f.number(from: self.textField.text ?? "")?.decimalValue
            self.textField.text = f.string(for: newValue) ?? ""
        }
    }
    
    @objc private func updateText() {
        // This is the only place we update `value`.
        if let newValue = formatter.number(from: self.textField.text ?? "")?.decimalValue {
            self.textField.text = formatter.string(for: newValue) ?? ""
            self.value = newValue
        } else {
            self.textField.text = formatter.string(for: standartValue)!
        }
    }
    
    @objc private func tapDone(sender: Any) {
        self.textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
}
