//
//  RecipeDetail.swift
//  BackApp Mac
//
//  Created by Moritz Schaub on 17.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RecipeDetail: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @Binding var recipe: Recipe
    
    private var image: some View {
        Group{
            if recipe.imageString == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image("bread").resizable().scaledToFit())
                    .frame(minWidth: 50, idealWidth: 75, maxWidth: 100, minHeight: 50, idealHeight: 75, maxHeight: 100)
                    .background(BackgroundGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                    .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
            } else{
                Image(nsImage: NSImage(data: recipe.imageString!)!).resizable().scaledToFill()
                    .frame(minWidth: 50, idealWidth: 75, maxWidth: 100, minHeight: 50, idealHeight: 75, maxHeight: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                    .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
            }
        }
    }
    
    private var imageButton: some View{
        Button(action: {
            self.recipeStore.rDSelection = 1
        }) {
            image
        }.buttonStyle(PlainButtonStyle())
    }
    
    private var exportButton: some View{
        Button(action: {
            self.export()
        }) {
            Text("Exportieren")
        }
    }
    
    private var titleSection: some View{
        HStack {
            imageButton
            TextField("Name eingeben",text: $recipe.name).font(.title)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
            exportButton
        }.padding(.horizontal)
        .frame(maxWidth: .infinity ,maxHeight: 100)
    }
    
    private var nameSection: some View{
        HStack {
            Text("Name:")
            TextField("Name eingeben", text: self.$recipe.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
    }
    
    private var nv: NumberFormatter{
        let nv = NumberFormatter()
        nv.numberStyle = .none
        return nv
    }
    
    private var amountSection: some View{
        HStack{
            Text("Anzahl:")
            TextField("Anzahl eingeben", text: self.$recipe.timesText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
    }
    
    private var categorySection: some View{
        HStack{
            Text("Kategorie:")
            Picker("", selection: self.$recipe.category) {
                ForEach(self.recipeStore.categories){cat in
                    Text(cat.name).tag(cat)
                }
            }.labelsHidden()
        }.padding(.horizontal)
    }
    
    private var stepsSection: some View{
        List(selection: self.$recipeStore.selectedStep) {
            Section(header:
                HStack {
                    Text("Schritte")
                    Spacer()
                    Button(action: {
                        self.recipeStore.rDSelection = 4
                    }) {
                        Text("+")
                    }
                }.padding(.leading)
            ){
                ForEach(self.recipe.steps){ step in
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature).tag(step)
                    Divider()
                }
            }
        }
    }
    
    private var deleteButton: some View {
        Button("Löschen") {
            self.recipeStore.delete(recipe: self.recipe)
        }
        .disabled(self.recipeStore.recipes.count <= 1)
        .foregroundColor(self.recipeStore.recipes.count <= 1 ? .gray : .red)
    }
    
    var body: some View {
        
        NavigationView {
            VStack{
                self.titleSection
                
                Divider()
                
                self.nameSection
                self.amountSection
                self.categorySection
                
                self.stepsSection
                self.deleteButton
                Spacer()
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if self.recipeStore.selectedStep != nil && self.recipeStore.recipes.count > 0{
                ZStack {
                    StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(of: self.recipeStore.selectedStep ?? Step(name: "", time: 0, ingredients: [], themperature: 20)) ?? 0], deleteEnabled: true).environmentObject(self.recipeStore)
                    VStack {
                            Spacer()
                            Button(action: {
                                self.recipeStore.delete(step: self.recipeStore.selectedStep!, from: self.recipe)
                            }){
                                    Text("Löschen")
                                        .foregroundColor(.red)
                            }
                            .disabled(self.recipe.steps.count <= 1)
                            .padding()
                        }

                }
            } else if self.recipeStore.rDSelection == 1 {
                ZStack {
                    ImagePickerView(imageData: self.$recipe.imageString, image: .none)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    VStack {
                        Spacer()
                        Button(action: {
                            self.recipeStore.rDSelection = nil
                        }) {
                            Text("Abbrechen").neomorphic()
                        }
                        .padding(.bottom)
                    }

                }
            } else if self.recipeStore.rDSelection == 4 {
                ZStack {
                    AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)
                    VStack {
                        Spacer()
                        Button(action: {
                            self.recipeStore.rDSelection = nil
                        }) {
                            Text("Abbrechen")
                        }
                        .padding(.bottom)
                        .padding(.bottom)
                        .padding(.bottom)
                    }
                }
            }
        }
    }
    
    func export(){
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Exportiere Rezept als"
        panel.nameFieldStringValue = "recipe.backApp"
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                do {
                    let data = try JSONEncoder().encode(self.recipe)
                    do {
                        try data.write(to: fileUrl)
                        self.recipeStore.inputAlertTitle = "Erfolg"
                        self.recipeStore.inputAlertMessage = "Das Rezept wurde erfolgreich exportiert"
                        self.recipeStore.showingInputAlert = true
                    } catch {
                        self.recipeStore.inputAlertTitle = "Fehler"
                        self.recipeStore.inputAlertMessage = error.localizedDescription
                        self.recipeStore.showingInputAlert = true
                    }
                } catch {
                    self.recipeStore.inputAlertTitle = "Fehler"
                    self.recipeStore.inputAlertMessage = error.localizedDescription
                    self.recipeStore.showingInputAlert = true
                }
            }
        }
    }
    
}

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetail(recipe: .constant(Recipe.example)).environmentObject(RecipeStore.example)
    }
}
