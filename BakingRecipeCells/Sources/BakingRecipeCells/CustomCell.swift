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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setup() {
        self.backgroundColor = UIColor.backgroundColor
        
        textLabel?.textColor = .cellTextColor
        
        selectionStyle = .none
    }
    
}
