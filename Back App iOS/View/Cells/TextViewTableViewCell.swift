//
//  TextViewTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 13.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

class TextViewTableViewCell: UITableViewCell {
    @Binding private var textContent: String
    private var placeholder: String
    
    private var textView = UITextView()

    init(textContent: Binding<String>, placeholder: String, reuseIdentifier: String?) {
        self._textContent = textContent
        self.placeholder = placeholder
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError(Strings.init_coder_not_implemented)
    }
    
    private func setup() {
        self.addSubview(textView)
        textView.fillSuperview()
        
        self.textView.addDoneButton(target: self, selector: #selector(tapDone))
        setText()
        textView.delegate = self
        textView.accessibilityIdentifier = placeholder
        
        setUpLinkDetection()
        
        addTextFieldGestureRecognizer()
        
        setUpCellDesign()
    }
    
    private func setUpLinkDetection() {
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
    }
    
    private func setText(starting: Bool = false) {
        if !starting, textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body)
            ])
            textView.attributedText = attributedPlaceholder
            textView.textColor = .secondaryLabel
        } else {
            textView.text = textContent
            textView.textColor = .label
        }
    }
    
    private func addTextFieldGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(textViewTapped))
        recognizer.delegate = self
        recognizer.numberOfTapsRequired = 1
        textView.addGestureRecognizer(recognizer)
    }
    
    private func setUpCellDesign() {
        textView.backgroundColor = UIColor(named: Strings.backgroundColorName)!
        textView.tintColor = .red
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    @objc private func tapDone(sender: Any) {
        self.textView.endEditing(true)
    }
    
    @objc private func textViewTapped(_ aRecognizer: UITapGestureRecognizer?) {
        textView.dataDetectorTypes = []
        textView.isEditable = true
        textView.becomeFirstResponder()
    }

}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.textContent = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setUpLinkDetection()
        setText()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setText(starting: true)
        return true
    }
}
