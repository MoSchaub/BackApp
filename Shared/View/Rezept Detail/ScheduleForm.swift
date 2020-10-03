//
//  ScheduleForm.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 16.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation

struct ScheduleForm: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipe: Recipe
    
    let roomTemp: Int
    
    @State private var times: Decimal? = 1
    @State private var showingSchedule = false
    @State private var showingAlert = false
    
    var numberFormatter: NumberFormatter{
        let nF = NumberFormatter()
        nF.numberStyle = .decimal
        return nF
    }
    
    var timesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("amount").secondary()
                .padding(.leading, 35)
            DecimalField("amountCellPlaceholder2", value: self.$times, formatter: self.numberFormatter)
                .padding([.leading, .vertical])
                .background(Color("blue"))
                .cornerRadius(10)
                .padding([.horizontal,.bottom])
        }
    }
    
    var alert: Alert{
        Alert(title: Text("Fehler"), message: Text("Bitte gebe eine Anzahl an"), dismissButton: .default(Text("Ok")))
    }
    
    var okButton: some View {
        Button(action: {
            if self.times != nil{
                self.showingSchedule = true
            } else{
                self.showingAlert = true
            }
        }){
            Text("OK")
            .padding()
        }
        .alert(isPresented: self.$showingAlert) {
            self.alert
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack{
                    self.timesSection
                    VStack(alignment: .center) {
                        MODatePicker(date: self.$recipe.date)
                            .frame(width: geo.size.width * 0.75)
                            .clipped()
                        Picker("s", selection: self.$recipe.inverted){
                            Text("start").tag(false)
                            Text("end").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                        .clipped()
                    }
                    .background(Color("blue"))
                    .cornerRadius(10)
                    .padding()
                }
                NavigationLink(destination: ScheduleView(recipe: self.recipe, roomTemp: self.roomTemp, times: self.times), isActive: self.$showingSchedule) {
                    EmptyView()
                }
            }
        }
        .onAppear{
            self.times = self.recipe.times
        }
        .navigationBarTitle(
            Text(recipe.formattedName),
            displayMode: NavigationBarItem.TitleDisplayMode.inline
        )
            .navigationBarItems(trailing: okButton)
    }
}

struct ScheduleForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleForm(recipe: .constant(Recipe.example), roomTemp: 20)
        }
    }
}
