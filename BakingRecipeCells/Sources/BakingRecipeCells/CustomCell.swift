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
        self.backgroundColor = UIColor.cellBackgroundColor
        
        textLabel?.textColor = .primaryCellTextColor
        
        self.selectedBackgroundView = UIView(backgroundColor: .selectionCellBackgroundColor)
        
        selectionStyle = .blue
    }
    
    public func chevronUpCell(text: String) {
        let image = UIImage(systemName: "chevron.up")
        image?.applyingSymbolConfiguration(.init(textStyle: .body, scale: .large))
        
        textLabel?.text = text
        accessoryView = UIImageView(image: image)
        accessoryView?.tintColor = .tintColor
    }
    
}
