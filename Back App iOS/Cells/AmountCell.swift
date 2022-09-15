//
//  AmountCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit
import BakingRecipeFoundation
import BakingRecipeStrings

public class AmountCell: TextFieldCell {
    
    private func setUp(with text: String, format: @escaping (String) -> String ) {
        textField.text = text
        textField.placeholder = Strings.amountCellPlaceholder2
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder2
        textField.keyboardType = .numberPad
        setUpBoth(format: format)
        self.textChanged!(textField.text ?? "" )
    }

    public init(text: String, reuseIdentifier: String, format: @escaping (String) -> String ) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setUp(with: text, format: format)
    }

    public init(ingredient: Ingredient, reuseIdentifier: String, format: @escaping (String) -> String, amountEditingDidEnd: @escaping () -> Void) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textField.text = String(ingredient.formattedAmount)
        textField.placeholder = Strings.amountCellPlaceholder1
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder1
        textField.keyboardType = .decimalPad
        setUpBoth(format: format)
        self.textChanged!(textField.text ?? "0g" )
        self.amountEditingDidEnd = amountEditingDidEnd
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var amountEditingDidEnd: (() -> Void)?
    
    private func setUpBoth(format: @escaping (String) -> String ) {
        selectionStyle = .none
        textChanged = { text in
            DispatchQueue.main.async { //force the ui update to the main thread
                self.textField.text = format(text)
            }
        }
    }
    
    internal override func setTextFieldBehavior() {
        textField.controlEventPublisher(for: .editingDidEnd).sink { _ in
            self.updateText {
                if let amountEditingDidEnd = self.amountEditingDidEnd {
                    amountEditingDidEnd()
                }
            }
            NotificationCenter.default.post(name: .fieldDoneButtonItemShouldBeRemoved, object: nil)
        }.store(in: &tokens)
        textField.controlEventPublisher(for: .editingDidBegin).sink { _ in
            NotificationCenter.default.post(name: .fieldDoneButtonItemShouldBeDisplayed, object: self.textField)
        }.store(in: &tokens)
       
    }
    
}

public extension AmountCell{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
}
