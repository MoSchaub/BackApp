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
    
    public func setUp(with ingredient: Ingredient, format: @escaping (String) -> String ) {
        textField.text = String(ingredient.formattedAmount)
        textField.placeholder = Strings.amountCellPlaceholder1
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder1
        textField.keyboardType = .decimalPad
        setUpBoth(format: format)
        self.textChanged!(textField.text ?? "0g" )
    }
    
    public func setUp(with text: String, format: @escaping (String) -> String ) {
        textField.text = text
        textField.placeholder = Strings.amountCellPlaceholder2
        textField.accessibilityIdentifier = Strings.amountCellPlaceholder2
        textField.keyboardType = .numberPad
        setUpBoth(format: format)
        self.textChanged!(textField.text ?? "" )
    }
    
    private func setUpBoth(format: @escaping (String) -> String ) {
        selectionStyle = .none
        textChanged = { text in
            self.textField.text = format(text)
        }
    }
    
    public override func setTextFieldBehavior() {
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
    }
    
}

public extension AmountCell{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
}
