//
//  StepTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

class StepTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell(for step: Step) {
        let rootView = StepRow(step: step)
        let hostingController = UIHostingController(rootView: rootView)
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
        accessoryType = .disclosureIndicator
    }

}
