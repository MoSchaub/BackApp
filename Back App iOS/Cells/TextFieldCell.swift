// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
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
        textField.controlEventPublisher(for: .editingDidEnd)
            .sink { _ in
                self.updateText()
                NotificationCenter.default.post(name: .fieldDoneButtonItemShouldBeRemoved, object: nil)
            }
            .store(in: &tokens)
        textField.controlEventPublisher(for: .editingChanged).sink { _ in self.updateText() }.store(in: &tokens)
        textField.controlEventPublisher(for: .editingDidBegin).sink { _ in
            NotificationCenter.default.post(name: .fieldDoneButtonItemShouldBeDisplayed, object: self.textField)
        }.store(in: &tokens)
    }

    init(text: String, placeholder: String, reuseIdentifier: String, textChanded: ((String) -> Void)?) {
        self.textField.text = text
        self.placeholder = placeholder
        self.textChanged = textChanded
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        textField.textColor = .primaryCellTextColor
        textField.tintColor = .primaryCellTextColor
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.secondaryCellTextColor!])
        
        setTextFieldConstraints()
    }
    
    /// set up the constraints
    func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }

}

extension TextFieldCell: UITextFieldDelegate {
    
    /// Passes the text to `textChanged` on the main actor, where UIKit sends the text field events.
    ///
    /// The callbacks change view controller state and save it, so they must not run on a background queue.
    /// Calling them synchronously also keeps the saves in the order the text was typed
    /// (an older value like "Mis" must never overwrite a newer one like "Mischen").
    @objc internal func updateText(completion: (() -> ())? = nil ) {
        guard let textChanged, let text = textField.text else { return }
        textChanged(text)
        completion?()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
}
