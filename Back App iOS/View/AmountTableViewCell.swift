//
//  AmountTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class AmountTableViewCell: UITableViewCell {

    var textField = UITextField(frame: .zero)
    
    private var textChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(textField)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextField() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(updateText), for: .editingDidEnd)
        setTextFieldConstraints()
    }
    
    private func setTextFieldConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    
    func setUp(with ingredient: Ingredient, format: @escaping (String) -> String ) {
        textField.text = "\(ingredient.amount)"
        textField.placeholder = "Menge"
        selectionStyle = .none
        textChanged = { text in
            self.textField.text = format(text)
        }
        self.textChanged!(textField.text ?? "0g" )
    }
    
    func setUp(with recipe: Recipe, format: @escaping (String) -> String ) {
        textField.text = "\(recipe.timesText)"
        textField.placeholder = "Anzahl an Broten, Brötche, etc"
        selectionStyle = .none
        textChanged = { text in
            self.textField.text = format(text)
        }
        self.textChanged!(textField.text ?? "" )
    }

}

extension AmountTableViewCell: UITextFieldDelegate {
    @objc func updateText() {
        if let textChanged = textChanged, let text = textField.text {
            textChanged(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
}
