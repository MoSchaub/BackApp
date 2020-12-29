//
//  SubtitleCell.swift
//  
//
//  Created by Moritz Schaub on 06.10.20.
//

import UIKit

public class SubtitleCell: CustomCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        detailTextLabel?.textColor = .secondaryCellTextColor
        accessoryType = .disclosureIndicator
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        if let indicatorButton = self.allSubviews.compactMap({ $0 as? UIButton }).last {
//            let image = indicatorButton.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
//            indicatorButton.setBackgroundImage(image, for: .normal)
//            indicatorButton.tintColor = .tintColor
//        }
//    }
    
}
