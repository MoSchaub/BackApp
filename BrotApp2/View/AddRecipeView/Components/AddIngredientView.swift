//
//  AddIngredientView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 12.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddIngredientView: View{
    @State private var ingredient = Ingredient(name: "", amount: 0)
    
    @Binding var step: Step
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var warningAlertShown = false
       
    var backButton: some View{
        Button(action: {
            self.warningAlertShown = true
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
            Text("Speichern")
        }
    }
    
    var body: some View{
        IngredientDetail(ingredient: self.$ingredient, step: self.$step, deleteEnabled: false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: self.backButton, trailing: self.saveButton)
        
    }
    
    func save(){
        self.step.ingredients.append(self.ingredient)
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        AddIngredientView(step: .constant(Step(name: "", time: 60, ingredients: [], themperature: 20)))
    }
}
