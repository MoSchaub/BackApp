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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    SearchBar(searchText: self.$searchText, isSearching: self.$searching)
                    ForEach(0..<recipeStore.recipes.count, id: \.self){ number in
                        NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[number]).environmentObject(self.recipeStore)) {
                            Card(recipe: self.recipeStore.recipes[number], width: UIScreen.main.bounds.width - 30)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.bottom)
            }.navigationBarItems(trailing: Button(action: {
                self.showingAddRecipeView = true
            }){
                Image(systemName: "square.and.pencil")
                .padding()
            })
            .navigationBarTitle("Rezepte")
        }
        .sheet(isPresented: self.$showingAddRecipeView) {
                AddRecipeView(isPresented: self.$showingAddRecipeView)
                    .environmentObject(self.recipeStore)
        }
    }
    
    init() {
        UINavigationBar.appearance().tintColor = UIColor.label
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RezeptList()
            .environment(\.colorScheme, .light)
            .environmentObject(RecipeStore())
    }
}


struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension View {
    func delayTouches() -> some View {
        Button(action: {}) {
            highPriorityGesture(TapGesture())
        }
        .buttonStyle(NoButtonStyle())
    }
}
