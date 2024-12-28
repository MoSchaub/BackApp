// Copyright © 2019 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

struct RecipeDetail: View {
    
    @Binding var recipe: Recipe
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    let creating: Bool
    let addRecipe: ((Recipe) -> Void)?
    let dismiss: (() -> Void)?
    
    private var title: String{
        if recipe.name.isEmpty{
            return "Rezept hinzufügen"
        } else {
            return recipe.name
        }
    }
    
//    @ViewBuilder
//    private func trailingButton() -> some View {
//        if !creating{
//            Image(systemName: recipe.isFavourite ? "heart.fill" : "heart")
//                .foregroundColor(.accentColor)
//                .onTapGesture {
//                    self.$recipe.isFavourite.wrappedValue.toggle()
//            }
//        } else {
//            Button(action: save) {
//                Text("OK")
//            }.disabled(recipeStore.recipes.first(where: {$0.id == self.recipeStore.selectedRecipe?.id})?.steps.isEmpty ?? false )
//        }
//
//    }
    
    @ViewBuilder private func leadingButton() -> some View {
        if creating {
            Button(action: cancel) {
                Text("Abrechen")
            }
        }
    }
    
    private var image: some View {
        Group{
            if recipe.imageString == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
            } else{
                Image(uiImage: UIImage(data: recipe.imageString!)!).resizable().scaledToFit()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
        .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
        .padding()
    .drawingGroup()
    }
    
    private var infoStrip: some View{
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
        }
    }
    
    var body: some View {
        List{
            Section(header: Text("Name")) {
                TextField("Name eingeben", text: self.$recipe.name)
            }
            
            Section(header: Text("Bild")) {
                NavigationLink(destination: ImagePickerView(imageData: self.$recipe.imageString)) {
                    self.image
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !creating{
                self.infoStrip
                NavigationLink(destination: ScheduleForm(recipe: self.$recipe, roomTemp: self.recipeStore.roomTemperature)) {
                    Text("Zeitplan erstellen")
                }
            }
            
            Section(header: Text("Schritte")) {
                ForEach(recipe.steps){ step in
                    NavigationLink(destination: StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(where: {$0.id == step.id}) ?? 0], creating: false)) {
                        StepRow(step: step, recipe: self.recipe, roomTemp: self.recipeStore.roomTemperature)
                    }
                }
                .onDelete(perform: deleteStep)
                .onMove(perform: moveSteps)
                NavigationLink(destination: AddStepView(recipe: $recipe).environmentObject(recipeStore)) {
                    Text("Schritt hinzufügen")
                }
            }
            
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(self.title)
//        .navigationBarItems(leading: leadingButton(), trailing: trailingButton())
    }
    
    func deleteStep(at offsets: IndexSet) {
        recipe.steps.remove(atOffsets: offsets)
    }
    
    func moveSteps(from source: IndexSet, to offset: Int) {
        recipe.steps.move(fromOffsets: source, toOffset: offset)
    }
    
    func save() {
        if creating {
            addRecipe!(self.recipe)
            self.dismiss!()
        }
    }
    
    func cancel() {
        if creating {
            self.dismiss!()
        }
    }
    
    
}


