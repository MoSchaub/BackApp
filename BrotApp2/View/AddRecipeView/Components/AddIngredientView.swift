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
    
    @EnvironmentObject private var recipeStore: RecipeStore
    let recipe: Recipe
    
    @Binding var step: Step
    
    #if os(iOS)
    @Environment(\.presentationMode) var presentationMode
    #endif

    var body: some View{
        #if os(iOS)
        return IngredientDetail(ingredient: self.$ingredient, step: self.$step, recipe: recipe, deleteEnabled: false).environmentObject(recipeStore)
        #elseif os(macOS)
        return IngredientDetail(ingredient: self.$ingredient, step: self.$step, recipe: recipe, creating: true).environmentObject(recipeStore)
        #endif
        
        
    }
}
