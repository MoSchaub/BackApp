//
//  File.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit
import BakingRecipeStrings

public class TextFieldCell: CustomCell {
    
    /// The textField of the cell
    public var textField = UITextField(frame: .zero)
    
    private var placeholder = "Placeholder"
    
    /// method called when text changed
    public var textChanged: ((String) -> Void)?
    
    override func setup() {
        super.setup()
        addSubview(textField)
        configureTextField()
    }
    
    public func setTextFieldBehavior() {
        textField.addTarget(self, action: #selector(updateText), for: .editingChanged)
    }
}

private extension TextFieldCell {
    
    /// set up the textfield
    func configureTextField() {
        textField.delegate = self
        
        setTextFieldBehavior()
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        
        textField.textColor = .cellTextColor
        textField.tintColor = .red
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.secondaryColor])
        
        setTextFieldConstraints()
    }
    
    /// set up the constraints
    func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    
    
    
    @objc private func tapDone(sender: Any) {
        self.textField.endEditing(true)
    }
    
}

extension TextFieldCell: UITextFieldDelegate {
    
    @objc public func updateText() {
        if let textChanged = textChanged, let text = textField.text {
            textChanged(text)
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
}
