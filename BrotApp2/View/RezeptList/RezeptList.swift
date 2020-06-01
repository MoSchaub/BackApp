//
//  ContentView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptList: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @State private var searching = false
    @State private var searchText = ""
    
    @State private var showingAddRecipeView = false
    @State private var showingRoomTempSheet = false
    
    var addButton: some View{
        Text("Rezept hinzufügen")
            .padding()
            .foregroundColor(.accentColor)
            .onTapGesture {
                self.showingAddRecipeView = true
        }
    }
    
    var body: some View {
        VStack {
            List {
                self.addButton
                ForEach(0..<recipeStore.recipes.count, id: \.self){n in
                    NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[n], isDetail: true).environmentObject(self.recipeStore)) {
                        Card(recipe: self.recipeStore.recipes[n])
                    }.accessibility(identifier: self.recipeStore.recipes[n].name)
                }
                .onDelete(perform: self.deleteRecipes)
                .onMove(perform: self.moveRecipes)
                .padding(.bottom)
            }
            .navigationBarItems(trailing: EditButton())
            .navigationBarTitle("Rezepte")
            .navigationBarHidden(self.searching)
            .sheet(isPresented: self.$showingAddRecipeView) {
                AddRecipeView(isPresented: self.$showingAddRecipeView)
                    .environmentObject(self.recipeStore)
            }
            
        }
    }
    
    func deleteRecipes(at offsets: IndexSet){
        self.recipeStore.recipes.remove(atOffsets: offsets)
        self.recipeStore.write()
    }
    
    func moveRecipes(from source: IndexSet, to destination: Int) {
        self.recipeStore.recipes.move(fromOffsets: source, toOffset: destination)
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
        RezeptList()
            .environment(\.colorScheme, .light)
            .environmentObject(RecipeStore())
        }
    }
}

