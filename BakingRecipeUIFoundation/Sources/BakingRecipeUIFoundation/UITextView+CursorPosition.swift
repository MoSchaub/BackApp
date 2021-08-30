//
//  UITextView+CursorPosition.swift
//  
//
//  Created by Moritz Schaub on 30.08.21.
//

import UIKit

public extension UITextView {
    func getCursorPosition() -> Int {
        if let selectedRange = self.selectedTextRange {

            let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)

            return cursorPosition
        } else {
            return self.offset(from: self.beginningOfDocument, to: self.endOfDocument)
        }
    }

    func setCursor(to position: Int) {
        if let newPosition = self.position(from: self.beginningOfDocument, offset: position) {

            self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
        }
    }
}
