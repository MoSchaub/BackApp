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
    
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State var url: URL? = nil{
        didSet{
            self.loadFile()
        }
    }
    
    var roomThemperturePicker: some View{
        VStack(spacing: 15) {
            Picker("", selection: $recipeStore.roomTemperature){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            .labelsHidden()
            .padding(.horizontal)
            .background(BackgroundGradient())
            Text("\(self.recipeStore.roomTemperature) °C")
            Button("OK"){
                self.recipeStore.hSelection = nil
            }
            .padding()
        }
    }
    
    var roomThemperatureSection: some View{
        NavigationLink(destination: self.roomThemperturePicker, tag: 1, selection: self.$recipeStore.hSelection, label: {
            Text("Raumtemperatur: \(recipeStore.roomTemperature)°C")
        })
    }
    
    var importButton: some View{
        HStack{
            Text("Rezept(e) aus Datei importieren")
            Spacer()
            Image(systemName: "chevron.up").foregroundColor(.secondary)
        }
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
            Image(systemName: "chevron.up").foregroundColor(.secondary)
        }
        .onTapGesture {
            self.showingShareSheet = true
        }
        .sheet(isPresented: self.$showingShareSheet) {
            ShareSheet(activityItems: [self.recipeStore.exportToUrl()])
        }
    }
    
    var donateButton: some View {
        Text("Spenden")
            .foregroundColor(.accentColor)
            .onTapGesture {
                //open donatePage
        }
    }
    
    var aboutButton: some View{
        NavigationLink(destination: ImpressumView(), tag: 2, selection: self.$recipeStore.hSelection) {
            Text("Über diese App")
        }
    }
    
    var addButton: some View{
       Text("Rezept hinzufügen")
        .font(.footnote)
        .foregroundColor(.accentColor)
        .onTapGesture {
            self.showingAddRecipeView = true
        }
    .accessibility(label: Text("Rezept hinzufügen"))
    }
    
    var background: some View{
        RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
            .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
    }
    
    var body: some View {
        NavigationView{
            List {
                Section(header: HStack {
                    Text("Rezepte")
                    Spacer()
                    self.addButton
                        .sheet(isPresented: self.$showingAddRecipeView) {
                            AddRecipe { recipe in
                                self.recipeStore.save(recipe: recipe)
                                self.recipeStore.showingAddRecipeView = false
                            }
                    }
                }) {
                    ForEach(recipeStore.recipes){ recipe in
                        NavigationLink(
                            destination: RecipeDetail(
                                recipe: self.$recipeStore.recipes[self.recipeStore.recipes.firstIndex(where: { self.recipeStore.selectedRecipe?.id == $0.id }) ?? 0],
                                creating: false,
                                addRecipe: nil,
                                dismiss: nil
                            ).environmentObject(self.recipeStore),
                            tag: recipe,
                            selection: self.$recipeStore.selectedRecipe
                        ) {
                            Card(recipe: recipe)
                        }.accessibility(identifier: recipe.name)
                    }
                    .onMove(perform: moveRecipes)
                    .onDelete(perform: deleteRecipes)
                }
                
                self.roomThemperatureSection
                self.importButton
                self.exportButton
                // self.donateButton
                self.aboutButton
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("BrotApp", displayMode: .automatic)
            .navigationBarItems(trailing: EditButton().padding())
            
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
    
    func deleteRecipes(at offsets: IndexSet){
        for index in offsets {
            recipeStore.deleteRecipe(at: index)
        }
    }
    
    func moveRecipes(from source: IndexSet, to destination: Int) {
        self.recipeStore.recipes.move(fromOffsets: source, toOffset: destination)
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(RecipeStore.example)
    }
}
