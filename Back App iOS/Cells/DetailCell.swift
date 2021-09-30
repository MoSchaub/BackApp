//
//  DetailCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit

public class DetailCell: CustomCell {
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    public override init(text: String, reuseIdentifier: String) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.textLabel?.text = text
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
        self.detailTextLabel?.textColor = .secondaryCellTextColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let indicatorButton = self.allSubviews.compactMap({ $0 as? UIButton }).last {
            let image = indicatorButton.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
            indicatorButton.setBackgroundImage(image, for: .normal)
            indicatorButton.tintColor = .baTintColor
        }
    }
}
