//
//  AddRecipeView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 08.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddRecipeView: View {
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @Binding var isPresented: Bool
    
    @State private var recipe = Recipe(name: "", brotValues: [], inverted: false, dateString: "", isFavourite: false, category: Category.example)
    
    var disabled: Bool{
        recipe.name.isEmpty || recipe.steps.isEmpty || recipeStore.contains(recipe: recipe)
    }
    
    var title: String{
        if recipe.name.isEmpty{
            return "Rezept hinzufügen"
        } else {
            return recipe.name
        }
    }
    var addButton: some View {
        Button(action: {
            self.recipeStore.save(recipe: self.recipe)
        }){
            Text("hinzufügen").neomorphic()
        }.disabled(self.disabled)
    }
    
    var body: some View {
        NavigationView{
            RezeptDetail(recipe: self.$recipe, isDetail: false).environmentObject(recipeStore)
                .navigationBarTitle(self.title)
                .navigationBarItems(
                    leading: Button("Abbrechen"){ self.isPresented = false }.foregroundColor(.accentColor),
                    trailing: Button("OK"){ self.recipeStore.save(recipe: self.recipe); self.isPresented = false }.disabled(self.disabled)
                )
        }
        .onAppear(){
            self.recipe.category = self.recipeStore.categories.first ?? Category.example
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeView(isPresented: .constant(true)).environmentObject(RecipeStore.example).environment(\.colorScheme, .dark)
    }
}
