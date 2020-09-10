//
//  StepRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

struct StepRow: View {
    
    let step: Step
    let roomTemp = UserDefaults.standard.integer(forKey: "roomTemp")
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            HStack {
                Text(step.formattedName).font(.headline).lineLimit(1)
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
            Text(step.notes)
                .lineLimit(2)
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
