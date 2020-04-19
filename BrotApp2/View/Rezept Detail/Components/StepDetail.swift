//
//  StepDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct StepDetail: View {
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipe: Recipe
    @Binding var step: Step
    
    @State private var isEditing = false
    @State private var showingIngredientsOrSubstepsActionSheet = false
    @State private var showingAddIngredientView = false
    @State private var showingSubStepPicker = false
    
    let deleteEnabled: Bool
    
    var title: String{
        self.step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : self.step.name
    }
    
    let roomTemp: Int
    
    var disabled: Bool{
        self.step.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self.step.ingredients.isEmpty && self.step.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var nameSection: some View{
        VStack(alignment: .leading, spacing: 3.0) {
            Text("Name").secondary()
                .padding(.leading)
                .padding(.leading)
            TextField("Name", text: self.$step.name, onEditingChanged: { (editing) in
                self.isEditing = editing
            }, onCommit: {
                
            })
                .padding()
                .padding(.leading)
                .background(BackgroundGradient())
        }
    }
    
    var timeSection: some View{
        NavigationLink(destination: stepTimePicker(time: self.$step.time)) {
            HStack {
                Text("Dauer:")
                Spacer()
                Text(self.step.formattedTime)
                Image(systemName: "chevron.right")
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
            .padding(.vertical)
        }.buttonStyle(PlainButtonStyle())
    }
    
    var tempSection: some View {
        NavigationLink(destination: stepTempPicker(temp: self.$step.themperature) ) {
            HStack {
                Text("Temperatur")
                Spacer()
                Text(self.step.formattedTemp)
                Image(systemName: "chevron.right")
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
            .padding(.vertical)
        }.buttonStyle(PlainButtonStyle())
    }
    
    var notesSection: some View{
        VStack(alignment: .leading, spacing: 3.0) {
            Text("Notizen").secondary()
                .padding(.leading)
                .padding(.leading)
            TextField("Notizen...",text: self.$step.notes, onEditingChanged: { (editing) in
                self.isEditing = editing
            }, onCommit: {
                
            })
                .padding()
                .padding(.leading)
                .background(BackgroundGradient())
        }
    }
    
    var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 3.0 ){
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
            NavigationLink(destination: AddIngredientView(step: self.$step), isActive: self.$showingAddIngredientView) {
                EmptyView()
            }
            NavigationLink(destination: self.subStepPicker, isActive: self.$showingSubStepPicker) {
                EmptyView()
            }
            Button(action: {
                if self.recipe.steps.isEmpty{
                    self.showingAddIngredientView = true
                } else{
                    self.showingIngredientsOrSubstepsActionSheet = true
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
            }.buttonStyle(PlainButtonStyle())
        }.actionSheet(isPresented: self.$showingIngredientsOrSubstepsActionSheet) {
            ActionSheet(title: Text("Zutat oder Schritt?"), buttons: [.default(Text("Zutat"), action: {
                self.showingAddIngredientView = true
            }),.default(Text("Schritt"), action: {
                //TODO: Present all steps with at least one ingredient
                self.showingSubStepPicker = true
            }),.cancel()])
        }
    }
    
    var subStepPicker: some View {
        let stepsWithIngredients = self.recipe.steps.filter({ $0 != self.step && !$0.ingredients.isEmpty})
        return VStack{
            ForEach(stepsWithIngredients){step in
                Button(action: {
                    self.step.subSteps.append(step)
                    self.showingSubStepPicker = false
                }){
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.roomTemp)
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var deleteButton: some View{
        Button(action: {
            self.delete()
        }){
            HStack {
                Text("Löschen")
                    .foregroundColor(self.recipe.steps.count > 1 ? .red : .secondary)
                Spacer()
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
            .padding(.vertical)
        }
        .disabled(self.recipe.steps.count < 2)
    }
    
    var okButton: some View {
        Button(action: {
            self.save()
        }){
            HStack {
                Text("OK")
                Spacer()
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
            .padding(.vertical)
        }.disabled(self.disabled)
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
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
        }
        //.offset(y: -keyboardResponder.currentHeight)
        .navigationBarTitle(self.title)
        .navigationBarHidden(self.isEditing)
    }
    
    func save(){
        if !deleteEnabled{
            self.recipe.steps.append(self.step)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func delete(){
        if self.deleteEnabled, self.recipe.steps.count > 1, let index = self.recipe.steps.firstIndex(of: self.step){
            self.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipe.steps.remove(at: index)
            }
        }
    }
    
}

