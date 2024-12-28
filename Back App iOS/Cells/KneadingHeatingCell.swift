// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  KneadingHeatingCell.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import UIKit
import BakingRecipeStrings
import Combine

/// the number formatter
private var formatter: NumberFormatter {
    let nv = NumberFormatter()
    nv.numberStyle = .decimal
    return nv
}

public class KneadingHeatingCell: CustomCell {
    
    private var value: Double = 0 {
        didSet {
            valueChangedPublisher.send((self, value))
        }
    }
    
    private lazy var textField = makeTextField()
    
    ///whether the defaultValue is going to be set the fist time
    private lazy var firstTime = true
    
    /// default value if no correct value was entered
    /// - Note: This one should be provided by the enclosing ViewController
    public var defaultValue: Double = 0 {
        didSet {
            if firstTime {
                self.firstTime = false
                self.setupCell()
            }
        }
    }
    
    /// notify the enclosing viewController that the value changed
    public var valueChangedPublisher = PassthroughSubject<(KneadingHeatingCell, Double), Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
 
}

private extension KneadingHeatingCell {
    func setupCell() {
        selectionStyle = .none
        configureTextField()
    }
    
    func makeTextField() -> UITextField {
        let textField = UITextField(frame: .zero)
        
        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
        textField.addDoneButton(title: Strings.EditButton_Done, target: self, selector: #selector(tapDone))
        
        textField.tintColor = .baTintColor
        textField.textColor = .primaryCellTextColor
        textField.attributedPlaceholder = NSAttributedString(string: Strings.kneadingHeatCellPlaceholder, attributes: [.foregroundColor : UIColor.secondaryCellTextColor!])
        
        return textField
    }
    
    func configureTextField() {
        addSubview(textField)
        setTextFieldConstraints()
        updateText()
    }
    
    func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    }
}

extension KneadingHeatingCell: UITextFieldDelegate {
    
    //called when editing ended
    @objc private func updateText() {
        if let newValue = formatter.number(from: self.textField.text ?? "")?.doubleValue {
            self.textField.text = String(newValue)
            self.value = newValue
        } else {
            self.textField.text = String(defaultValue)
        }
    }
    
    // for done Button
    @objc private func tapDone(sender: Any) {
        self.textField.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
}
