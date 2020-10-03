//
//  TextFieldTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeCore

class TextFieldTableViewCell: UITableViewCell{
    
    var textField = UITextField(frame: .zero)
    
    var textChanged: ((String) -> Void)?
    
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
        
        textField.addTarget(self, action: #selector(updateText), for: .editingChanged)
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
    
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    
    @objc func updateText() {
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
    
}
