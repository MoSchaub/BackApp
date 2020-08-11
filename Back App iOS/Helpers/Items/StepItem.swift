//
//  StepItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipe

class StepItem: Item {
    var step: Step
    
    init(id: UUID = UUID(), step: Step) {
        self.step = step
        super.init(id: id)
    }
}
