//
//  StepDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct StepDetail: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipe: Recipe
    @Binding var step: Step
    
    @State private var selection: Int? = nil
    @State private var selectedIngredient: Ingredient? = nil
    @State private var selectedSubstep: Step? = nil
    
    let deleteEnabled: Bool
    
    var title: String{
        self.step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : self.step.name
    }
    
    let roomTemp: Int
    
    var nameSection: some View{
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
    
    var timeSection: some View{
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
    
    var tempSection: some View {
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
    
    var notesSection: some View{
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
    
    var ingredientsSection: some View {
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
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp, inLink: true, background: true)
                        .padding(.bottom)
                }.buttonStyle(PlainButtonStyle())
            }
            NavigationLink(destination: AddIngredientView(step: self.$step), tag: 2, selection: self.$selection) {
                EmptyView()
            }.hidden()
            NavigationLink(destination: self.subStepPicker, tag: 3, selection: self.$selection) {
                EmptyView()
            }.hidden()
            NavigationLink(destination: self.ingredientOrStep, tag: 1, selection: self.$selection) {
                EmptyView()
            }.hidden()
            Button(action: {
                let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
                if stepsWithIngredients.isEmpty{
                    self.selection = 2 //ingredient
                } else{
                    self.selection = 1 //ingredient or substep
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
                Button("hinzufügen"){
                    let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
                    if stepsWithIngredients.isEmpty{
                        self.selection = 2 //ingredient
                    } else{
                        self.selection = 1 //ingredient or substep
                    }
                }
            }.padding(.horizontal)
            if !self.step.subSteps.isEmpty{
                List(selection: self.$selectedSubstep){
                    //Substeps
                    ForEach(self.step.subSteps, id: \.id){ sub in
                        StepRow(step: sub, recipe: self.recipe, inLink: false, roomTemp: self.roomTemp)
                            .tag(sub)
                    }
                    .onTapGesture {
                        self.selection = nil
                        self.selectedIngredient = nil
                    }
                }
            }
            
            List(selection: self.$selectedIngredient){
                //Ingredients
                ForEach(self.step.ingredients){ ingredient in
                    IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp, inLink: false, background: false).tag(ingredient)
                }
                .onTapGesture {
                    self.selection = nil
                    self.selectedSubstep = nil
                }
            }
                
            
                
            
        }

        
        #endif
    }
    
    var ingredientOrStep: some View{
        VStack{
        Button("Zutat"){
        self.selection = 2 //ingredient
        }
        Button("Schritt"){
        self.selection = 3 //substep
        }
        Button(action: {
        self.selection = nil //cancel
        }) {
        Text("Abbrechen").foregroundColor(.red)
        }
        }
    }
    
    var subStepPicker: some View {
        let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
        #if os(iOS)
        return VStack{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                    self.step.subSteps.append(step)
                    self.selection = 3
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.roomTemp)
                }.buttonStyle(PlainButtonStyle())
            }
        }
        #elseif os(macOS)
        return List{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                    self.step.subSteps.append(step)
                    self.selection = 3
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.roomTemp)
                }.buttonStyle(PlainButtonStyle())
            }
        }
        
        #endif
    }
    
    #if os(iOS)
    var deleteButton: some View{
        Button(action: {
            self.delete()
        }){
            HStack {
                Text("Löschen")
                    .foregroundColor(self.recipe.steps.count > 1 ? .red : .secondary)
                Spacer()
            }
            .neomorphic()
        }
        .disabled(self.recipe.steps.count < 2 || self.deleting)
    }
    #endif
    
    var okButton: some View {
        return Button(action: {
            self.save()
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
                }
            }
            .frame(minWidth: 310, idealWidth: 350, maxWidth: .infinity)
            if self.selection == 1{
                self.ingredientOrStep
            } else if self.selection == 2{
                VStack {
                    AddIngredientView(step: self.$step, selection: self.$selection)
                    Button("Abbrechen"){ self.selection = nil}
                        .padding(.bottom)
                }
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.selection == 3 {
                self.subStepPicker
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.selectedSubstep == nil && self.selectedIngredient != nil{
                VStack {
                    IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(of: self.selectedIngredient!) ?? 0], step: self.$step, selection: .constant(nil))
                    Button(action: {
                        self.deleteIngredient()
                    }){
                        HStack {
                            Text("Löschen")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }.frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            } else if self.selectedIngredient == nil && self.selectedSubstep != nil{
                VStack {
                    StepDetail(recipe: self.$recipe, step: self.$step.subSteps[self.step.subSteps.firstIndex(of: self.selectedSubstep!) ?? 0], deleteEnabled: false, roomTemp: self.roomTemp)
                    Button(action: {
                        self.deleteSubstep()
                    }) {
                        Text("Entfernen")
                    }
                }.frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity)
            }
        }
        #endif
    }
    
    func save(){
        if !deleteEnabled{
            if self.recipe.steps.contains(self.step){
                return
            }
            self.recipe.steps.append(self.step)
            self.step = Step(name: "", time: 60, ingredients: [], themperature: 20)
        }
        #if os(iOS)
        self.presentationMode.wrappedValue.dismiss()
        #endif
    }
    
    @State private var deleting = false
    #if os(iOS)

    func delete(){
        if !self.deleting{
            self.deleting = true
            if self.deleteEnabled, self.recipe.steps.count > 1, let index = self.recipe.steps.firstIndex(of: self.step){
                
                self.presentationMode.wrappedValue.dismiss()
                
                self.step = Step(name: "", time: 60, ingredients: [], themperature: 20)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.recipe.steps.remove(at: index)
                    self.deleting = false
                }
            }
        }
    }
    #elseif os(macOS)
    func deleteIngredient() {
        if let index = self.step.ingredients.firstIndex(of: self.selectedIngredient!), self.step.ingredients.count > index {
            self.selection = nil
            self.selectedIngredient = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.step.ingredients.remove(at: index)
            }
        }
    }
    
    func deleteSubstep() {
        if let index = self.step.subSteps.firstIndex(of: self.selectedSubstep!), self.step.subSteps.count > index{
            self.selection = nil
            self.selectedSubstep = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.step.subSteps.remove(at: index)
            }
        }
    }
    #endif
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
