//
//  CategoryPicker.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct CategoryPicker: View {
    
    @Binding var recipe: Recipe
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<self.recipeStore.categories.count, id: \.self){ n in
                    Button(action: {
                        self.recipe.category = self.recipeStore.categories[n]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }){
                        HStack {
                            Text("\(self.recipeStore.categories[n].name)")
                            
                            Spacer()
                            if self.recipe.category == self.recipeStore.categories[n]{
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                        .padding(.bottom)
                    }.buttonStyle(PlainButtonStyle())
                    
                }

            }
        }
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(recipe: .constant(Recipe.example)).environmentObject(RecipeStore.example)
    }
}
