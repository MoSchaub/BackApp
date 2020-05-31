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
    
    #if os(iOS)
    @Environment(\.presentationMode) var presentationMode
    @State private var warningAlertShown = false
    #endif
    #if os(iOS)
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
    
    func save(){
        self.step.ingredients.append(self.ingredient)
        self.presentationMode.wrappedValue.dismiss()
    }
    
#endif

    var body: some View{
        #if os(iOS)
        return IngredientDetail(ingredient: self.$ingredient, step: self.$step, deleteEnabled: false)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: self.backButton, trailing: self.saveButton)
        #elseif os(macOS)
        return IngredientDetail(ingredient: self.$ingredient, step: self.$step, creating: true)
        #endif
        
        
    }
}

struct AddIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        return AddIngredientView(step: .constant(Step(name: "", time: 60, ingredients: [], themperature: 20)))
        #elseif os(macOS)
        return AddIngredientView(step: .constant(Step(name: "", time: 60, ingredients: [], themperature: 20)))
        #endif
        
    }
}
