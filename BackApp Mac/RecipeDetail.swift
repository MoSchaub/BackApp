//
//  RecipeDetail.swift
//  BackApp Mac
//
//  Created by Moritz Schaub on 17.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RecipeDetail: View {
    
    @EnvironmentObject private var recipeStore: RecipeStore
    
    @Binding var recipe: Recipe
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image( "bread").resizable().scaledToFit())
                    .frame(minWidth: 50, idealWidth: 75, maxWidth: 100, minHeight: 50, idealHeight: 75, maxHeight: 100)
                    .background(BackgroundGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                    .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
                    
            } else{
                Image(nsImage: recipe.image!).resizable().scaledToFit().frame(minWidth: 50, idealWidth: 75, maxWidth: 100, minHeight: 50, idealHeight: 75, maxHeight: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    image
                    Text(recipe.name).font(.title)
                    Spacer()
                }.padding(.horizontal)
                .frame(maxWidth: .infinity ,maxHeight: 100)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            //steps
        }
        .frame(maxHeight: .infinity)
    }
}

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetail(recipe: .constant(Recipe.example)).environmentObject(RecipeStore.example)
    }
}
