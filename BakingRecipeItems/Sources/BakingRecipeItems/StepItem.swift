//
//  StepItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeFoundation

public class StepItem: Item {
    public var step: Step
    
    public init(id: UUID = UUID(), step: Step) {
        self.step = step
        super.init(id: id)
    }
}
