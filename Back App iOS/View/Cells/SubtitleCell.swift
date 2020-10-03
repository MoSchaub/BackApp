//
//  SubtitleCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 19.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeStrings

class SubtitleCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = UIColor(named: Strings.backgroundColorName)!
        detailTextLabel?.tintColor = .label
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let indicatorButton = self.allSubviews.compactMap({ $0 as? UIButton }).last {
            let image = indicatorButton.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
            indicatorButton.setBackgroundImage(image, for: .normal)
            indicatorButton.tintColor = .label
        }
    }
    
}
