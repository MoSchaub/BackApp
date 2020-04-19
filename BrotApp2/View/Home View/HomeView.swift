//
//  HomeView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 07.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
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
    
    var roomThemperturePicker: some View{
        VStack {
            Picker("", selection: $recipeStore.roomThemperature){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            .labelsHidden()
            .padding(.horizontal)
            Button("OK"){
                self.showingRoomTempSheet = false
            }
        }
    }
    
    var roomThemperatureSection: some View{
        Button(action: {
            self.showingRoomTempSheet = true
        }){
            HStack {
            Text("Raumtemperatur: \(recipeStore.roomThemperature)°C")
                .padding(.leading)
            
            Spacer()
            Image(systemName: "chevron.up").padding(.trailing)
            
        }
        .padding()
        .background(BackgroundGradient())
        .sheet(isPresented: self.$showingRoomTempSheet) {
            self.roomThemperturePicker
            }
            
        }
            
            .buttonStyle(PlainButtonStyle())
    }
    
    var importButton: some View{
        HStack{
            Text("Rezept(e) aus Json-Datei importieren")
            Spacer()
            Image(systemName: "chevron.up")
        }
        .neomorphic()
        .onTapGesture {
                self.showingDocumentPicker = true
        }
        .sheet(isPresented: self.$showingDocumentPicker,onDismiss: self.loadFile) {
            DocumentPicker(url: self.$url)
        }
        .onAppear{
            self.loadFile()
        }
    }
    
    var recipesSection: some View{
        VStack {
            HStack{
                Text("Rezepte").font(.title).fontWeight(.bold)
                Spacer()
                NavigationLink(destination: RezeptList().environmentObject(self.recipeStore)) {
                    Text("Alle ansehen").secondary()
                }
            }.padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<recipeStore.latest.count){n in
                        ImageCard(recipe: self.recipeStore.latest[n]).environmentObject(self.recipeStore)
                            
                    }
                }
            }
        }
    }
    
    var favoritesSection: AnyView {
        if !self.recipeStore.favourites.isEmpty{
          return AnyView(  VStack {
                HStack{
                    Text("Favoriten").font(.title).fontWeight(.bold)
                    Spacer()
                }.padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(0..<recipeStore.favourites.count){n in
                            ImageCard(recipe: self.recipeStore.favourites[n]).environmentObject(self.recipeStore)
                        }
                    }
                }
            })
        } else {
          return AnyView(EmptyView())
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
    
    var background: some View{
        RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
            .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
    }
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false) {
                self.roomThemperatureSection.sheet(isPresented: self.$showingRoomTempSheet) {
                    self.roomThemperturePicker
                }
                self.importButton
                self.recipesSection
                self.favoritesSection
            }
            .navigationBarTitle("BrotApp")
            .navigationBarItems(trailing: self.addButton)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(RecipeStore.example)
    }
}

struct ImageCard: View {
    let recipe: Recipe
    @EnvironmentObject var recipeStore: RecipeStore
    
    var background: some View{
        RoundedRectangle(cornerRadius: 15)
        .fill(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
        .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
    }

    
    var body: some View{
        NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[self.recipeStore.recipes.firstIndex(of: self.recipe)!]).environmentObject(self.recipeStore)) {
            Card(recipe: recipe)
            .frame(width: UIScreen.main.bounds.width - 10)
            .background(self.background)
            .padding([.horizontal,.bottom])
        }.buttonStyle(PlainButtonStyle())
        .padding([.horizontal,.bottom])
    }
}
