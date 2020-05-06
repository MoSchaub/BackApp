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
    
    let roomTemp: Int
    
    @State private var step = Step(name: "", time: 60, ingredients: [], themperature: 20)
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
            Alert(title: Text("Achtung"), message: Text("Dieser Schritt wird nicht gespeichert"), primaryButton: .default(Text("OK"), action: {
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
    
    var body: some View {
        StepDetail(recipe: self.$recipe, step: self.$step, deleteEnabled: false, roomTemp: self.roomTemp)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: self.backButton, trailing: self.saveButton)
    }
    
    func save(){
        self.recipe.steps.append(self.step)
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddStepsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddStepView(recipe: .constant(Recipe.example), roomTemp: 20)
        }
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

struct stepTempPicker: View{
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var temp: Int
    
    var body: some View {
        VStack {
            Picker(" ",selection: self.$temp){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            .labelsHidden()
            .padding()
            Button("OK"){ self.presentationMode.wrappedValue.dismiss()}
        }
    }
}
