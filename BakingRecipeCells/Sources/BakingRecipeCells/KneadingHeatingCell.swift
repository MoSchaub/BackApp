//
//  KneadingHeatingCell.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import UIKit
import BakingRecipeStrings

public protocol KneadingHeatingCellDelegate: class {
    
    func kneadingHeatingCell(_ cell: KneadingHeatingCell, didChangeValue value: Double)
    
    func startValue(for cell: KneadingHeatingCell) -> Double
    
}

/// the number formatter
private var formatter: NumberFormatter {
    let nv = NumberFormatter()
    nv.numberStyle = .decimal
    return nv
}

public class KneadingHeatingCell: CustomCell {
    
    private var value: Double = 0 {
        didSet {
            delegate?.kneadingHeatingCell(self, didChangeValue: value)
        }
    }
    
    private lazy var textField = makeTextField()
    
    open weak var delegate: KneadingHeatingCellDelegate? {
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
        
        textField.tintColor = .tintColor
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
            let defaultValue: Double = 0
            self.textField.text = String(delegate?.startValue(for: self) ?? defaultValue)
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
