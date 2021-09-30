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

extension View {
    @ViewBuilder
    func optionalModifier<T:View>(condition: Bool, modified: @escaping (Self) -> T ) -> some View {
        if condition {
            modified(self)
        } else {
            self
        }
    }
}

@ViewBuilder
public func substepIngredientRows(for step: Step, scaleFactor: Double? = nil) -> some View {
    ForEach(step.sortedSubsteps(reader: BackAppData.shared.databaseReader)) { substep in
        SubstepRow(substep: substep, scaleFactor: scaleFactor ?? 1)

    }
    ForEach(step.ingredients(reader: BackAppData.shared.databaseReader)) { ingredient in
        IngredientRow(ingredient: ingredient, step: step, scaleFactor: scaleFactor)
            .optionalModifier(condition: scaleFactor != nil) {
                $0.padding(.vertical, 5)
            }
    }
}

public struct StepRow: View {

    let step: Step
    let roomTemp = Standarts.roomTemp
    
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
            substepIngredientRows(for: step)
            HStack {
                Text(step.notes)
                Spacer()
            }
        }
        .foregroundColor(Color(UIColor.primaryCellTextColor!))
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
