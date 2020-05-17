//
//  CardView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct Card: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject private var rezeptStore: RecipeStore
    
    var recipe: Recipe
    var width: CGFloat = 300
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image("bread").resizable().scaledToFill())
                    .background(BackgroundGradient())
                    .frame(width: CGFloat(width / 3.75), height: CGFloat(width / 3.75))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
            } else{
                #if os(iOS)
                Image(uiImage: recipe.image!).resizable().scaledToFill()
                    .frame(width: CGFloat(width / 3.75), height: CGFloat(width / 3.75))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                #elseif os(macOS)
                Image(nsImage: recipe.image!).resizable().scaledToFill()
                    .frame(width: CGFloat(width / 3.75), height: CGFloat(width / 3.75))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                #endif
                
            }
        }
    }
    
    var body: some View {
        HStack {
            image
            VStack{
                HStack {
                    Text(recipe.name)
                        .font(.callout)
                        .fontWeight(.bold)
                    Spacer()
                }
                HStack {
                    Text(recipe.formattedTotalTime)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                    Spacer()
                }
                HStack {
                    Text(recipe.formattedStartBisEnde)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
                Spacer()
            }.frame(height: width / 3.75)
        }.frame(width: width)
        
    }
    
    func color() -> Color{
        if colorScheme == .light{

            return Color.white
        } else {
            return Color.black
        }
        
    }
}


struct CardView_Previews: PreviewProvider {
    
    static var previews: some View {
        Card(recipe: Recipe.example, width: 350 )
            .environment(\.colorScheme, .light)
            .environmentObject(RecipeStore())
    }
}

extension CGFloat {
    var absoluteValue: CGFloat{
        if self < 0{
            return self * -1
        } else {
            return self
        }
    }
}
