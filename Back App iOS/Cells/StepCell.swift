// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  StepCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BackAppCore
import BakingRecipeFoundation

public class StepCell: DetailCell {
    
    private var vstack: UIStackView
    private var editMode: Bool
    
    public init(vstack: UIStackView, reuseIdentifier: String, editMode: Bool = true) {
        self.vstack = vstack
        self.editMode = editMode
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        if !editMode {
            self.accessoryType = .none
            self.selectionStyle = .none
            self.isUserInteractionEnabled = editMode
        }
        self.contentView.addSubview(vstack)
        vstack.fillSuperview(padding: .init(top: 8, left: 20, bottom: 8, right: 8))
    }


}
