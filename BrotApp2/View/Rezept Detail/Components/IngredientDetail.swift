//
//  IngredientDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct IngredientDetail: View {
    @Binding var ingredient : Ingredient
    @Binding var step: Step
    let recipe: Recipe
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @State private var amountText = ""
    
    #if os(iOS)
    @Environment(\.presentationMode) var presentationMode
    let deleteEnabled: Bool
    @State private var warningAlertShown = false
    
    var backButton: some View{
        Button(action: {
            if !self.deleteEnabled {
                self.warningAlertShown = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack{
                
                Image(systemName: "chevron.left")
                Text("zurück")
                
            }
        }.alert(isPresented: self.$warningAlertShown) {
            Alert(title: Text("Achtung"), message: Text("Diese Zutat wird nicht gespeichert"), primaryButton: .default(Text("OK"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .cancel())
        }
    }
    
    var saveButton: some View {
        Button(action: {
            self.save()
        }){
            HStack {
                Text("OK")
                Spacer()
            }
        }.disabled(self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
    }
    #elseif os(macOS)
    
    let backButton = EmptyView()
    
    var saveButton = EmptyView()
    
    let creating: Bool
    #endif
    var title: String {
        self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "neue Zutat" : self.ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View{
        ScrollView{
            #if os(iOS)
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
            #elseif os(macOS)
            VStack(alignment: .leading) {
                HStack {
                    Text("Name:")
                    TextField("Name eingeben", text: $ingredient.name)
                    Spacer()
                }
                .padding([.leading,.top])
                
                HStack {
                    Text("Menge:")
                    TextField("0.00 g", text: self.$amountText) {
                        self.formatAmountText()
                    }
                    Spacer()
                }
                .padding(.leading)

                HStack {
                    Toggle("Schüttflüssigkeit", isOn: self.$ingredient.isBulkLiquid)
                    Spacer()
                }
                .padding(.leading)
                
                Spacer()
                if self.creating {
                    Button(action: {
                        self.save()
                    }){
                        Text("OK")
                    }.disabled(ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) == nil || stepContains(ingredient: ingredient))
                        .padding(.leading)
                } else {
                    Button(action: {
                        self.delete()
                    }) {
                        Text("Löschen").foregroundColor(.red)
                    }.padding(.leading)
                }
            }
            
            #endif
        }
        .navigationBarItems(leading: self.backButton, trailing: self.saveButton)
        .navigationBarBackButtonHidden(true)
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
    
    func stepContains(ingredient: Ingredient) -> Bool {
        self.step.ingredients.contains(where: {$0.name == self.ingredient.name})
    }
    
    func save(){
        self.formatAmountText()
        guard Double(self.amountText.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines)) != nil else { return }
        if !stepContains(ingredient: self.ingredient) {
            self.step.ingredients.append(self.ingredient)
        }
        #if os(iOS)
        self.presentationMode.wrappedValue.dismiss()
        #elseif os(macOS)
        if creating {
            self.recipeStore.sDSelection = nil
        } else {
            self.recipeStore.selectedIngredient = nil
        }
        #endif
    }
    
    
    func delete(){
        self.recipeStore.deleteIngredient(of: step, in: recipe)
        #if os(iOS)
        self.presentationMode.wrappedValue.dismiss()
        #endif
    }
    
}
