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
    let creating: Bool

    private var title: String{
        step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : step.name
    }

    private var nameSection: some View{
         #if os(iOS)
        return Section(header: Text("Name")) {
            TextField("Name eingeben", text: $step.name)
        }
        #elseif os(macOS)
        return HStack{
            Text("Name:")
            TextField("Name", text: $step.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
        }.padding([.horizontal,.top])
        
        #endif
    }
    
    private var timeSection: some View{
        #if os(iOS)
        return Section(header: Text("Dauer")) {
            NavigationLink(destination: stepTimePicker(time: $step.time)) {
                Text(step.formattedTime)
            }
        }
        #elseif os(macOS)
        return HStack {
            Text("Dauer:").padding(.leading)
            MOTimePicker().environmentObject(TimePickerModel(time: $step.time))
            Spacer()
        }
        #endif
    }
    
    private var tempSection: some View {
        #if os(iOS)
        return Section(header: Text("Temperatur")) {
            NavigationLink(destination: stepTempPicker(temp: $step.temperature) ) {
                Text(step.formattedTemp)
            }
        }
        #elseif os(macOS)
        return Picker("Temperatur:", selection: $step.temperature){
            ForEach(-10...50, id: \.self){ temperature in
                Text("\(temperature)° C")
            }
        }.padding(.horizontal)
        #endif
    }
    
    private var notesSection: some View{
        #if os(iOS)
        return Section(header: Text("Notizen")) {
            TextField("Notizen...",text: $step.notes)
        }
        #elseif os(macOS)
        return HStack{
            Text("Notizen:")
            TextField("Notizen eingeben", text: $step.notes)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
        
        #endif
    }
    
    private var ingredientsSection: some View {
        #if os(iOS)
        return Section(header: Text("Zutaten")) {
            ForEach(self.step.subSteps, id: \.id){ sub in
                StepRow(step: sub, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                    .contextMenu{
                        Button(action: { self.delete(substep: sub)}) {
                            Text("Löschen")
                        }
                }
            }
            .onDelete(perform: deleteSubsteps)
            .onMove(perform: moveSubsteps)
            
            ForEach(step.ingredients){ ingredient in
                NavigationLink(destination: IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(where: { $0.id == ingredient.id}) ?? 0], step: self.$step, recipe: self.recipe, creating: false).environmentObject(self.recipeStore)){
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.recipeStore.roomThemperature)
                }
                
            }
            .onMove(perform: moveIngredients)
            .onDelete(perform: deleteIngredients)
            
            Button(action: addIngredient){
                HStack {
                    Text("Zutat hinzufügen")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }.foregroundColor(.primary)
        }.actionSheet(isPresented: $recipeStore.sDShowingSubstepOrIngredientSheet, content: {self.ingredientOrStep})
        #elseif os(macOS)
        return VStack{
            HStack{
                Text("Zutaten").secondary()
                Spacer()
                Button(action: addIngredient) {
                    Text("+")
                }
            }.padding(.horizontal)
            if !self.step.subSteps.isEmpty{
                List{
                    //Substeps
                    ForEach(self.step.subSteps, id: \.id){ sub in
                        StepRow(step: sub, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                            .contextMenu{
                                Button(action: { self.delete(substep: sub)}) {
                                    Text("Löschen")
                                }
                        }
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
        let stepsWithIngredients = recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
        return List{
            ForEach(stepsWithIngredients){step in
                Button(action: {self.pick(Substep: step)}){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                }.buttonStyle(PlainButtonStyle())
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
        NavigationLink(destination: AddIngredientView(step: self.$step, recipe: recipe).environmentObject(self.recipeStore), tag: 2, selection: self.$recipeStore.sDSelection) {
        EmptyView()
        }.hidden()
        NavigationLink(destination: self.subStepPicker, tag: 3, selection: self.$recipeStore.sDSelection) {
        EmptyView()
        }.hidden()
        }.hidden()
    }
    #endif
    
    
    var okButton: some View {
        Button(action: save){ Text("OK") }.disabled(recipe.steps.contains(where: {$0.name == self.step.name}))
    }
   
    var body: some View {
        #if os(iOS)
        return VStack {
            List{
                nameSection
                notesSection
                timeSection
                tempSection
                ingredientsSection
                if !creating {
                    deleteButton
                }
            }
            navigationSection
        }
        .navigationBarTitle(self.title)
        #elseif os(macOS)
        return Group {
            if recipeStore.sDSelection == 1{
                ingredientOrStep
            } else if recipeStore.sDSelection == 2{
                AddIngredientView(step: $step, recipe: recipe).environmentObject(recipeStore)
                        .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if recipeStore.sDSelection == 3 {
                subStepPicker
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if recipeStore.selectedIngredient != nil {
                IngredientDetail(
                    ingredient: $step.ingredients[
                        step.ingredients.firstIndex(where: {$0.id == recipeStore.selectedIngredient?.id}) ?? 0
                    ],
                    step: $step, recipe: recipe, creating: false
                ).environmentObject(recipeStore)
                    .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else {
                VStack{
                    nameSection
                    notesSection
                    timeSection
                    tempSection
                    ingredientsSection
                    Spacer()
                    HStack {
                        okButton
                            .padding()
                        if creating {
                            Button(action: dissmiss) {
                                Text("Abrechen")
                            }
                        } else {
                            Button(action: delete){
                                Text("Löschen")
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
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
    
    func delete(substep: Step) {
        if step.subSteps.contains(substep), let index = step.subSteps.firstIndex(where: {substep.id == $0.id} ) {
            step.subSteps.remove(at: index)
        }
    }
    
    func moveSubsteps(from source: IndexSet, to offset: Int){
        self.step.subSteps.move(fromOffsets: source, toOffset: offset)
    }
    
    func delete() {
        recipeStore.delete(step: step, from: recipe)
    }
    
    func dissmiss() {
        if creating {
            recipeStore.rDSelection = nil
        } else {
            recipeStore.selectedStep = nil
        }
        #if os(iOS)
        presentationMode.wrappedValue.dismiss()
        #endif
    }
    
    func save() {
        recipeStore.save(step: step, to: recipe)
        dissmiss()
    }
    
    func addIngredient()  {
        let stepsWithIngredients = recipe.steps.filter({ $0 != step && !$0.ingredients.isEmpty})
        if stepsWithIngredients.isEmpty{
            recipeStore.sDSelection = 2 //ingredient
        } else{
            recipeStore.sDSelection = 1 //ingredient or substep
        }
    }
    
    func pick(Substep: Step) {
        step.subSteps.append(Substep)
        recipeStore.sDSelection = nil
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
