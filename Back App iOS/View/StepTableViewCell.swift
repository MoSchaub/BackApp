//
//  StepTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

class StepTableViewCell: UITableViewCell {
    
    var view: UIView!
    
    func setUpCell(for step: Step, recipe: Recipe, roomTemp: Int) {
        view = UIHostingController(rootView: StepRow(step: step, recipe: recipe, roomTemp: roomTemp)).view
        view.frame = .zero
        contentView.addSubview(view)
        setViewConstraints()
        accessoryType = .disclosureIndicator
    }
    
    private func setViewConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
    }

}
