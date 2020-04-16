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
                Text(step.name).font(.headline)
                Spacer()
                Text(step.formattedTime).secondary()
                if self.inLink{
                    Image(systemName: "chevron.right")
                }
            }.padding(.horizontal)
            
            ForEach(step.ingredients){ ingredient in
                HStack{
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp, inLink: false, background: false)
                }.padding([.top, .leading, .trailing])
            }
            
            ForEach(step.subSteps){substep in
                HStack{
                    Text(substep.name)
                    Spacer()
                    Text("\(substep.totalAmount)")
                }.padding(.horizontal)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(step.notes)
                        .lineLimit(nil)
                    Spacer()
                }
            }.padding([.horizontal,.top])
        }
        .neomorphic()
    }
}

