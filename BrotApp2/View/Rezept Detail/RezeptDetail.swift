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
    @State private var deleting = false
    
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
                        .padding(.vertical)
                        .background(BackgroundGradient())
                        .padding([.horizontal,.bottom])
                }
            } else{
                EmptyView()
            }
        }
    }
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(BackgroundGradient())
            } else{
                #if os(iOS)
                Image(uiImage: recipe.image!).resizable().scaledToFit()
                #elseif os(macOS)
                Image(nsImage: recipe.image!).resizable().scaledToFit()
                #endif
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
        .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
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
                    }
                        .neomorphic()
                }.buttonStyle(PlainButtonStyle())
            } else {
                HStack {
                    Text(recipe.category.name).secondary()
                    Spacer()
                }.padding(.leading)
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
        }
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
        Group{
            if self.editMode{
               VStack {
                    ForEach(0..<recipe.steps.count, id: \.self){ n in
                        NavigationLink(destination: StepDetail(recipe: self.$recipe, step: self.$recipe.steps[n], deleteEnabled: true, roomTemp: self.recipeStore.roomThemperature)) {
                            StepRow(step: self.recipe.steps[n], recipe: self.recipe, inLink: true, roomTemp: self.recipeStore.roomThemperature)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    NavigationLink(destination: AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature)) {
                        HStack {
                            Text("Schritt hinzufügen")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    .neomorphic()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
               ForEach(0..<recipe.steps.count, id: \.self){ n in
                    StepRow(step: self.recipe.steps[n], recipe: self.recipe, inLink: false, roomTemp: self.recipeStore.roomThemperature)
                }
            }
        }
    }
    
//    var deleteSection: some View{
//        Group {
//            if self.editMode {
//                Button(action: {
//                    self.delete()
//                }){
//                    HStack {
//                        Text("Löschen")
//                            .foregroundColor(self.recipeStore.recipes.count < 1 ? .secondary : .red)
//                        Spacer()
//                    }
//                    .neomorphic()
//                }
//                .disabled(self.recipeStore.recipes.count < 1 )
//            } else {
//                EmptyView()
//            }
//        }
//    }
    
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
                //self.deleteSection
            }
            .frame(maxWidth: .infinity)
            .navigationBarTitle(self.title)
            .navigationBarItems(
                trailing: self.trailingButtons
            )
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
    }
    
    func fav(){
        self.recipe.isFavourite.toggle()
    }
    
    func delete(){
        if self.recipeStore.recipes.count > 1, let index = self.recipeStore.recipes.firstIndex(of: self.recipe){
            
            self.presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                print("hello")
            }
            print("Hello2")
            if !self.deleting{
                self.deleting = true
                self.recipeStore.recipes.remove(at: index)
                self.deleting = false
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


