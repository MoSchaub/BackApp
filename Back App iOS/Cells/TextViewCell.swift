// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  TextViewCell.swift
//  
//
//  Created by Moritz Schaub on 06.10.20.
//

import SwiftUI

// uitableviewcell with a textview
public class TextViewCell: CustomCell, UITextViewDelegate {

    // MARK: Colors
    private var textViewBackgroundColor = UIColor.cellBackgroundColor!
    private var textViewTextColor = UIColor.primaryCellTextColor!
    private var baTintColor = UIColor.baTintColor
    private var placeholderColor = UIColor.secondaryCellTextColor!

    //MARK: main properties
    /// the main content of the cell
    private var textView: UITextView

    private var isEditable: Bool

    private var placeholder: String

    @Binding private var textContent: String


    // MARK: Updating Properties

    ///timer to track wether the user has stopped typing
    var textViewTimer : Timer?

    //minimum intervall between changes that causes an update
    private var typingTimerIntervall = 0.2


    //MARK: Undo Properties

    private let _undoManager = UndoManager()
    public override var undoManager: UndoManager {
        _undoManager
    }

    /// button for undoing used in the toolbar
    private lazy var undoButton: UIBarButtonItem = {
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undo))
        undoButton.isEnabled = false
        undoButton.tintColor = baTintColor
        return undoButton
    }()

    /// button for redoing used in the toolbar
    private lazy var redoButton: UIBarButtonItem = {
        let redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redo))
        redoButton.isEnabled = false
        redoButton.tintColor = baTintColor
        return redoButton
    }()

    /// button for stop editing the textView
    private lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing(_:)))
        doneButton.tintColor = baTintColor
        return doneButton
    }()

    //MARK: Initializer

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
        setupTextView()
    }

    //MARK: Configuring Textview

    private func setupTextView() {
        // add subview
        contentView.addSubview(textView)

        // delegate for editingDidEnd and textViewDidChange
        self.textView.delegate = self

        // constraints
        textView.fillSuperview()

        self.setText()

        //placeholder
        self.textView.placeholder = self.placeholder
        self.textView.placeholderColor = self.placeholderColor

        //font
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)

        //background color
        self.textView.backgroundColor = self.textViewBackgroundColor
        
        //tint color
        self.textView.tintColor = .baTintBackgroundColor

        // auto growing
        self.textView.isScrollEnabled = false

        // link detection and toolbar if editable
        setupLinkDetection()

        // add toolbar Buttons and editing functionality if it should be editable
        if isEditable {
            addTextFieldGestureRecognizer()
        }
    }

    private func setText() {
        self.textView.textColor = textViewTextColor
        self.textView.attributedText = NSAttributedString(string: self.textContent, attributes: [.foregroundColor: textViewTextColor ])
    }

    //MARK: Updating Text

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.textContent = textView.text
        setupLinkDetection()

        NotificationCenter.default.post(name: .viewDoneButtonItemShouldBeRemoved, object: nil)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        let tuple = (textView: self.textView, undo: undoButton, redo: redoButton)
        NotificationCenter.default.post(name: .viewDoneButtonItemShouldBeDisplayed, object: tuple)
    }

    public func textViewDidChange(_ textView: UITextView) {
        textViewTimer?.invalidate()
        textViewTimer = Timer.scheduledTimer(timeInterval: self.typingTimerIntervall, target: self, selector: #selector(typingStopped), userInfo: nil, repeats: false)
    }

    @objc func typingStopped() {
        self.textDidChange(previousText: self.textContent, previousCursorPosition: self.textView.getCursorPosition())
    }

    public func clickTextView() {
        self.textView.becomeFirstResponder()
    }
}

//MARK:  Undo and Redo
private extension TextViewCell {

    /// enables or disables undo and redo buttons if undo or redo are possible
    func updateUndoRedoButtons() {
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

    func registerUndo(previousText: String, previousCursorPosition: Int) {
        self.undoManager.registerUndo(withTarget: self) { target in
            let currentText: String = self.textView.text
            let currentCursorPosition = self.textView.getCursorPosition()

            self.textView.text = previousText
            self.textView.setCursor(to: previousCursorPosition) //TODO: Fix Cursor Position not working correctly in the middle of a string

            self.textDidChange(previousText: currentText, previousCursorPosition: currentCursorPosition)
        }
    }

    private func textDidChange(previousText: String, previousCursorPosition: Int) {
        self.textContent = self.textView.text
        self.textView.textColor = textViewTextColor
        registerUndo(previousText: previousText, previousCursorPosition: previousCursorPosition)
        self.updateUndoRedoButtons()
    }

}

// MARK:  enabling Link Detection while retaining Editing Functionality
private extension TextViewCell {

    func setupLinkDetection() {
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
    }

    func addTextFieldGestureRecognizer() {
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
