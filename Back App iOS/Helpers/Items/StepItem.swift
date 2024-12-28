// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BakingRecipeFoundation

class StepItem: Item {
    var step: Step
    
    init(id: UUID = UUID(), step: Step) {
        self.step = step
        super.init(id: id)
    }
}
