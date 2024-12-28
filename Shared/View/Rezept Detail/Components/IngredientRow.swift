// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeFoundation

struct IngredientRow: View {
    
    let ingredient: Ingredient
    let step: Step
    let roomTemp: Int
    
    var body: some View {
        HStack {
            Text(ingredient.name).lineLimit(1)
            Spacer()
            if ingredient.isBulkLiquid{
                Text("\(step.themperature(for: ingredient, roomThemperature: roomTemp))" + "° C").lineLimit(1)
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.formattedAmount).lineLimit(1)
        }
    }
}
