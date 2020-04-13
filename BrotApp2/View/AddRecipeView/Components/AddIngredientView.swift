//
//  AddIngredientView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddIngredientView: View{
    @State private var ingredient = Ingredient(name: "", amount: 0)
    @State private var amountText = "0.00 g"
    
    @Binding var step: Step
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        IngredientDetail(ingredient: self.$ingredient, step: self.$step, deleteEnabled: false)
    }
    
    func save(){
        if let index = self.step.ingredients.firstIndex(where: {$0.id == self.ingredient.id}){
            self.step.ingredients[index] = self.ingredient
        } else {
            self.step.ingredients.append(self.ingredient)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        AddIngredientView(step: .constant(Step(name: "", time: 60, ingredients: [], themperature: 20)))
    }
}
