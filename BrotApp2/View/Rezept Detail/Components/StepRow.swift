//
//  StepRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct StepRow: View {
    
    let step: Step
    let recipe: Recipe
    let inLink: Bool
    let roomTemp: Int
    
    var body: some View {
       VStack{
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(step.name).font(.headline)
                    Text(step.formattedTime).secondary()
                }
                Spacer()
                Text(self.recipe.formattedStartDate(for: step))
                if self.inLink{
                    Image(systemName: "chevron.right")
                }
            }.padding(.horizontal)
            
            ForEach(step.ingredients){ ingredient in
                HStack{
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp)
                }.padding(.horizontal)
            }
        }
        .padding()
        .background(BackgroundGradient())
    }
}

