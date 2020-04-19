//
//  SearchingList.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 19.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct SearchingList: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        VStack{
            SearchBar(searchText: self.$searchText, isSearching: self.$isSearching)
            List {
                ForEach(recipeStore.recipes.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }){ recipe in
                    NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[self.recipeStore.recipes.firstIndex(of: recipe)!]).environmentObject(self.recipeStore)) {
                        Card(recipe: recipe, width: UIScreen.main.bounds.width - 30)
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

struct SearchingList_Previews: PreviewProvider {
    static var previews: some View {
        SearchingList().environmentObject(RecipeStore.example)
    }
}
