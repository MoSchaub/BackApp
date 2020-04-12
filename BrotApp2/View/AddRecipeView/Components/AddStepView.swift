//
//  AddStepView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddStepView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipe: Recipe
    
    @State private var step = Step(name: "", time: 60, ingredients: [])
    
    var title: String{
        self.step.name.trimmingCharacters(in: .whitespaces).isEmpty ? "neuer Schritt" : self.step.name
    }
    
    var disabled: Bool{
        self.step.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self.step.ingredients.isEmpty
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 3.0) {
                        Text("Name").secondary()
                            .padding(.leading)
                            .padding(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        TextField("Name", text: self.$step.name)
                            .padding()
                            .padding(.leading)
                            .background(BackgroundGradient())
                    }
                    
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
                    
                    VStack(alignment: .leading, spacing: 3.0 ){
                        Text("Zutaten").secondary()
                            .padding(.leading)
                            .padding(.leading)
                        ForEach(self.step.ingredients){ ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Text("\(String(format: "%.2f", ingredient.amount)) g")
                            }
                            .padding()
                            .padding(.horizontal)
                            .background(BackgroundGradient())
                            
                        }
                        NavigationLink(destination: AddIngredientView(step: self.$step) ){
                            HStack {
                                Text("Zutat hinzufügen")
                                Spacer()
                                Image("chevron.right")
                            }
                            .padding()
                            .padding(.horizontal)
                            .background(BackgroundGradient())
                        }.buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        HStack {
                            Text("OK")
                            Spacer()
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                        .padding(.vertical)
                    }.buttonStyle(PlainButtonStyle())
                        .disabled(self.disabled)
                    
                }
            }
            .navigationBarTitle(self.title)
            .navigationBarItems(trailing: Button("Abbrechen"){ self.presentationMode.wrappedValue.dismiss()})
        }
    }
    
    func save(){
        if let index = recipe.steps.firstIndex(of: step){
            self.recipe.steps[index] = self.step
        }else {
            recipe.steps.append(step)
        }
    }
    
}

struct AddStepsView_Previews: PreviewProvider {
    static var previews: some View {
        AddStepView(recipe: .constant(Recipe.example))
    }
}

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
