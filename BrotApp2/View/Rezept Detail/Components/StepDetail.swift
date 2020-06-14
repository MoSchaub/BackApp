//
//  StepDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct StepDetail: View {
    
    @EnvironmentObject private var recipeStore: RecipeStore
    #if os(iOS)
    @Environment(\.presentationMode) var presentationMode
    #endif
    
    @Binding var recipe: Recipe
    @Binding var step: Step

    let deleteEnabled: Bool

    private var title: String{
        self.step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : self.step.name
    }

    private var nameSection: some View{
         #if os(iOS)
        return Section(header: Text("Name")) {
            TextField("Name eingeben", text: self.$step.name)
        }
        #elseif os(macOS)
        return HStack{
            Text("Name:")
            TextField("Name", text: self.$step.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
        }.padding([.horizontal,.top])
        
        #endif
    }
    
    private var timeSection: some View{
        #if os(iOS)
        return Section(header: Text("Dauer")) {
            NavigationLink(destination: stepTimePicker(time: self.$step.time)) {
                Text(step.formattedTime)
            }
        }
        #elseif os(macOS)
        return HStack {
            Text("Dauer:").padding(.leading)
            MOTimePicker().environmentObject(TimePickerModel(time: self.$step.time))
            Spacer()
        }
        #endif
    }
    
    private var tempSection: some View {
        #if os(iOS)
        return Section(header: Text("Temperatur")) {
            NavigationLink(destination: stepTempPicker(temp: self.$step.temperature) ) {
                Text(self.step.formattedTemp)
            }
        }
        #elseif os(macOS)
        return Picker("Temperatur:", selection: self.$step.temperature){
            ForEach(-10...50, id: \.self){ n in
                Text("\(n)° C")
            }
        }.padding(.horizontal)
        #endif
    }
    
    private var notesSection: some View{
        #if os(iOS)
        return Section(header: Text("Notizen")) {
            TextField("Notizen...",text: self.$step.notes)
        }
        #elseif os(macOS)
        return HStack{
            Text("Notizen:")
            TextField("Notizen eingeben", text: self.$step.notes)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
        
        #endif
    }
    
    private var ingredientsSection: some View {
        #if os(iOS)
        return Section(header: Text("Zutaten")) {
            ForEach(self.step.subSteps){ subStep in
                HStack {
                    Text(subStep.name).font(.headline)
                    Spacer()
                    Text(subStep.formattedTime).secondary()
                }
            }
            .onDelete(perform: deleteSubsteps)
            .onMove(perform: moveSubsteps)
            
            ForEach(self.step.ingredients){ ingredient in
                NavigationLink(destination: IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(where: { $0.id == ingredient.id}) ?? 0], step: self.$step, recipe: self.recipe, deleteEnabled: true).environmentObject(self.recipeStore)){
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.recipeStore.roomThemperature)
                }
                
            }
            .onMove(perform: moveIngredients)
            .onDelete(perform: deleteIngredients)
            
            Button(action: {
                let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
                if stepsWithIngredients.isEmpty{
                    self.recipeStore.sDSelection = 2 //ingredient
                } else{
                    self.recipeStore.sDSelection = 1 //ingredient or substep
                }
            }){
                HStack {
                    Text("Zutat hinzufügen")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }.foregroundColor(.primary)
        }.actionSheet(isPresented: self.$recipeStore.sDShowingSubstepOrIngredientSheet, content: {self.ingredientOrStep})
        #elseif os(macOS)
        return VStack{
            HStack{
                Text("Zutaten").secondary()
                Spacer()
                Button("+"){
                    let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
                    if stepsWithIngredients.isEmpty{
                        self.recipeStore.sDSelection = 2 //ingredient
                    } else{
                        self.recipeStore.sDSelection = 1 //ingredient or substep
                    }
                }
            }.padding(.horizontal)
            if !self.step.subSteps.isEmpty{
                List(selection: self.$recipeStore.selectedSubstep){
                    //Substeps
                    ForEach(self.step.subSteps, id: \.id){ sub in
                        StepRow(step: sub, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                            .tag(sub)
                    }
                .onMove(perform: moveSubsteps)
                .onDelete(perform: deleteSubsteps)
                }
            }
            
            List(selection: self.$recipeStore.selectedIngredient){
                //Ingredients
                ForEach(self.step.ingredients){ ingredient in
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.recipeStore.roomThemperature).tag(ingredient)
                }
                .onMove(perform: moveIngredients)
                .onDelete(perform: deleteIngredients)
            }
        }
        #endif
    }
    
    private var subStepPicker: some View {
        let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
        return List{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                        self.step.subSteps.append(step)
                        self.recipeStore.selectedSubstep = step
                    #if os(iOS)
                    self.recipeStore.sDSelection = nil
                    #endif
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                }
            }
        }

    }
    
    #if os(iOS)
    
    private var ingredientOrStep: ActionSheet{
        let buttons = [
        ActionSheet.Button.default(Text("Zutat"), action: {
        self.recipeStore.sDSelection = 2 //add ingredient
        }),
        .default(Text("Schritt"), action: {
        self.recipeStore.sDSelection = 3 // add Substep
        }),
        .cancel()
        ]
        return ActionSheet(title: Text("Schritt oder Zutat?"), buttons: buttons)
    }
    #elseif os(macOS)
    
    private var ingredientOrStep: some View{
        VStack{
            Button("Zutat"){
                self.recipeStore.sDSelection = 2 //ingredient
            }
            Button("Schritt"){
                self.recipeStore.sDSelection = 3 //substep
            }
            Button(action: {
                self.recipeStore.sDSelection = nil //cancel
            }) {
                Text("Abbrechen").foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    #endif

    #if os(iOS)
    var deleteButton: some View{
        Button(action: {
            self.recipeStore.delete(step: self.step, from: self.recipe)
            self.presentationMode.wrappedValue.dismiss()
        }){
            HStack {
                Text("Löschen").foregroundColor(.red)
                Spacer()
            }
            .neomorphic()
        }
    }
    
    var navigationSection: some View {
        Section {
        NavigationLink(destination: AddIngredientView(recipe: recipe, step: self.$step).environmentObject(self.recipeStore), tag: 2, selection: self.$recipeStore.sDSelection) {
        EmptyView()
        }.hidden()
        NavigationLink(destination: self.subStepPicker, tag: 3, selection: self.$recipeStore.sDSelection) {
        EmptyView()
        }.hidden()
        }.hidden()
    }
    #endif
    
    
    var okButton: some View {
        return Button(action: {
            if self.recipeStore.recipes.contains(self.recipe) {
                self.recipeStore.save(step: self.step, to: self.recipe)
            } else if !self.recipe.steps.contains(self.step) {
                self.recipe.steps.append(self.step)
            }
            #if os(iOS)
            self.presentationMode.wrappedValue.dismiss()
             #endif
        }){ Text("OK") }
    }
   
    var body: some View {
        #if os(iOS)
        return VStack {
            List{
                    self.nameSection
                    self.notesSection
                    self.timeSection
                    self.tempSection
                    self.ingredientsSection
                    if self.deleteEnabled{
                        self.deleteButton
                    } else{
                        self.okButton
                    }
            }
            self.navigationSection
        }
        .navigationBarTitle(self.title)
        #elseif os(macOS)
        return Group {
            if self.recipeStore.sDSelection == 1{
                self.ingredientOrStep
            } else if self.recipeStore.sDSelection == 2{
                VStack {
                    AddIngredientView(recipe: recipe, step: self.$step).environmentObject(self.recipeStore)
                    Button("Abbrechen"){ self.recipeStore.sDSelection = nil}
                        .padding(.bottom)
                }
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.sDSelection == 3 {
                self.subStepPicker
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.selectedIngredient != nil {
                IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(where: {$0.id == self.recipeStore.selectedIngredient?.id}) ?? 0], step: self.$step, recipe: self.recipe, creating: false).environmentObject(self.recipeStore).frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.selectedIngredient == nil && self.recipeStore.selectedSubstep != nil && self.step.subSteps.count > 0{
                VStack {
                    StepDetail(recipe: self.$recipe, step: self.$step.subSteps[self.step.subSteps.firstIndex(where: {$0.id == self.recipeStore.selectedSubstep?.id}) ?? 0], deleteEnabled: false)
                    
                    Button(action: {
                        self.recipeStore.deleteSubstep(of: self.step, in: self.recipe)
                    }) {
                        Text("Entfernen")
                    }
                    
                    Button(action: {
                        self.recipeStore.selectedSubstep = nil
                    }) {
                        Text("OK")
                    }
                }.frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else {
                VStack{
                    self.nameSection
                    self.notesSection
                    self.timeSection
                    self.tempSection
                    self.ingredientsSection
                    Spacer()
                    if !self.deleteEnabled{
                        self.okButton
                        .padding(.bottom)
                    }
                }
                .frame(minWidth: 310, idealWidth: 350, maxWidth: .infinity)
            }
        }
        #endif
    }
    
    func deleteIngredients(at offsets: IndexSet){
        self.step.ingredients.remove(atOffsets: offsets)
    }
    
    func moveIngredients(from source: IndexSet, to offset: Int){
        self.step.ingredients.move(fromOffsets: source, toOffset: offset)
    }
    
    func deleteSubsteps(at offsets: IndexSet){
        self.step.subSteps.remove(atOffsets: offsets)
    }
    
    func moveSubsteps(from source: IndexSet, to offset: Int){
        self.step.subSteps.move(fromOffsets: source, toOffset: offset)
    }
    
    

}

#if os(iOS)
struct stepTimePicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var time: TimeInterval
    
    var body: some View {
        VStack {
            MOTimePicker(time: self.$time)
                .accessibility(identifier: "time")
            Button("OK"){ self.presentationMode.wrappedValue.dismiss()}
        }
    }
}

struct stepTempPicker: View{
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var temp: Int
    
    var body: some View {
        VStack {
            Picker(" ",selection: self.$temp){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            .labelsHidden()
            .padding()
            Button("OK"){ self.presentationMode.wrappedValue.dismiss()}
        }
    }
}
#endif
