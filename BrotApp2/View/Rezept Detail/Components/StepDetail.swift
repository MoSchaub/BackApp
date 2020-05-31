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
        return VStack(alignment: .leading, spacing: 3.0) {
            Text("Name").secondary()
                .padding(.leading)
                .padding(.leading)
            TextField("Name", text: self.$step.name)
                .padding(.leading)
                .padding(.vertical)
                .background(BackgroundGradient())
                .padding([.horizontal,.bottom])
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
        return NavigationLink(destination: stepTimePicker(time: self.$step.time)) {
            HStack {
                Text("Dauer:")
                Spacer()
                Text(step.formattedTime)
                Image(systemName: "chevron.right")
            }
            .neomorphic()
        }.buttonStyle(PlainButtonStyle())
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
        return NavigationLink(destination: stepTempPicker(temp: self.$step.temperature) ) {
            HStack {
                Text("Temperatur")
                Spacer()
                Text(self.step.formattedTemp)
                Image(systemName: "chevron.right")
            }
            .neomorphic()
        }.buttonStyle(PlainButtonStyle())
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
        return VStack(alignment: .leading, spacing: 3.0) {
            Text("Notizen").secondary()
                .padding(.leading)
                .padding(.leading)
            TextField("Notizen...",text: self.$step.notes)
                .padding(.leading)
                .padding(.vertical)
                .background(BackgroundGradient())
                .padding([.horizontal,.bottom])
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
        return VStack(alignment: .leading, spacing: 3.0 ){
            Text("Zutaten").secondary()
                .padding(.leading)
                .padding(.leading)
            ForEach(self.step.subSteps){ subStep in
                HStack {
                    Text(subStep.name).font(.headline)
                    Spacer()
                    Text(subStep.formattedTime).secondary()
                }
                .neomorphic()
                .padding(.bottom)
            }
            ForEach(self.step.ingredients){ ingredient in
                NavigationLink(destination: IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(of: ingredient)!], step: self.$step, deleteEnabled: true)){
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.recipeStore.roomThemperature, inLink: true, background: true)
                        .padding(.bottom)
                }.buttonStyle(PlainButtonStyle())
            }
            NavigationLink(destination: AddIngredientView(step: self.$step), tag: 2, selection: self.$recipeStore.sDSelection) {
                EmptyView()
            }.hidden()
            NavigationLink(destination: self.subStepPicker, tag: 3, selection: self.$recipeStore.sDSelection) {
                EmptyView()
            }.hidden()
            NavigationLink(destination: self.ingredientOrStep, tag: 1, selection: self.$recipeStore.sDSelection) {
                EmptyView()
            }.hidden()
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
                    Image(systemName: "chevron.right")
                }
                .padding()
                .padding(.horizontal)
                .background(BackgroundGradient())
                .padding(.horizontal)
            }.buttonStyle(PlainButtonStyle())
        }
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
                }
            }
            
            List(selection: self.$recipeStore.selectedIngredient){
                //Ingredients
                ForEach(self.step.ingredients){ ingredient in
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.recipeStore.roomThemperature, inLink: false, background: false).tag(ingredient)
                }
            }
        }
        #endif
    }
    
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
    
    private var subStepPicker: some View {
        let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
        #if os(iOS)
        return VStack{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                    self.step.subSteps.append(step)
                    self.recipeStore.sDSelection = 3
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                }.buttonStyle(PlainButtonStyle())
            }
        }
        #elseif os(macOS)
        return List{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                    self.step.subSteps.append(step)
                    self.recipeStore.sDSelection = nil
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                }.buttonStyle(PlainButtonStyle())
            }
        }
        
        #endif
    }
    
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
    #endif
    
    
    var okButton: some View {
        return Button(action: {
            self.recipeStore.save(step: self.step, to: self.recipe)
            #if os(iOS)
            self.presentationMode.wrappedValue.dismiss()
             #endif
        }){
            HStack {
                Text("OK")
                Spacer()
            }.neomorphic()
        }
    }
   
    var body: some View {
        #if os(iOS)
        return ScrollView{
            VStack(alignment: .leading) {
                self.nameSection
                self.notesSection
                self.timeSection
                self.tempSection
                self.ingredientsSection
                Spacer()
                if self.deleteEnabled{
                    self.deleteButton
                } else{
                    self.okButton
                }
            }
        }
        .navigationBarTitle(self.title)
        #elseif os(macOS)
        return NavigationView {
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
            if self.recipeStore.sDSelection == 1{
                self.ingredientOrStep
            } else if self.recipeStore.sDSelection == 2{
                VStack {
                    AddIngredientView(step: self.$step).environmentObject(self.recipeStore)
                    Button("Abbrechen"){ self.recipeStore.sDSelection = nil}
                        .padding(.bottom)
                }
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.sDSelection == 3 {
                self.subStepPicker
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.selectedSubstep == nil && self.recipeStore.selectedIngredient != nil &&  self.step.ingredients.contains(self.recipeStore.selectedIngredient ?? Ingredient(name: "", amount: 0)){
                ZStack {
                    IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(of: self.recipeStore.selectedIngredient ?? Ingredient(name: "", amount: 0)) ?? 0], step: self.$step, creating: false).environmentObject(self.recipeStore)
                    VStack {

                        Spacer()

                        Button("OK"){
                            self.recipeStore.selectedIngredient = nil
                        }
                        
                        Button(action: {
                            self.recipeStore.deleteIngredient(of: self.step, in: self.recipe)
                        }){
                            Text("Löschen")
                                .foregroundColor(.red)
                        }.padding(.bottom)
                    }

                }.frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.recipeStore.selectedIngredient == nil && self.recipeStore.selectedSubstep != nil{
                VStack {
                    StepDetail(recipe: self.$recipe, step: self.$step.subSteps[self.step.subSteps.firstIndex(of: self.recipeStore.selectedSubstep!) ?? 0], deleteEnabled: false)
                    
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
            }
        }
        #endif
    }

}

#if os(iOS)
struct stepTimePicker: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var time: TimeInterval
    
    var body: some View {
        VStack {
            MOTimePicker(time: self.$time)
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
