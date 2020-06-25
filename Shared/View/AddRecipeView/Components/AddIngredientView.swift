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
    @Binding var step: Step
    @EnvironmentObject private var recipeStore: RecipeStore
    let recipe: Recipe
    
    var body: some View{
        return IngredientDetail(ingredient: self.$ingredient, step: self.$step, recipe: recipe, creating: true).environmentObject(recipeStore)
    }
}
