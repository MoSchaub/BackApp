//
//  AddRecipeView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 08.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct AddRecipeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @Binding var isPresented: Bool
    
    @State private var recipe = Recipe(name: "", brotValues: [], inverted: false, dateString: "", imageString: "", isFavourite: false, category: Category.example)
    @State private var showingStepsSheet = false
    
    var disabled: Bool{
        recipe.name.isEmpty || recipe.steps.isEmpty
    }
    
    var title: String{
        if recipe.name.isEmpty{
            return "Rezept hinzufügen"
        } else {
            return recipe.name
        }
    }
    
    var name: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Name").secondary()
                .padding(.leading, 35)
            TextField("Name eingeben", text: self.$recipe.name)
                .padding(.leading)
                .padding()
                .background(BackgroundGradient())
        }
    }
    
    var image: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bild").secondary().padding(.leading, 35)
            NavigationLink(destination: ImagePickerView(inputImage: self.$recipe.image)) {
                ZStack {
                    Image(uiImage: self.recipe.image ?? UIImage(named: "bread")!)
                        .resizable()
                        .scaledToFill()
                        .background(BackgroundGradient())
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                        
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right").padding(.trailing)
                    }
                }.padding([.leading, .bottom, .trailing])
            }.buttonStyle(PlainButtonStyle())
        }
    }
    
    var categoryButton: some View {
        NavigationLink(destination: CategoryPicker(recipe: self.$recipe).environmentObject(self.recipeStore)) {
            HStack {
                Text("Kategorie: ")
                Spacer()
                HStack() {
                    Text(self.recipe.category.name)
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
        }.buttonStyle(PlainButtonStyle())
    }
    
    var stepSection: some View {
        VStack {
            VStack(alignment: .leading, spacing: 3.0){
                Text("Arbeitsschritte").secondary()
                    .padding(.leading)
                    .padding(.leading)
                Button(action: {
                    self.showingStepsSheet = true
                }){
                    HStack {
                        Text("Schritt hinzufügen")
                        Spacer()
                        Image(systemName: "chevron.up")
                    }.padding()
                    .padding(.horizontal)
                    .background(BackgroundGradient())
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: self.$showingStepsSheet) {
                    AddStepView(recipe: self.$recipe)
                }
            }
            ForEach(self.recipe.steps){step in
                VStack(alignment: .leading){
                    HStack {
                        Text(step.name).font(.headline)
                        Spacer()
                        Text(step.formattedTime).secondary()
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
    }
    
    var addButton: some View {
        Button(action: {
            self.save()
            self.isPresented = false
        }){
            HStack {
                Text("hinzufügen")
                Spacer()
            }
            .padding()
            .padding(.horizontal)
            .background(BackgroundGradient())
            .padding(.vertical)
        }.disabled(self.disabled)
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading){
                    self.name
                    self.image
                    self.categoryButton
                    self.stepSection
                    self.addButton
                }
            }
            .navigationBarTitle(self.title)
            .navigationBarItems(trailing: Button("Abbrechen"){
                self.presentationMode.wrappedValue.dismiss()
            })
        }.onAppear(){
            self.recipe.category = self.recipeStore.categories.first ?? Category.example
        }
    }
    
    func stepIndex(for step: BrotValue) -> Int? {
        self.recipe.steps.firstIndex(of: step)
    }
    
    func IndexFound(for step: BrotValue) -> Bool{
        self.stepIndex(for: step) != nil
    }
    
    func formattedTime(for step: BrotValue) -> String{
        let time = self.recipe.steps[self.stepIndex(for: step)!].time
        return String(format: "%.0f" + "\(time == 60 ? " Minute" : " Minuten" )" , "\(time/60)")
    }
    
    func save(){
        recipeStore.addRecipe(recipe: self.recipe)
    }
    
}

struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeView(isPresented: .constant(true)).environmentObject(RecipeStore.example)
    }
}
