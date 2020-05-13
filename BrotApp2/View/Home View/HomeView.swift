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
    @State private var searchText = ""
    
    @State private var showingAddRecipeView = false
    @State private var showingRoomTempSheet = false
    @State private var showingAboutView = false
    
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State var url: URL? = nil{
        didSet{
            self.loadFile()
        }
    }
    
    var roomThemperturePicker: some View{
        VStack(spacing: 15) {
            Picker("", selection: $recipeStore.roomThemperature){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            .labelsHidden()
            .padding(.horizontal)
            .background(BackgroundGradient())
            Text("\(self.recipeStore.roomThemperature) °C")
            Button("OK"){
                self.showingRoomTempSheet = false
            }
            .padding()
            .background(BackgroundGradient())
        }
    }
    
    var roomThemperatureSection: some View{
        Button(action: {
            self.showingRoomTempSheet = true
        }){
            HStack {
                Text("Raumtemperatur: \(recipeStore.roomThemperature)°C")
                Spacer()
                Image(systemName: "chevron.right")
                
            }
            .neomorphic()
            .onTapGesture {
                self.showingAboutView = false
                self.showingRoomTempSheet = true
            }
            NavigationLink(destination: self.roomThemperturePicker, isActive: self.$showingRoomTempSheet, label: {
                EmptyView()
            })
            
        }
            
        .buttonStyle(PlainButtonStyle())
    }
    
    var importButton: some View{
        HStack{
            Text("Rezept(e) aus Datei importieren")
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
        .alert(isPresented: self.$recipeStore.showingInputAlert){
            Alert(title: Text(self.recipeStore.inputAlertTitle), message: Text(self.recipeStore.inputAlertMessage), dismissButton: .default(Text("Ok")))
        }
    }
    
    var exportButton: some View {
        HStack{
            Text("Rezepte exportieren")
            Spacer()
            Image(systemName: "chevron.up")
        }
        .neomorphic()
        .onTapGesture {
            self.showingShareSheet = true
        }
        .sheet(isPresented: self.$showingShareSheet) {
            ShareSheet(activityItems: [self.recipeStore.exportToUrl()])
        }
    }
    
    var donateButton: some View {
        HStack{
            Text("Spenden").foregroundColor(.accentColor)
            Spacer()
            Image(systemName: "chevron.up")
        }.onTapGesture {
            //open donatePage
        }
        .neomorphic()
    }
    
    var aboutButton: some View{
        VStack {
            Button(action: {
                self.showingRoomTempSheet = false
                self.showingAboutView = true
            }){
                HStack{
                    Text("Über diese App")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .neomorphic()
            }.buttonStyle(PlainButtonStyle())
            NavigationLink(destination: ImpressumView(), isActive: self.$showingAboutView) {
                EmptyView()
            }
        }
    }
    
    var recipesSection: some View{
        VStack {
            HStack{
                Text("Rezepte").font(.headline).fontWeight(.bold)
                Spacer()
                NavigationLink(destination: RezeptList().environmentObject(self.recipeStore)) {
                    Text("Alle ansehen").secondary()
                }
            }.padding([.horizontal, .top])
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<recipeStore.latest.count, id: \.self){n in
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
                    Text("Favoriten").font(.headline).fontWeight(.bold)
                    Spacer()
                }.padding([.horizontal, .top])
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(0..<recipeStore.favourites.count, id: \.self){n in
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
       Text("Rezept hinzufügen")
        .font(.footnote)
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
                VStack{
                    self.favoritesSection
                    self.recipesSection
                      .padding(.bottom)
                    self.roomThemperatureSection
                    self.importButton
                    self.exportButton
                   // self.donateButton
                    self.aboutButton
                }
            }.padding(.bottom)
                .navigationBarTitle("BrotApp", displayMode: .inline)
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
                if let recipes = self.recipeStore.load(url: url, as: [Recipe].self){
                    self.recipeStore.recipes += recipes
                }else if !self.recipeStore.isArray, let recipe: Recipe = self.recipeStore.load(url: url){
                    self.recipeStore.recipes.append(recipe)
                }
                self.recipeStore.isArray = false
                self.url = nil
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
        if let index = self.recipeStore.recipes.firstIndex(where: { self.recipe.id == $0.id}){
            return AnyView(
                NavigationLink(destination: RezeptDetail(recipe: self.$recipeStore.recipes[index]).environmentObject(self.recipeStore)) {
                    Card(recipe: self.recipe)
                        .background(self.background)
                        .padding([.horizontal])
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom)
                
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}
