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
    let step: Step
    let roomTemp: Double = Standarts.roomTemp
    let scaleFactor: Double?
    
    var body: some View {
        HStack {
            Text(ingredient.name).lineLimit(1)
            Spacer()
            if ingredient.type == .bulkLiquid{
                Text(tempText).lineLimit(1)
                Spacer()
            } else{
                EmptyView()
            }
            Text(ingredient.scaledFormattedAmount(with: scaleFactor ?? 1)).lineLimit(1)
        }
        .foregroundColor(Color(UIColor.primaryCellTextColor!))
    }

    private var tempText: String {
        if let temp = try? step.temperature(roomTemp: roomTemp, kneadingHeating: Standarts.kneadingHeating, databaseReader: BackAppData.shared.databaseReader) {
            return temp.formattedTemp
        } else {
            print("Error getting the temp for the ingredient with name: \(ingredient.formattedName)")
            return "error"
        }
    }
}
