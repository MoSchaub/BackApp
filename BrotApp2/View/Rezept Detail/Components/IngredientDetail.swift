//
//  IngredientDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct IngredientDetail: View {
    @State private var amountText = ""
    
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
                        .padding(.leading)
                        .padding(.vertical)
                        .background(BackgroundGradient())
                        .padding([.horizontal,.bottom])
                }
                VStack(alignment: .leading, spacing: 3.0) {
                    Text("Menge").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    HStack {
                        TextField("0.00 g", text: self.$amountText) {
                            self.formatAmountText()
                        }
                        Spacer()
                    }
                        .padding(.leading)
                        .padding(.vertical)
                        .background(BackgroundGradient())
                        .padding([.horizontal,.bottom])
                }

                HStack {
                    Toggle("Schüttflüssigkeit", isOn: self.$ingredient.isBulkLiquid)
                    Spacer()
                }
                .neomorphic()
                
                Button(action: {
                    self.save()
                }){
                    HStack {
                        Text("OK")
                        Spacer()
                    }
                .neomorphic()
                }.disabled(self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
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
                .neomorphic()
                }
            }
        }
        .onAppear{
            self.formatAmountText()
            if self.step.ingredients.firstIndex(where: {$0.id == self.ingredient.id}) != nil{
                self.amountText = self.ingredient.formattedAmount
            }
        }
        .navigationBarTitle(self.title)
    }
    
    func formatAmountText(){
        guard Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return }
        self.ingredient.amount = Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        self.amountText = self.ingredient.formatted(rest: self.amountText)
    }
    
    func save(){
        self.formatAmountText()
        guard Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return }
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
