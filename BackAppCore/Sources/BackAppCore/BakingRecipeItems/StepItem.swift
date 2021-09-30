//
//  StepItem.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Foundation
import BakingRecipeFoundation

public class StepItem: Item, Decodable {
    public var step: Step
    
    public init(step: Step) {
        self.step = step
        super.init(id: Int(step.id!))
    }

    private enum CodingKeys: CodingKey {
        case step
    }

    public required init(from decoder: Decoder) throws {
        self.step = try decoder.container(keyedBy: CodingKeys.self).decode(Step.self,forKey: .step)
    }
}
