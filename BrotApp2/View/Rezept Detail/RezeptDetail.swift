//
//  RezeptDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptDetail: View {
    
    @Binding var recipe: Recipe
    
    @EnvironmentObject var recipeStore: RecipeStore
    
    @State private var showingRoomTempSheet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                    .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
                    
            } else{
                Image(uiImage: recipe.image!).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }.padding()
    }
    
    var infoStrip: some View{
        HStack{
            Spacer()
            
            VStack {
                Text("\(recipe.totalTime)")
                Text("Min").secondary()
            }
            
            Spacer()
            
            VStack{
                Text("\(recipe.numberOfIngredients)")
                Text("Zutaten").secondary()
            }
            
            Spacer()
            
            VStack{
                Text("\(recipe.steps.count)")
                Text("Schritte").secondary()
            }
            Spacer()
        }.background(BackgroundGradient())
    }
    
    var startSection: some View {
        VStack(alignment: .leading){
            Text(self.recipe.inverted ? "Ende am " + recipe.formattedEndDate : "Start am " + recipe.formattedStartDate)
                .padding([.top, .leading])
            Picker(" ", selection: self.$recipe.inverted){
                Text("Start").tag(false)
                Text("Ende").tag(true)
            }.pickerStyle(SegmentedPickerStyle())
        }
        .background(BackgroundGradient())
        .padding([.leading, .bottom, .trailing])
    }
    
    var roomThemperturePicker: some View{
        VStack {
            Picker("Raumtemperatur", selection: $recipeStore.roomThemperature){
                ForEach(-10...50, id: \.self){ n in
                    Text("\(n)")
                }
            }
            Button("OK"){
                self.showingRoomTempSheet = false
            }
        }
    }
    
    var roomThemperatureSection: some View{
        HStack {
            Text("Raumtemperatur: \(recipeStore.roomThemperature)°C")
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                self.showingRoomTempSheet = true
            }){ Image(systemName: "pencil")}
                .padding(.trailing)
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(BackgroundGradient().padding(.vertical))
        .sheet(isPresented: self.$showingRoomTempSheet) {
            self.roomThemperturePicker
        }
    }
    
    var recipeSections: some View {
        
        ForEach(self.recipe.steps){step in
            NavigationLink(destination: StepDetail(recipe: self.$recipe, stepIndex: self.recipe.steps.firstIndex(of: step)!)) {
                VStack{
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(step.name).font(.headline)
                            Text(step.formattedTime).secondary()
                        }
                        Spacer()
                        Text(self.recipe.formattedStartDate(for: step))
                    }.padding(.horizontal)
                    
                    ForEach(step.ingredients){ ingredient in
                        HStack{
                            Group{
                                Text(ingredient.name)
                                Spacer()
                                if ingredient.isBulkLiquid{
                                    Text("themp")
                                    Spacer()
                                } else{
                                    EmptyView()
                                }
                                Text("\(ingredient.amount) g")
                            }
                        }.padding(.horizontal)
                    }
                }
                .padding()
                .background(BackgroundGradient())
            }
        .buttonStyle(PlainButtonStyle())
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text(recipe.category.name)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(Color.secondary)
                        .padding(.leading)
                    self.image
                    self.infoStrip
                    self.roomThemperatureSection
                    Text("Arbeitsschritte")
                        .secondary()
                        .padding(.leading)
                    self.startSection
                    self.recipeSections
                    
                    
                    
                }
                .frame(maxWidth: .infinity)
                .navigationBarTitle(recipe.name)
                .navigationBarItems(
                    trailing: HStack{
                        Button(action: {
                            self.fav()
                        }, label: {
                            if self.recipe.isFavourite{
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 30)
                                    .foregroundColor(.primary)
                            } else{
                                Image(systemName: "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 30)
                                    .foregroundColor(.primary)
                            }
                        })
                            .padding()
                        
                        Button(action: {
                            print("edit")
                        }, label: {
                            Image(systemName: "pencil")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 30)
                                .foregroundColor(.primary)
                        })
                            .padding()
                    }
                )
            }
        }
        
    }
    
    func fav(){
        self.recipe.isFavourite.toggle()
    }
    
}




struct RezeptDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RezeptDetail(recipe: .constant(Recipe.example))
                .environmentObject(RecipeStore.example)
                .environment(\.colorScheme, .light)
        }
    }
}


