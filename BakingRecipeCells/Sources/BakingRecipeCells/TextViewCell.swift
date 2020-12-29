//
//  TextViewCell.swift
//  
//
//  Created by Moritz Schaub on 06.10.20.
//

import SwiftUI
import BakingRecipeStrings

public class TextViewCell: CustomCell {
    
    /// text of the textView
    @Binding private var textContent: String
    
    /// placeholderText
    private var placeholder: String
    
    /// textView
    private var textView = UITextView()
    
    public init(textContent: Binding<String>, placeholder: String, reuseIdentifier: String?) {
        self._textContent = textContent
        self.placeholder = placeholder
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        addSubview(textView)
        configureTextView()
    }
    
}

private extension TextViewCell {
    
    func configureTextView() {
        
        textView.delegate = self
        textView.accessibilityIdentifier = placeholder
        
        textView.addDoneButton(target: self, selector: #selector(tapDone))
        
        setUpLinkDetection()
        
        addTextFieldGestureRecognizer()
        
        setUpCellDesign()
        
        setTextViewConstraints()
    }
    
    private func setTextViewConstraints() {
        textView.fillSuperview()
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
            textView.textColor = .secondaryCellTextColor
        } else {
            textView.text = textContent
            textView.textColor =  .primaryCellTextColor
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
        textView.backgroundColor = UIColor.cellBackgroundColor
        textView.tintColor = .tintColor
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        setText()
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


extension TextViewCell: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        self.textContent = textView.text
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        setUpLinkDetection()
        setText()
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setText(starting: true)
        return true
    }
    
}
