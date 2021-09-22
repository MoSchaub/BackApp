//
//  TextViewCell.swift
//  
//
//  Created by Moritz Schaub on 06.10.20.
//

import SwiftUI
import BakingRecipeStrings

// uitableviewcell with a textview
public class TextViewCell: CustomCell {

    /// text of the cell
    /// - Note: This is synced with textView.text
    @Binding private var textContent: String

    /// the placeholder for the textView
    private var placeholder: String

    /// the textView, the main content, of this cell
    private var textView: UITextView

    //determines wether the textView should be editable or just visual
    private var isEditable: Bool

    ///managing undo state
    private let _undoManager = UndoManager()
    public override var undoManager: UndoManager {
        return _undoManager
    }

    /// button for undoing used in the toolbar
    private lazy var undoButton: UIBarButtonItem = {
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undo))
        undoButton.isEnabled = false
        return undoButton
    }()

    /// button for redoing used in the toolbar
    private lazy var redoButton: UIBarButtonItem = {
        let redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redo))
        redoButton.isEnabled = false
        return redoButton
    }()

    /// button for stop editing the textView
    private lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneButton.tintColor = .baTintColor
        return doneButton
    }()

    /// initalizer
    /// - Parameter textContent: the content of the textView
    /// - Parameter placeholder: the placeholder for the textView
    /// - Parameter reuseIdentifier: a reuseIdentifier for reusing the cell
    /// - Parameter isEditable: wether the textView should be editable, by default this is true
    public init(textContent: Binding<String>, placeholder: String, reuseIdentifier: String?, isEditable: Bool = true) {
        self.textView = UITextView()
        self._textContent = textContent
        self.placeholder = placeholder
        self.isEditable = isEditable
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        /// add the textView to the cell
        addSubview(textView)

        configureTextView()

    }

}

private extension TextViewCell {
    private var textContentEmpty: Bool {
        textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


private extension TextViewCell {

    func configureTextView() {
        //delegate
        self.textView.delegate = self

        // design
        self.setupTextViewDesign()

        // link detection and toolbar if editable
        setupLinkDetection()

        if self.isEditable {

            // make textField editable if tapped
            self.addTextFieldGestureRecognizer()
            self.addToolbarWithButtons()
        }
    }
}

private extension TextViewCell {

    /// sets up the constraints and design of the textView
    func setupTextViewDesign() {
        //contraints
        self.textView.fillSuperview()

        //textColor, text and font
        self.setTextViewTextFromTextContent()

        //background color
        self.textView.backgroundColor = UIColor.cellBackgroundColor

        //baTintColor
        self.textView.tintColor = UIColor.baTintColor
    }

    /// sets the text for textView from textContent, the textColor and the font
    func setTextViewTextFromTextContent() {
        DispatchQueue.main.async {
            if !self.textContentEmpty {
                self.textView.attributedText = NSAttributedString(string: self.textContent, attributes: [.foregroundColor : UIColor.primaryCellTextColor!])
            }

            self.textView.font = UIFont.preferredFont(forTextStyle: .body)
            self.textView.textColor = .primaryCellTextColor
            self.textView.placeholder = self.placeholder
            self.textView.placeholderColor = .secondaryCellTextColor

        }
    }
}

//MARK: - Link Detection and Editable
private extension TextViewCell {

    func setupLinkDetection() {
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
    }

    private func addTextFieldGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(textViewDidTapped))
        recognizer.delegate = self
        recognizer.numberOfTapsRequired = 1
        textView.addGestureRecognizer(recognizer)
    }


    func placeCursor(_ myTextView: UITextView, _ location: CGPoint) {
        // place the cursor on tap position
        if let tapPosition = myTextView.closestPosition(to: location) {
            let uiTextRange = myTextView.textRange(from: tapPosition, to: tapPosition)

            if let start = uiTextRange?.start, let end = uiTextRange?.end {
                let loc = myTextView.offset(from: myTextView.beginningOfDocument, to: tapPosition)
                let length = myTextView.offset(from: start, to: end)
                myTextView.selectedRange = NSMakeRange(loc, length)
            }
        }
    }

    func changeTextViewToNormalState() {
        textView.isEditable = true
        textView.dataDetectorTypes = []
        textView.becomeFirstResponder()
    }

    @objc func textViewDidTapped(_ recognizer: UITapGestureRecognizer) {
        guard let myTextView = recognizer.view as? UITextView else {
            return
        }
        let layoutManager = myTextView.layoutManager
        var location = recognizer.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left
        location.y -= myTextView.textContainerInset.top

        let glyphIndex: Int = myTextView.layoutManager.glyphIndex(for: location, in: myTextView.textContainer, fractionOfDistanceThroughGlyph: nil)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: myTextView.textContainer)

        if glyphRect.contains(location) {
            let characterIndex: Int = layoutManager.characterIndexForGlyph(at: glyphIndex)
            let attributeName = NSAttributedString.Key.link
            let attributeValue = myTextView.textStorage.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            if let url = attributeValue as? URL {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("There is a problem in your link.")
                }
            } else {
                // place the cursor to tap position
                placeCursor(myTextView, location)

                // back to normal state
                changeTextViewToNormalState()
            }
        } else {
            changeTextViewToNormalState()
        }
    }
}

//MARK: - Toolbar and Undo/Redo
private extension TextViewCell {
    func addToolbarWithButtons() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.setItems([undoButton, redoButton, UIBarButtonItem.flexible, doneButton], animated: true)
        textView.inputAccessoryView = toolBar
    }

    private func updateUndoRedoButtons() {
        DispatchQueue.main.async {
            self.undoButton.isEnabled = self.undoManager.canUndo
            self.redoButton.isEnabled = self.undoManager.canRedo
        }
    }

    @objc private func undo() {
        undoManager.undo()
        updateUndoRedoButtons()
    }

    @objc private func redo() {
        undoManager.redo()
        updateUndoRedoButtons()
    }

    @objc private func done() {
        textView.endEditing(true)
    }
}

private extension TextViewCell {
    
    func textDidChange(from previousText: String, previousCursorPosition: Int) {
        DispatchQueue.main.async {
            self.textContent = self.textView.text
        }

        self.undoManager.registerUndo(withTarget: self) { target in
            let currentText: String = self.textContent
            let currentCursorPosition = self.textView.getCursorPosition()
            DispatchQueue.main.async {
                self.textView.text = previousText
                self.textView.setCursor(to: previousCursorPosition)
            }
            self.textDidChange(from: currentText, previousCursorPosition: currentCursorPosition)
        }

        self.updateUndoRedoButtons()
    }
}

extension TextViewCell: UITextViewDelegate {

    // update textContent if textView.text changes
    public func textViewDidChange(_ textView: UITextView) {
        textDidChange(from: self.textContent, previousCursorPosition: self.textView.getCursorPosition())
    }


    public func textViewDidBeginEditing(_ textView: UITextView) {
        // remove placeholder when editing did begin
        DispatchQueue.main.async {
            if self.textContentEmpty {
                textView.text = ""
            }
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        setTextViewTextFromTextContent()
        setupLinkDetection()
    }
}
