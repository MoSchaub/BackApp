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
    
    var roomThemperatureSection: some View{
        HStack {
            Picker("Raumthemperatur:", selection: $recipeStore.roomThemperature){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)° C")
                }
            }.frame(maxWidth: 235)
            Spacer()
        }
    }
    
    
    var importButton: some View{
        
        HStack {
            Button("Rezept(e) aus Datei importieren"){
                    self.importRecipes()
            }
            Spacer()
        }
            .alert(isPresented: self.$recipeStore.showingInputAlert){
                Alert(title: Text(self.recipeStore.inputAlertTitle), message: Text(self.recipeStore.inputAlertMessage), dismissButton: .default(Text("Ok")))
            }
       
    }
    
    var exportButton: some View {
        
        HStack{
            Button("Rezepte exportieren"){
                 self.saveRecipes()
            }
            Spacer()
        }
    }
    
    var aboutButton: some View{
        HStack{
            Button("Über diese App"){
                self.recipeStore.hSelection = 1
            }
            Spacer()
        }
    }

    var body: some View {
        NavigationView{
            VStack{
                HStack {
                    Text("Rezepte").secondary()
                    Spacer()
                    Button("+"){
                        self.recipeStore.showingAddRecipeView = true
                    }.onReceive(self.recipeStore.newRecipePublisher) { (_) in
                        self.recipeStore.showingAddRecipeView = true
                    }
                }.padding()
                List(selection: self.$recipeStore.selectedRecipe) {
                    ForEach(self.recipeStore.recipes) { recipe in
                        Card(recipe: recipe).tag(recipe)
                    }
                    .onMove(perform: moveRecipes)
                }
                Divider()
                
                Group {
                    self.roomThemperatureSection
                    self.importButton
                    self.exportButton
                    self.aboutButton
                        .padding(.bottom)
                }
                .padding(.leading)
                
                .sheet(isPresented: self.$recipeStore.showingAddRecipeView) {
                    AddRecipe { recipe in
                        self.recipeStore.addRecipe(recipe: recipe)
                    }
                }
            }
            .frame(minWidth: 300, idealWidth: 300, maxWidth: 400, minHeight: 200, idealHeight: 800, maxHeight: .infinity)
            if self.recipeStore.selectedRecipe != nil{
                RecipeDetail(recipe: self.$recipeStore.recipes[self.recipeStore.recipes.firstIndex(where: {$0.id == recipeStore.selectedRecipe?.id}) ?? 0], creating: false, addRecipe: nil, cancel: nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if self.recipeStore.hSelection == 1 {
                ImpressumView()
            }
            
        }.environmentObject(self.recipeStore)
        .frame(minWidth: 1055 ,maxWidth: .infinity, minHeight: 515, idealHeight: 800, maxHeight: .infinity)
    }
    
    func importRecipes() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url{
                    if let recipes = self.recipeStore.load(url: url, as: [Recipe].self){
                        self.recipeStore.recipes += recipes
                    }else if !self.recipeStore.isArray, let recipe: Recipe = self.recipeStore.load(url: url){
                        self.recipeStore.recipes.append(recipe)
                    }
                    self.recipeStore.isArray = false
            }
        }
    }
    
    func saveRecipes() {
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Exportiere Rezepte als"
        panel.nameFieldStringValue = "recipes.backApp"
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                let source = self.recipeStore.exportToUrl()
                if let data = try? Data(contentsOf: source){
                    do {
                        try data.write(to: fileUrl)
                        self.recipeStore.inputAlertTitle = "Erfolg"
                        self.recipeStore.inputAlertMessage = "Die Rezepte wurden erfolgreich exportiert"
                        self.recipeStore.showingInputAlert = true
                    } catch {
                        self.recipeStore.inputAlertTitle = "Fehler"
                        self.recipeStore.inputAlertMessage = error.localizedDescription
                        self.recipeStore.showingInputAlert = true
                    }
                } else{
                    self.recipeStore.inputAlertTitle = "Fehler"
                    self.recipeStore.inputAlertMessage = "Konnte die Daten nicht finden"
                    self.recipeStore.showingInputAlert = true
                }

            }
        }
    }
    
    func deleteRecipes(at offsets: IndexSet){
        self.recipeStore.recipes.remove(atOffsets: offsets)
        //self.recipeStore.write()
    }
    
    func moveRecipes(from source: IndexSet, to destination: Int) {
        self.recipeStore.recipes.move(fromOffsets: source, toOffset: destination)
    }
    
}


struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RecipeStore())
    }
}
