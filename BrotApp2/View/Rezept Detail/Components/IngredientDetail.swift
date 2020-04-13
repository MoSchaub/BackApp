//
//  IngredientDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct IngredientDetail: View {
    @State private var amountText = "0.00 g"
    
    @Binding var ingredient : Ingredient
    @Binding var step: Step
    
    let deleteEnabled: Bool
    
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
                            self.ingredient.amount = Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                            self.amountText = self.ingredient.formatted(rest: self.amountText)
                        }
                        Spacer()
                    }.padding()
                        .padding(.leading)
                        .background(BackgroundGradient())
                        .padding(.bottom)
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
            if self.deleteEnabled{
                Button(action: {
                    self.delete()
                }){
                    HStack {
                        Text("Löschen")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(BackgroundGradient())
                    .padding(.vertical)
                }
            }
        }
        .onAppear{
            self.amountText =  self.ingredient.formattedAmount
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
    
    func delete(){
        if self.step.ingredients.count > 1, let index = self.step.ingredients.firstIndex(of: self.ingredient){
            self.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.step.ingredients.remove(at: index)
            }
        }
    }
}
