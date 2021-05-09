//
//  DecimalCell.swift
//
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BakingRecipeStrings

/// The `DecimalCellDelegate` protocol allows the adopting delegate to respond to the UI interaction
public protocol DecimalCellDelegate: AnyObject {
    func decimalCell(_ cell: DecimalCell, didChangeValue value: Decimal?)
    
    func standardValue(in cell: DecimalCell) -> Decimal
}

public class DecimalCell: CustomCell {
    
    private var value: Decimal? {
        didSet {
            delegate?.decimalCell(self, didChangeValue: value)
        }
    }
    
    /// The textField of the cell
    private lazy var textField = makeTextField()
    
    /// The decimal cell's delegate object, which should conform to `DecimalCellDelegate`
    open weak var delegate: DecimalCellDelegate? {
        didSet {
            self.setupCell()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setupCell() {
        configureTextField()
        setTextFieldConstraints()
    }
    
    private func makeTextField() -> UITextField {
        let textField = UITextField(frame: .zero)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingchange), for: .editingChanged) //updates the text while editing
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd) //updates the text when finished editing
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone)) // add toolbar to keyboard with done button to finish editing
        
        textField.keyboardType = .decimalPad //set keyboard type to decimalpad because the user should be only enter decimals
        
        //colors
        textField.tintColor = .tintColor
        textField.textColor = .primaryCellTextColor
        //set placeholder text and its color. color has to be changed cause it should use light mode colors in dark mode and dark mode colors in light mode. textColor of placeholder text can't be set but by using an attributed String
        textField.attributedPlaceholder = NSAttributedString(string: Strings.amountCellPlaceholder2, attributes: [.foregroundColor : UIColor.secondaryCellTextColor!])
        
        return textField
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
        if let newValue = formatter.number(from: self.textField.text ?? "")?.doubleValue {
            self.textField.text = String(newValue)
            self.value = Decimal(newValue)
        } else {
            self.textField.text = formatter.string(for: delegate?.standardValue(in: self))!
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
    
    /// ensures that the endEditing methods are called on return
    /// - NOTE: This only applies when using a different keyboard cause there is no enter key on the .decimalPad
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
    /// delete the textFields contents when editing did begin so the placeholder can be shown as it provides information to the user what purpose the textField serves
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
}
