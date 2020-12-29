//
//  File.swift
//  
//
//  Created by Moritz Schaub on 12.10.20.
//

import UIKit
import BakingRecipeStrings

@available(iOS 13.0, *)
public extension UIViewController {
    
    func customHeader(enabled: Bool, title: String, frame: CGRect) -> UIStackView {
        func customEditButton(enabled: Bool, in frame: CGRect) -> UIButton {
            let editButton = UIButton(frame: CGRect(x: frame.size.width - 60, y: 10, width: 50, height: 30))
            editButton.setAttributedTitle(attributedTitleForEditButton(isEnabled: enabled), for: .normal)
            editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchDown)
            editButton.isEnabled = enabled
            
            return editButton
        }
        
        func customHeaderLabel(with title: String) -> UILabel {
            let label = UILabel(frame: CGRect(x: 20, y: 10, width: 100, height: 30))
            
            let attributes = [
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote),
                .foregroundColor : UIColor.secondaryLabel,
            ]
            label.attributedText = NSAttributedString(string: title.uppercased(), attributes: attributes)
            
            return label
        }
        
        let stackView = UIStackView(frame: .zero)
        
        stackView.addArrangedSubview(customHeaderLabel(with: title))
        stackView.addArrangedSubview(customEditButton(enabled: enabled, in: frame))
        
        return stackView
    }
    
   
    
    @objc private func toggleEditMode(sender: UIButton) {
        setEditing(!isEditing, animated: true)
        sender.setAttributedTitle(attributedTitleForEditButton(), for: .normal)
    }
    
    private func attributedTitleForEditButton(isEnabled: Bool = true) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: .current),
            .foregroundColor : isEnabled ? UIColor.tintColor! : UIColor.secondaryLabel
        ]
        let titleString = isEditing ? Strings.EditButton_Done : Strings.EditButton_Edit
        return NSAttributedString(string: titleString, attributes: attributes)
    }
    
}

public extension UIViewController {
    func theme(with theme: Theme) {
        if theme.name == "light" {
            self.overrideUserInterfaceStyle = .light
        } else if theme.name == "dark" {
            self.overrideUserInterfaceStyle = .dark
        }
    }
}
