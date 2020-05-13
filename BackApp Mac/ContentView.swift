//
//  ContentView.swift
//  BackApp Mac
//
//  Created by Moritz Schaub on 13.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var recipeStore: RecipeStore
    @State private var searchText = ""
    
    @State private var showingAddRecipeView = false
    @State private var showingRoomTempSheet = false
    @State private var showingAboutView = false
    
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State var url: URL? = nil{
        didSet{
           // self.loadFile()
        }
    }
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
