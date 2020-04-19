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
    
    @State private var recipe = Recipe(name: "", brotValues: [], inverted: false, dateString: "", isFavourite: false, category: Category.example)
    
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
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(BackgroundGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                    .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
                    
            } else{
                Image(uiImage: recipe.image!).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
            }
        }
    }
    
    var imageButton: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bild").secondary().padding(.leading, 35)
            NavigationLink(destination: ImagePickerView(inputImage: self.$recipe.image)) {
                ZStack {
                    image
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
    
    var numberFormatter: NumberFormatter{
        let nF = NumberFormatter()
        nF.numberStyle = .decimal
        return nF
    }
    
    var timesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Anzahl").secondary()
                .padding(.leading, 35)
            DecimalField("Anzahl eingeben", value: self.$recipe.times, formatter: self.numberFormatter)
                .padding(.leading)
                .padding()
                .background(BackgroundGradient())
        }
    }
    
    var stepSection: some View {
        VStack {
            VStack(alignment: .leading, spacing: 2.0){
                HStack {
                    Text("Arbeitsschritte").secondary()
                        
                    Spacer()
                }
                .padding(.leading)
                .padding(.leading)
                ForEach(self.recipe.steps){step in
                    NavigationLink(destination: StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(of: step)!], deleteEnabled: true, roomTemp: self.recipeStore.roomThemperature)) {
                        StepRow(step: step, recipe: self.recipe, inLink: true, roomTemp: self.recipeStore.roomThemperature)
                    }.buttonStyle(PlainButtonStyle())
                    
                }
            }
            NavigationLink(destination: AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)) {
                HStack {
                    Text("Schritt hinzufügen")
                    Spacer()
                    Image(systemName: "chevron.right")
                }.padding()
                    .padding(.horizontal)
                    .background(BackgroundGradient())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var addButton: some View {
        Button(action: {
            self.save()
        }){
            Text("hinzufügen").neomorphic()
        }.disabled(self.disabled)
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading){
                    self.name
                    self.timesSection
                    self.imageButton
                    self.categoryButton
                    self.stepSection
                    self.addButton
                }
            }
            .navigationBarTitle(self.title)
            .navigationBarItems(leading: Button("Abbrechen"){
                self.presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.accentColor) , trailing: Button("OK"){ self.save()}.disabled(self.disabled))
        }.onAppear(){
            self.recipe.category = self.recipeStore.categories.first ?? Category.example
        }
    }
    
    func stepIndex(for step: Step) -> Int? {
        self.recipe.steps.firstIndex(of: step)
    }
    
    func IndexFound(for step: Step) -> Bool{
        self.stepIndex(for: step) != nil
    }
    
    func formattedTime(for step: Step) -> String{
        let time = self.recipe.steps[self.stepIndex(for: step)!].time
        return String(format: "%.0f" + "\(time == 60 ? " Minute" : " Minuten" )" , "\(time/60)")
    }
    
    func save(){
        recipeStore.addRecipe(recipe: self.recipe)
        self.isPresented = false
    }
    
}

struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipeView(isPresented: .constant(true)).environmentObject(RecipeStore.example)
    }
}
