// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
