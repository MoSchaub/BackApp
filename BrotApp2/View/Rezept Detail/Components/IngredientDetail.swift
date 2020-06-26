//
//  IngredientDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct IngredientDetail: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    @State private var amountText = ""
    @Binding var ingredient : Ingredient
    @Binding var step: Step
    let recipe: Recipe
    let creating: Bool
    
    #if os(iOS)
    @Environment(\.presentationMode) var presentationMode

    #endif
    private var title: String {
        ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "neue Zutat" : ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var saveButton: some View {
        Button(action: save){
            Text("OK")
        }.disabled(ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) == nil || stepContains(ingredient: ingredient) && creating)
    }
    
    var body: some View{
        #if os(iOS)
        return List {
            Section(header: Text("Name")) {
                TextField("Name eingeben", text: $ingredient.name)
            }
            
            Section(header: Text("Menge")) {
                TextField("0.00 g", text: $amountText) {
                    self.formatAmountText()
                }
            }
        
            Section {
                Toggle("Schüttflüssigkeit", isOn: $ingredient.isBulkLiquid)
            }
        }
        .navigationBarItems(trailing: saveButton)
            .onAppear{
                self.formatAmountText()
                if self.step.ingredients.firstIndex(where: {$0.id == self.ingredient.id}) != nil{
                    self.amountText = self.ingredient.formattedAmount
                }
        }
        .navigationBarTitle(title)
            
        #elseif os(macOS)
            return VStack(alignment: .leading) {
                HStack {
                    Text("Name:")
                    TextField("Name eingeben", text: $ingredient.name)
                    Spacer()
                }
                .padding([.leading,.top])
                
                HStack {
                    Text("Menge:")
                    TextField("0.00 g", text: $amountText) {
                        self.formatAmountText()
                    }
                    Spacer()
                }
                .padding(.leading)

                HStack {
                    Toggle("Schüttflüssigkeit", isOn: $ingredient.isBulkLiquid)
                    Spacer()
                }
                .padding(.leading)
                
                Spacer()
                HStack {
                    saveButton
                        .padding()
                    if creating {
                        Button(action: {self.dissmiss()}) {
                            Text("Abbrechen")
                        }
                    } else {
                        Button(action: delete) {
                            Text("Löschen").foregroundColor(.red)
                        }
                    }
                    Spacer()
                }
            }
            .onAppear{
                self.formatAmountText()
                if self.step.ingredients.firstIndex(where: {$0.id == self.ingredient.id}) != nil{
                    self.amountText = self.ingredient.formattedAmount
                }
            }
        #endif
    }
    
    func formatAmountText(){
        guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return }
        ingredient.amount = Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        amountText = ingredient.formatted(rest: amountText)
    }
    
    func stepContains(ingredient: Ingredient) -> Bool {
        step.ingredients.contains(where: {$0.name == self.ingredient.name})
    }
    
    func save(){
        formatAmountText()
        guard Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return }
        if !stepContains(ingredient: ingredient) {
            step.ingredients.append(ingredient)
        }
        dissmiss(true)
    }
    
    func dissmiss(_ saving: Bool = false) {
        if creating {
            #if os(macOS)
            recipeStore.sDSelection = nil
            #endif
        } else {
           recipeStore.selectedIngredient = nil
        }
        #if os(iOS)
        presentationMode.wrappedValue.dismiss()
        #endif
    }
    
    func delete(){
        recipeStore.deleteIngredient(of: step, in: recipe)
        dissmiss()
    }
    
}
