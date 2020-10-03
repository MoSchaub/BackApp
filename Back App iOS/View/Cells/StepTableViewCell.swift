//
//  StepTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeCore

class StepTableViewCell: UITableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let indicatorButton = self.allSubviews.compactMap({ $0 as? UIButton }).last {
            let image = indicatorButton.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
            indicatorButton.setBackgroundImage(image, for: .normal)
            indicatorButton.tintColor = .label
        }
    }
    
    func setUpCell(for step: Step) {
        let rootView = StepRow(step: step)
        let hostingController = UIHostingController(rootView: rootView)
        contentView.addSubview(hostingController.view)
        hostingController.view.fillSuperview()
        hostingController.view.backgroundColor = UIColor(named: Strings.backgroundColorName)
        
        accessoryType = .disclosureIndicator
        backgroundColor = UIColor(named: Strings.backgroundColorName)!
        selectionStyle = .none
    }

}
