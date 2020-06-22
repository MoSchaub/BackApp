//
//  AddRecipe.swift
//  BackApp iOS
//
//  Created by Moritz Schaub on 14.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddRecipe: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var recipeStore: RecipeStore
    
    let addRecipe: (Recipe) -> Void
    
    init( addRecipe: @escaping (Recipe) -> Void){
        self.addRecipe = addRecipe
        self.recipeStore = RecipeStore()
        let recipe = Recipe(name: "", brotValues: [], inverted: false, dateString: "", isFavourite: false, category: recipeStore.categories.first!)
        recipeStore.addRecipe(recipe: recipe)
        recipeStore.selectedRecipe = recipe
    }
    var addButton: some View {
        Button(action: {
            self.save()
        }){
            Text("hinzufügen").padding(.leading)
        }.disabled(recipeStore.recipes.first!.steps.isEmpty)
    }
    
    var cancelButton: some View{
        Button("Abbrechen"){
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        #if os(iOS)
        return NavigationView{
            RecipeDetail(recipe: $recipeStore.recipes[recipeStore.selectedRecipeIndex()!], creating: true, addRecipe: addRecipe, dismiss: dissmiss)
                .environmentObject(recipeStore)
        }
        #elseif os(macOS)
        return RecipeDetail(recipe: $recipeStore.recipes[recipeStore.selectedRecipeIndex()!], creating: true, addRecipe: addRecipe, cancel: dissmiss)
            .environmentObject(recipeStore)
            .frame(minWidth: 600, idealWidth: 700, maxWidth: .infinity, minHeight: 700, idealHeight: 700, maxHeight: .infinity, alignment: .leading)
        #endif
    }

    func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func save(){
        self.addRecipe(recipeStore.recipes.first!)
        self.presentationMode.wrappedValue.dismiss()
    }
    
}
