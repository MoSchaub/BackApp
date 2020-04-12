//
//  StepDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct StepDetail: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipe: Recipe
    
    var stepIndex: Int
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 3.0) {
                    Text("Name").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    TextField("Name", text: self.$recipe.steps[self.stepIndex].name)
                        .padding()
                        .padding(.leading)
                        .background(BackgroundGradient())
                }
                
                NavigationLink(destination: stepTimePicker(time: self.$recipe.steps[self.stepIndex].time)) {
                    HStack {
                        Text("Dauer:")
                        Spacer()
                        Text(self.recipe.steps[self.stepIndex].formattedTime)
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(BackgroundGradient())
                    .padding(.vertical)
                }.buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 3.0 ){
                    Text("Zutaten").secondary()
                        .padding(.leading)
                        .padding(.leading)
                    ForEach(self.recipe.steps[self.stepIndex].ingredients){ ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(String(format: "%.2f", ingredient.amount)) g")
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                        
                    }
                    NavigationLink(destination: AddIngredientView(step: self.$recipe.steps[self.stepIndex]) ){
                        HStack {
                            Text("Zutat hinzufügen")
                            Spacer()
                            Image("chevron.right")
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                    }.buttonStyle(PlainButtonStyle())
                    
                        Button(action: {
                            self.delete()
                        }){
                            HStack {
                                Text("Loschen")
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
        }
        .navigationBarTitle(self.recipe.steps[self.stepIndex].name)
    }
    
    func delete(){
        if self.recipe.steps.count > 1{
            self.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipe.steps.remove(at: self.stepIndex)
            }
        }
    }
    
}

