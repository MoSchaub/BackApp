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
    
    private var step: Step
    private var editMode: Bool
    
    public init(step: Step, reuseIdentifier: String, editMode: Bool = true) {
        self.step = step
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
        }

        let rootView = StepRow(step: step)
        let hostingController = UIHostingController(rootView: rootView)
        
        // set clear so the view takes the cells background color
        hostingController.view.backgroundColor = .clear
        
        contentView.addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }
}
