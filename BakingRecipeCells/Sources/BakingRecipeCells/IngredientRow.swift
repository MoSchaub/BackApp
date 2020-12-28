//
//  IngredientRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeUIFoundation
import BackAppCore

struct IngredientRow: View {
    
    let ingredient: Ingredient
    let roomTemp: Int
    let appData = BackAppData()
    
    var body: some View {
        HStack {
            Text(ingredient.name).lineLimit(1)
            Spacer()
            if ingredient.type == .bulkLiquid{
                Text("\(appData.temperature(for: ingredient, roomTemp: roomTemp))"  + "° C").lineLimit(1)
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.formattedAmount).lineLimit(1)
        }
        .foregroundColor(Color(.cellTextColor))
    }
}
