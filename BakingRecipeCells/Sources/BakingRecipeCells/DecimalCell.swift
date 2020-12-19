//
//  DecimalCell.swift
//
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BakingRecipeStrings

public class DecimalCell: CustomCell {
    
    @Binding private var value: Decimal?
    
    /// The standardValue for the decimal when its nil
    var standartValue: Decimal
    
    /// The textField of the cell
    var textField: UITextField
    
    public init(decimal: Binding<Decimal?>, reuseIdentifier: String?, standartValue: Decimal) {
        self._value = decimal
        self.textField = UITextField(frame: .zero)
        self.standartValue = standartValue
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        addSubview(textField)
        configureTextField()
    }
}

private extension DecimalCell {
    
    /// the number formatter
    private var formatter: NumberFormatter {
        let nv = NumberFormatter()
        nv.numberStyle = .decimal
        return nv
    }
    
    /// set up the textfield
    func configureTextField() {
        addSubview(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingchange), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        
        textField.tintColor = .red
        textField.textColor = .cellTextColor
        textField.attributedPlaceholder = NSAttributedString(string: Strings.amountCellPlaceholder2, attributes: [.foregroundColor : UIColor.secondaryColor])
        
        setTextFieldConstraints()
        textField.becomeFirstResponder()
    }
    
    /// set up the constraints
    func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
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
}

extension DecimalCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
}
