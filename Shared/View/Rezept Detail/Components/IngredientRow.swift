//
//  IngredientRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct IngredientRow: View {
    
    let ingredient: Ingredient
    let step: Step
    let roomTemp: Int
    
    var body: some View {
        HStack {
            Text(ingredient.name)
            Spacer()
            if ingredient.isBulkLiquid{
                Text("\(step.themperature(for: ingredient, roomThemperature: roomTemp))" + "° C")
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.formattedAmount)
        }
    }
}
