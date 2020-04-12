//
//  AddIngredientView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddIngredientView: View{
    @State private var ingredient = Ingredient(name: "", amount: 10)
    @State private var amountText = "0.00"
    @State private var unit = "g"
    
    @Binding var step: Step
    
    @Environment(\.presentationMode) var presentationMode

    var title: String {
        self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "neue Zutat" : self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 3.0) {
                    Text("Name").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    TextField("Name", text: $ingredient.name)
                        .padding()
                        .padding(.leading)
                        .background(BackgroundGradient())
                }
                VStack(alignment: .leading, spacing: 3.0) {
                    Text("Menge").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    HStack {
                        TextField("Menge", text: self.$amountText) {
                            self.ingredient.amount = Double(self.amountText) ?? 0.0
                            self.amountText = String(format: "%\(".2")f", self.ingredient.amount)
                        }
                        Text(self.unit)
                        Spacer()
                    }.padding()
                        .padding(.leading)
                        .background(BackgroundGradient())
                }

                HStack {
                    Toggle("Schüttflüssigkeit", isOn: self.$ingredient.isBulkLiquid)
                    Spacer()
                }
                .padding()
                .padding(.leading)
                .background(BackgroundGradient())
                
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
                }.disabled(self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self.amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationBarTitle(self.title)
    }
    
    func save(){
        if let index = self.step.ingredients.firstIndex(where: {$0.id == self.ingredient.id}){
            self.step.ingredients[index] = self.ingredient
        } else {
            self.step.ingredients.append(self.ingredient)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        AddIngredientView(step: .constant(Step(name: "", time: 60, ingredients: [])))
    }
}
