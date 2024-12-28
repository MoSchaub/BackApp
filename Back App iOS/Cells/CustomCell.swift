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
    
    public func chevronUpCell(text: String) {
        let image = UIImage(systemName: "chevron.up")
        image?.applyingSymbolConfiguration(.init(textStyle: .body, scale: .large))
        
        textLabel?.text = text
        accessoryView = UIImageView(image: image)
        accessoryView?.tintColor = UIView.appearance().tintColor
    }
    
}
