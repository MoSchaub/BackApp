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
    
    @State private var showingDocumentPicker = false
    @State var url: URL? = nil{
        didSet{
            self.loadFile()
        }
    }
    
    var addButton: some View{
       Image(systemName: "plus")
        .padding()
        .foregroundColor(.accentColor)
        .onTapGesture {
            self.showingAddRecipeView = true
        }
    }
    
    var body: some View {
        VStack {
            List {
                SearchBar(searchText: self.$searchText, isSearching: self.$searching)
                ForEach(recipeStore.recipes.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }){ recipe in
                    NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[self.recipeStore.recipes.firstIndex(of: recipe)!]).environmentObject(self.recipeStore)) {
                        Card(recipe: recipe, width: UIScreen.main.bounds.width - 30)
                    }
                    .disabled(self.searching)
                }
                .padding(.bottom)
            }
            .navigationBarItems(trailing: self.addButton)
            .navigationBarTitle("Rezepte")
            .navigationBarHidden(self.searching)
            .sheet(isPresented: self.$showingAddRecipeView) {
                AddRecipeView(isPresented: self.$showingAddRecipeView)
                    .environmentObject(self.recipeStore)
            }
            
        }
    }
    
    func loadFile() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let url = self.url{
                if let recipes: [Recipe] = load(url: url){
                    self.recipeStore.recipes += recipes
                }else if let recipe: Recipe = load(url: url){
                    self.recipeStore.recipes.append(recipe)
                }
                
            }
        }
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

