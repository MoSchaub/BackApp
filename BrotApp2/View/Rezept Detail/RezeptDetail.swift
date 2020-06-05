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
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    let isDetail: Bool
    
    private var title: String{
        if recipe.name.isEmpty{
            return "Rezept hinzufügen"
        } else {
            return recipe.name
        }
    }
    
    private var trailingButton: some View{
        Toggle(isOn: self.$recipe.isFavourite) {
            if self.recipe.isFavourite{
                Image(systemName: "heart.fill")
                    .foregroundColor(.primary)
            } else{
                Image(systemName: "heart")
                    .foregroundColor(.primary)
            }
        }.toggleStyle(NeomorphicToggleStyle())
    }
    
    private var nameSection: some View{
        VStack(alignment: .leading, spacing: 0) {
            Text("Name").secondary()
                .padding(.leading, 35)
            TextField("Name eingeben", text: self.$recipe.name)
                .padding(.leading)
                .padding(.vertical)
                .background(BackgroundGradient())
                .padding([.horizontal,.bottom])
        }
    }
    
    private var image: some View {
        Group{
            if recipe.imageString == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(height: 250)
                    .background(BackgroundGradient())
            } else{
                Image(uiImage: UIImage(data: recipe.imageString!)!).resizable().scaledToFit()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
        .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
        .padding()
    }
    
    private var imageSection: some View{
        NavigationLink(destination: ImagePickerView(imageData: self.$recipe.imageString), tag: 1, selection: self.$recipeStore.rDSelection) {
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
    }
    
    private var categorySection: some View{
        NavigationLink(destination: CategoryPicker(recipe: self.$recipe), tag: 2, selection: self.$recipeStore.rDSelection) {
            HStack {
                Text("Kategorie:")
                Spacer()
                Text(recipe.category.name).secondary()
                Image("chevron.right")
            }
            .neomorphic()
        }.buttonStyle(PlainButtonStyle())
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
    
    private var startButton: some View{
        NavigationLink(destination: ScheduleForm(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature), tag: 3, selection: self.$recipeStore.rDSelection) {
            HStack {
                Text("Zeitplan erstellen")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .neomorphic()
        }.buttonStyle(PlainButtonStyle())
    }
    
    private var stepSections: some View {
        VStack {
            ForEach(recipe.steps){ step in
                if self.recipe.steps.contains(where: {$0.id == step.id}) {
                    NavigationLink(destination: StepDetail(recipe: self.$recipe, step: self.$recipe.steps[self.recipe.steps.firstIndex(where: { $0.id == step.id}) ?? 0], deleteEnabled: true).environmentObject(self.recipeStore)) {
                        StepRow(step: step, recipe: self.recipe, inLink: true, roomTemp: self.recipeStore.roomThemperature)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            NavigationLink(destination: AddStepView(recipe: self.$recipe, roomTemp: self.recipeStore.roomThemperature).environmentObject(self.recipeStore), tag: 4, selection: self.$recipeStore.rDSelection) {
                HStack {
                    Text("Schritt hinzufügen")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .neomorphic()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                self.nameSection
                self.imageSection
                if self.isDetail{
                    self.infoStrip
                    self.startButton
                }
                self.categorySection
                Text("Arbeitsschritte")
                    .secondary()
                    .padding(.leading)
                    .padding(.leading)
                self.stepSections
                //self.deleteSection
            }
            .frame(maxWidth: .infinity)
        }
        
        .navigationBarTitle(self.title)
        .navigationBarItems(
            trailing: self.trailingButton
        )
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
    }
    
    func fav(){
        self.recipe.isFavourite.toggle()
    }
}




struct RezeptDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RezeptDetail(recipe: .constant(Recipe.example), isDetail: true)
                .environmentObject(RecipeStore.example)
                .environment(\.colorScheme, .light)
        }
    }
}


