//
//  RezeptDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptDetail: View {
    @State private var editMode = false
    
    @Binding var recipe: Recipe
    
    @EnvironmentObject var recipeStore: RecipeStore
    
    @Environment(\.presentationMode) var presentationMode
    
    var title: String{
        if recipe.name.isEmpty{
            return "Rezept hinzufügen"
        } else {
            return recipe.name
        }
    }
    
    var trailingButtons: some View{
        HStack{
            Toggle(isOn: self.$recipe.isFavourite) {
                if self.recipe.isFavourite{
                    Image(systemName: "heart.fill")
                        .foregroundColor(.primary)
                } else{
                    Image(systemName: "heart")
                        .foregroundColor(.primary)
                }
            }.toggleStyle(NeomorphicToggleStyle())
            
            Toggle(isOn: self.$editMode) {
                Image(systemName: "pencil")
                    .foregroundColor(.primary)
            }.toggleStyle(NeomorphicToggleStyle())
            
        }
    }
    
    var nameSection: some View{
        Group{
            if editMode{
                VStack(alignment: .leading, spacing: 0) {
                    Text("Name").secondary()
                        .padding(.leading, 35)
                    TextField("Name eingeben", text: self.$recipe.name)
                        .padding(.leading)
                        .padding()
                        .background(BackgroundGradient())
                }
            } else{
                EmptyView()
            }
        }
    }
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(BackgroundGradient())
            } else{
                Image(uiImage: recipe.image!).resizable().scaledToFit()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
        .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
        .padding()
    }
    
    var imageSection: some View{
        Group{
            if self.editMode{
                NavigationLink(destination: ImagePickerView(inputImage: self.$recipe.image)) {
                    ZStack {
                        self.image
                        HStack{
                            Spacer()
                            Image(systemName: "chevron.right")
                            
                        }
                        .padding(.trailing)
                        .padding(.trailing)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } else{
                self.image
            }
        }
    }
    
    var categorySection: some View{
        Group {
            if self.editMode {
                NavigationLink(destination: CategoryPicker(recipe: self.$recipe)) {
                    HStack {
                        Text("Kategorie:")
                        Spacer()
                        Text(recipe.category.name).secondary()
                        Image("chevron.right")
                    }.padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                }.buttonStyle(PlainButtonStyle())
            } else {
                HStack {
                    Text(recipe.category.name).secondary()
                    Spacer()
                }.padding()
                    .padding(.leading)
                    .background(BackgroundGradient())
            }
        }
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
    
    var startButton: some View{
        NavigationLink(destination: ScheduleForm(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)) {
            HStack {
                Text("Zeitplan erstellen")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .neomorphic()
        }.buttonStyle(PlainButtonStyle())
    }
    
    var stepSections: some View {
        ForEach(self.recipe.steps){step in
            Group {
                if self.editMode {
                    NavigationLink(destination: StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(of: step)!], deleteEnabled: true, roomTemp: self.recipeStore.roomThemperature)) {
                        StepRow(step: step, recipe: self.recipe, inLink: true, roomTemp: self.recipeStore.roomThemperature)
                    }
                    .buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)) {
                        HStack {
                            Text("Schritt hinzufügen")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .padding(.horizontal)
                        .background(BackgroundGradient())
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    StepRow(step: step, recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                    EmptyView()
                }
            }
        }
    }
    
    var deleteSection: some View{
        Group {
            if self.editMode {
                Button(action: {
                    self.delete()
                }){
                    HStack {
                        Text("Löschen")
                            .foregroundColor(self.recipeStore.recipes.count < 1 ? .secondary : .red)
                        Spacer()
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(BackgroundGradient())
                    .padding(.vertical)
                }
                .disabled(self.recipeStore.recipes.count < 1 )
            } else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                self.nameSection
                if !editMode{
                    self.categorySection
                }
                self.imageSection
                if editMode{
                    self.categorySection
                }
                if !editMode{
                    self.infoStrip
                    self.startButton
                }
                Text("Arbeitsschritte")
                    .secondary()
                    .padding(.leading)
                    .padding(.leading)
                self.stepSections
                self.deleteSection
            }
            .frame(maxWidth: .infinity)
            .navigationBarTitle(self.title)
            .navigationBarItems(
                trailing: self.trailingButtons
            )
        }
    }
    
    func fav(){
        self.recipe.isFavourite.toggle()
    }
    
    func delete(){
        if self.recipeStore.recipes.count > 1, let index = self.recipeStore.recipes.firstIndex(of: self.recipe){
            self.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.recipeStore.recipes.remove(at: index)
            }
        }
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


