//
//  AddRecipe.swift
//  BackApp iOS
//
//  Created by Moritz Schaub on 14.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddRecipe: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @State private var recipe = Recipe(name: "", brotValues: [], inverted: false, dateString: "", isFavourite: false, category: Category.example)
    @State private var selection: Int? = nil
    @State private var selectedStep: Step? = nil
    
    var disabled: Bool{
        recipe.name.isEmpty || recipe.steps.isEmpty
    }
    
    var name: some View {
        HStack {
            Text("Name:")
            TextField("Name eingeben", text: self.$recipe.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
        }.padding([.leading,.top])
    }
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(BackgroundGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                    .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
                    
            } else{
                Image(nsImage: recipe.image!).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
            }
        }
    }
    
    var imageButton: some View {
        Button(action: {
            self.selection = 1
            self.selectedStep = nil
        }) {
            image
                .padding([.leading, .bottom, .trailing])
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 300)
    }
    
    var categoryButton: some View {
        Picker(selection: self.$recipe.category, label: Text("Kategorie: ")) {
            ForEach(self.recipeStore.categories){ c in
                Text(c.name).tag(c)
            }
        }.padding(.horizontal)
    }
    
    var numberFormatter: NumberFormatter{
        let nF = NumberFormatter()
        nF.numberStyle = .decimal
        return nF
    }
    
    var timesSection: some View {
        HStack {
            Text("Anzahl:")
            DecimalField("Anzahl eingeben", value: self.$recipe.times, formatter: self.numberFormatter)
            Spacer()
        }.padding(.leading)
    }
    
    var stepSection: some View {
        VStack {
            HStack {
                Text("Arbeitsschritte").secondary()
                    .padding(.leading)
                Spacer()
                Button("hinzufügen"){
                    self.selection = 2
                    self.selectedStep = nil
                }.padding(.horizontal)
            }
            
            List(selection: self.$selectedStep){
                ForEach(self.recipe.steps){step in
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                        .tag(step)
                }
            }
        }
    }
    
    var addButton: some View {
        Button(action: {
            self.save()
        }){
            Text("hinzufügen").padding(.leading)
        }.disabled(self.disabled)
    }
    
    var cancelButton: some View{
        Button("Abbrechen"){
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                self.name
                self.timesSection
                self.imageButton
                self.categoryButton
                self.stepSection
                Spacer()
                HStack {
                    self.addButton
                    self.cancelButton
                }.padding([.leading, .bottom, .trailing])
            }
            .frame(minWidth: 290, idealWidth: 300, maxWidth: 500, minHeight: 700, idealHeight: 700, maxHeight: .infinity, alignment: .leading)
            if self.selectedStep == nil && self.selection == 1{
                ImagePickerView(inputImage: self.$recipe.image, filteredImage: nil)
            } else if self.selectedStep == nil && self.selection == 2 {
                VStack{
                    AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)
                    Button(action: {
                        self.selection = nil
                    }) {
                        Text("Abbrechen").neomorphic()
                    }
                    .padding(.bottom)
                }
            }else if self.selectedStep != nil{
                VStack {
                    StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(of: self.selectedStep!) ?? 0], deleteEnabled: true, roomTemp: self.recipeStore.roomThemperature)
                    Button(action: {
                        self.deleteStep()
                    }){
                        HStack {
                            Text("Löschen")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }.disabled(self.recipe.steps.count <= 1)
                    Button(action: {
                        self.selectedStep = nil
                    }) {
                        Text("Abbrechen").neomorphic()
                    }
                    .padding(.bottom)
                }
            }
        }.onAppear(){
            self.recipe.category = self.recipeStore.categories.first ?? Category.example
        }
    }

    func deleteStep(){
        if let index = self.recipe.steps.firstIndex(of: self.selectedStep!), self.recipe.steps.count > index {
            self.selection = nil
            self.selectedStep = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.recipe.steps.remove(at: index)
                
            }
        }
    }
    
    func save(){
        recipeStore.addRecipe(recipe: self.recipe)
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddRecipe_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipe().environmentObject(RecipeStore.example)
    }
}

