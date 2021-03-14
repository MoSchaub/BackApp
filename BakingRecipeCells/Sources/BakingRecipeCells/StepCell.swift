//
//  StepCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BakingRecipeFoundation

public class StepCell: DetailCell {
    
    private var step: Step
    
    public init(step: Step ,reuseIdentifier: String?) {
        self.step = step
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        let rootView = StepRow(step: step)
        let hostingController = UIHostingController(rootView: rootView)
        
        // set clear so the view takes the cells background color
        hostingController.view.backgroundColor = .clear
        
        contentView.addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }
}
