// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import BakingRecipeFoundation

struct StepRow: View {
    
    let step: Step
    let roomTemp = UserDefaults.standard.integer(forKey: "roomTemp")
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            HStack {
                VStack(alignment: .leading) {
                    Text(step.formattedName).font(.headline).lineLimit(1)
                    Text(step.formattedTemp).secondary()
                }
                Spacer()
                Text(step.formattedTime).secondary()
            }
            
            ForEach(step.ingredients){ ingredient in
                IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp)
            }
            
            ForEach(step.subSteps){substep in
                HStack{
                    Text(substep.formattedName)
                    Spacer()
                    Text(substep.formattedTemp)
                    Spacer()
                    Text(substep.totalFormattedAmount)
                }
            }
            HStack {
                Text(step.notes)
                Spacer()
            }
        }
        .padding()
        .padding(.trailing)
    }
}


struct StepRow_Previews: PreviewProvider {
    
    static var recipe: Recipe{
        let i = Ingredient(name: "Mehl", amount: 100)
        let b2 = Step(name: "Sub", time: 60, ingredients: [], themperature: 20)
        var b = Step(name: "Schritt1", time: 60, ingredients: [i], themperature: 20)
        b.subSteps.append(b2)
        return Recipe(name: "Test", brotValues: [b], inverted: false, dateString: "", isFavourite: false)
    }
    
    static var previews: some View {
        StepRow(step: recipe.steps.first!)
    }
}
