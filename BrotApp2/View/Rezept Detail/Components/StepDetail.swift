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
    
    @State var isEditing = false
    
    let deleteEnabled: Bool
    
    var title: String{
        self.step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : self.step.name
    }
    
    let roomTemp: Int
    
    var disabled: Bool{
        self.step.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self.step.ingredients.isEmpty
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
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                
                self.nameSection
                
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
                
                VStack(alignment: .leading, spacing: 3.0 ){
                    Text("Zutaten").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    ForEach(self.step.ingredients){ ingredient in
                        NavigationLink(destination: IngredientDetail(ingredient: self.$step.ingredients[self.step.ingredients.firstIndex(of: ingredient)!], step: self.$step, deleteEnabled: true)){
                            IngredientRow(ingredient: ingredient, step: self.step, roomTemp: self.roomTemp)
                            .padding()
                            .padding(.horizontal)
                            .background(BackgroundGradient())
                        }.buttonStyle(PlainButtonStyle())
                    }
                    NavigationLink(destination: AddIngredientView(step: self.$step) ){
                        HStack {
                            Text("Zutat hinzufügen")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                    }.buttonStyle(PlainButtonStyle())
                    
                    if self.deleteEnabled{
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
                    } else{
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
                }
            }
        }
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

