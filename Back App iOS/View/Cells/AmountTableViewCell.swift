//
//  AmountTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeFoundation

class AmountTableViewCell: UITableViewCell, TextFieldCellable {

    internal var textField = UITextField(frame: .zero)
    
    internal var textChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(textField)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    internal func configureTextField() {
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        textField.tintColor = .red
        
        setTextFieldConstraints()
    }
    
    internal func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    
    func setUp(with ingredient: Ingredient, format: @escaping (String) -> String ) {
        textField.text = String(ingredient.formattedAmount)
        textField.placeholder = Strings.amountCellPlaceholder1
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder1
        selectionStyle = .none
        textChanged = { text in
            self.textField.text = format(text)
        }
        self.textChanged!(textField.text ?? "0g" )
    }
    
    func setUp(with text: String, format: @escaping (String) -> String ) {
        textField.text = text
        textField.placeholder = Strings.amountCellPlaceholder2
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder2
        selectionStyle = .none
        textChanged = { text in
            self.textField.text = format(text)
        }
        self.textChanged!(textField.text ?? "" )
    }

}

extension AmountTableViewCell: UITextFieldDelegate {
    @objc private func updateText() {
        if let textChanged = textChanged, let text = textField.text {
            textChanged(text)
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
