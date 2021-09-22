//
//  TextFieldCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit
import BakingRecipeStrings
import CombineCocoa
import Combine

public class TextFieldCell: CustomCell {
    
    /// The textField of the cell
    public var textField = UITextField(frame: .zero)
    
    private var placeholder = "Placeholder"
    
    internal var tokens = Set<AnyCancellable>()
    
    /// method called when text changed
    public var textChanged: ((String) -> Void)?
    
    override func setup() {
        super.setup()
        addSubview(textField)
        configureTextField()
    }
    
    /// sets the behavior for updating: only calls update Text when editingDidEnd
    /// - Note: internal because its needs to be overwritten in a subclass
    internal func setTextFieldBehavior() {
        textField.controlEventPublisher(for: .editingDidEnd).sink { _ in self.updateText() }.store(in: &tokens)
        textField.controlEventPublisher(for: .editingChanged).sink { _ in self.updateText() }.store(in: &tokens)
    }
    
    deinit {
        
        // cancel listening to control event publishers
        for token in tokens {
            token.cancel()
        }
    }
    
    
}

private extension TextFieldCell {
    
    /// set up the textfield
    func configureTextField() {
        textField.delegate = self
        
        setTextFieldBehavior()
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        
        textField.textColor = .primaryCellTextColor
        textField.tintColor = .baTintColor
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.secondaryCellTextColor!])
        
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
    
    @objc internal func updateText(completion: (() -> ())? = nil ) {
        let textFieldText = textField.text
        DispatchQueue.global(qos: .background).async {
            if let textChanged = self.textChanged, let text = textFieldText {//force away from main thread to not interrupt the ux
                textChanged(text)
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
    public override func endEditing(_ force: Bool) -> Bool {
        // cancel listening to control event publishers
        for token in tokens {
            token.cancel()
        }
        
        return super.endEditing(force)
    }
}
