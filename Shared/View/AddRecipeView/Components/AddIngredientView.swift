// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
