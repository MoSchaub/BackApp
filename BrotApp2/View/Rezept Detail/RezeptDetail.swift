//
//  RezeptDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptDetail: View {
    
    let recipe: Recipe
    
    var recipeIndex: Int {
        recipeStore.recipes.firstIndex(of: recipe) ?? 0
    }
    
    @State private var showingRoomTempSheet = false
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
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
            Text(recipeStore.recipes[recipeIndex].inverted ? "Ende am " + recipe.formattedEndDate : "Start am " + recipe.formattedStartDate)
                .padding([.top, .leading])
            Picker(" ", selection: self.$recipeStore.recipes[recipeIndex].inverted){
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
        ForEach(recipeStore.recipes[recipeIndex].steps){step in
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
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func fav(){
        self.recipeStore.recipes[self.recipeIndex].isFavourite.toggle()
    }
    
}




struct RezeptDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RezeptDetail(recipe: Recipe.example)
                .environmentObject(RecipeStore.example)
                .environment(\.colorScheme, .light)
        }
    }
}
//struct RezeptDetail: View {
//
//    @EnvironmentObject private var rezeptStore: RecipeStore
//
//    var rezept: Recipe
//
//    var rezeptIndex: Int {
//        rezeptStore.recipes.firstIndex(where: {$0.id == rezept.id }) ?? 0
//    }
//
//    var body: some View {
//        PatialDetailView()
////        List{
////            Section{
////                HStack {
////                    Text("Name:")
////                    TextField("name", text: $rezeptStore.recipes[rezeptIndex].name).textFieldStyle(RoundedBorderTextFieldStyle())
////                }
////
////            }
////
////            NavigationLink(destination: ImagePickerView(inputImage: $rezeptStore.recipes[rezeptIndex].image)) {
////                Image(uiImage: rezeptStore.recipes[rezeptIndex].image ?? UIImage(named: "user")!)
////                    .resizable()
////                    .scaledToFit()
////                    .background(Color.white)
////                    .clipShape(RoundedRectangle(cornerRadius: 15))
////                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.primary, lineWidth: 1))
////                    .shadow(color: .primary, radius: 2)
////                    .padding()
////                    .animation(.default)
////            }
////
////            Section(header: Text("Schritte").font(.headline)){
////                ForEach(rezeptStore.recipes[rezeptIndex].brotValues) { brotValue in
////                    NavigationLink(destination: BrotValueDetail(rezept: self.rezeptStore.recipes[self.rezeptIndex], brotValue: brotValue).environmentObject(self.rezeptStore)) {
////                        BrotValueRow(brotValue: brotValue)
////                    }
////                }
////                .onDelete(perform: deleteBrotValue(at:))
////                .onMove(perform: moveItems(from:to:))
////
////                Button(action: {
////                    let brotValue = BrotValue(id: self.rezeptStore.recipes[self.rezeptIndex].brotValues.count + 1, time: 60, name: "Schritt")
////                    self.rezeptStore.recipes[self.rezeptIndex].brotValues.append(brotValue)
////                }) {
////                    Text("Schritt hinzufügen")
////                }
////
////            }
////
////
////
////            Section{
////                Picker(selection: $rezeptStore.recipes[rezeptIndex].inverted, label: Text("Start-/Enddatum")) {
////                    Text("Enddatum").tag(true)
////                    Text("Startdatum").tag(false)
////                }.pickerStyle(SegmentedPickerStyle())
////
////                MODatePicker(date: $rezeptStore.recipes[rezeptIndex].date )
////
////                if rezeptStore.recipes[rezeptIndex].inverted{
////                    Text("Enddatum: \(dateFormatter.string(from: rezeptStore.recipes[rezeptIndex].endDate()))")
////                }else {
////                    Text("Startdatum: \(dateFormatter.string(from: rezeptStore.rezepte[rezeptIndex].startDate()))")
////                }
////            }
////
////            Section(header: Text("Zeitplan").font(.headline)){
////                Text(rezeptStore.recipes[rezeptIndex].text())
////            }
////        }
////        .listStyle(GroupedListStyle())
////        .navigationBarItems(trailing: EditButton())
////        .navigationBarTitle(Text("\(rezeptStore.recipes[rezeptIndex].name)"))
//    }
//
//    func deleteBrotValue(at offsets: IndexSet) {
//        rezeptStore.recipes[rezeptIndex].steps.remove(atOffsets: offsets)
//    }
//
//    func moveItems(from source: IndexSet, to destination: Int){
//        rezeptStore.recipes[rezeptIndex].steps.move(fromOffsets: source, toOffset: destination)
//    }
//
//}
//
//struct RezeptDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView{
//            RezeptDetail(rezept: RezeptData[0]).environmentObject(RecipeStore())
//        }
//    }
//}


