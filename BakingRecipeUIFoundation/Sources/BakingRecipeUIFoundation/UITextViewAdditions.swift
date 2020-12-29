//
//  UITextViewAdditions.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeStrings

public extension UITextView {
    func addDoneButton(target: Any, selector: Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: Strings.EditButton_Done, style: .plain, target: target, action: selector)
        barButton.tintColor = .tintColor
        toolBar.setItems([flexible,barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
