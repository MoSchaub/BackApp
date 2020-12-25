//
//  StepRow.swift
//
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BackAppCore

public struct StepRow: View {
    
    let step: Step
    let roomTemp = UserDefaults.standard.integer(forKey: "roomTemp")
    let appData = BackAppData()
    
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        VStack{
            HStack {
                VStack(alignment: .leading) {
                    Text(step.formattedName).font(.headline).lineLimit(1)
                    Text(step.formattedTemp(roomTemp: roomTemp)).secondary()
                }
                Spacer()
                Text(step.formattedDuration).secondary()
            }
            
            ForEach(appData.ingredients(with: step.id)) { ingredient in
                IngredientRow(ingredient: ingredient, roomTemp: roomTemp)
            }
            
            ForEach(appData.substeps(for: step.id)) { substep in
                HStack {
                    Text(substep.formattedName)
                    Spacer()
                    Text(substep.formattedTemp(roomTemp: roomTemp))
                    Spacer()
                    Text(appData.totalFormattedMass(for: substep.id))
                }
            }
            
            HStack {
                Text(step.notes)
                Spacer()
            }
        }
        .foregroundColor(Color(.cellTextColor))
        .padding()
        .padding(.trailing)
    }
    
    public init(step: Step) {
        self.step = step
    }
}
//
//struct StepRow_Previews: PreviewProvider {
//
//    static var recipe: Recipe{
//        let i = Ingredient(name: "Mehl", amount: 100, type: .flour)
//        let b2 = Step(name: "Sub", time: 60, ingredients: [], themperature: 20)
//        var b = Step(name: "Schritt1", time: 60, ingredients: [i], themperature: 20)
//        b.subSteps.append(b2)
//        return Recipe(name: "Test", brotValues: [b], inverted: false, dateString: "", isFavourite: false)
//    }
//
//    static var previews: some View {
//        StepRow(step: recipe.steps.first!)
//    }
//}
