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
    let roomTemp: Double = Standarts.roomTemp
    let appData: BackAppData
    let scaleFactor: Double?
    
    var body: some View {
        HStack {
            Text(ingredient.name).lineLimit(1)
            Spacer()
            if ingredient.type == .bulkLiquid{
                Text(appData.temperature(for: ingredient, roomTemp: roomTemp).formattedTemp).lineLimit(1)
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.scaledFormattedAmount(with: scaleFactor ?? 1)).lineLimit(1)
        }
        .foregroundColor(Color(UIColor.primaryCellTextColor!))
    }
}
