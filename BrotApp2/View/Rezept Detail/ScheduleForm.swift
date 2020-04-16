//
//  ScheduleForm.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 16.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

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
            Text("Anzahl").secondary()
                .padding(.leading, 35)
            DecimalField("Anzahl eingeben", value: self.$times, formatter: self.numberFormatter)
                .padding(.leading)
                .padding()
                .background(BackgroundGradient())
        }
    }
    
    var alert: Alert{
        Alert(title: Text("Fehler"), message: Text("Bitte gebe ein welche Menge du machen möchtest"), dismissButton: .default(Text("Ok")))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(Color.init(.secondarySystemBackground),Color.init(.systemBackground)).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(){
                    
                    timesSection
                    
                    VStack {
                        MODatePicker(date: self.$recipe.date)
                            .frame(width: UIScreen.main.bounds.width - 60)
                            .clipped()
                        Picker("s", selection: self.$recipe.inverted){
                            Text("Start").tag(false)
                            Text("Ende").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: UIScreen.main.bounds.width - 30)
                        .padding(.bottom)
                        .clipped()
                    }.background(BackgroundGradient())
                    Text(recipe.formattedDate).font(.title).padding()
                    Button(action: {
                        if self.times != nil{
                            self.showingSchedule = true
                        } else{
                            self.showingAlert = true
                        }
                    }){
                        Text("weiter")
                            .foregroundColor(.primary)
                            .padding()
                            .background(BackgroundGradient())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    .alert(isPresented: self.$showingAlert) {
                        self.alert
                    }
                    NavigationLink(destination: ScheduleView(recipe: recipe, roomTemp: self.roomTemp, times: self.times), isActive: self.$showingSchedule) {
                       EmptyView()
                    }
                    
                    Button(action:{
                       self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("zurück")
                            .foregroundColor(.primary)
                            .padding()
                            .background(BackgroundGradient())
                    }.padding()
                }
            }
        }
            .onAppear{
                self.times = self.recipe.times
            }
        .navigationBarTitle(Text(recipe.name), displayMode: .inline)
        
    }
}

struct ScheduleForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleForm(recipe: .constant(Recipe.example), roomTemp: 20)
        }
    }
}
