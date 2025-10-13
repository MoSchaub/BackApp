// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  CustomCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit
import BakingRecipeUIFoundation

public class CustomCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public init(text: String, reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.textLabel?.text = text
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    internal func setup() {
        self.backgroundColor = UIColor.cellBackgroundColor
        
        textLabel?.textColor = .primaryCellTextColor
        detailTextLabel?.textColor = .secondaryCellTextColor
        
        selectedBackgroundView = UIView(backgroundColor: UIColor.selectedCellBackgroundColor!)
        
        selectionStyle = .blue
    }

    // Always keep custom background when highlighted or selected (fixes white flash/context menu)
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // Use your custom highlight color, or fallback to default
        contentView.backgroundColor = highlighted ? UIColor.selectedCellBackgroundColor : UIColor.cellBackgroundColor
        backgroundColor = contentView.backgroundColor
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Use your custom selected color
        contentView.backgroundColor = selected ? UIColor.selectedCellBackgroundColor : UIColor.cellBackgroundColor
        backgroundColor = contentView.backgroundColor
    }

    // (Optional) For iOS 14+, support cell background configuration
    override public func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        if state.isHighlighted || state.isSelected {
            backgroundColor = UIColor.selectedCellBackgroundColor
            contentView.backgroundColor = UIColor.selectedCellBackgroundColor
        } else {
            backgroundColor = UIColor.cellBackgroundColor
            contentView.backgroundColor = UIColor.cellBackgroundColor
        }
    }
    
    public func chevronUpCell(text: String) {
        let image = UIImage(systemName: "chevron.up")
        image?.applyingSymbolConfiguration(.init(textStyle: .body, scale: .large))
        
        textLabel?.text = text
        accessoryView = UIImageView(image: image)
        accessoryView?.tintColor = UIColor.baTintBackgroundColor
    }
}
