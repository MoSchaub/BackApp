//
//  CardView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    static let darkFillColor = Color.black
    
    static let lightFillColor =  Color.white
    
    static let lightShadow = Color.gray.opacity(0.05)
    static let darkShadow = Color.white.opacity(0.05)
    
    
    static func fillColor(colorScheme: ColorScheme) -> Color{
        if colorScheme == .dark{
            return darkFillColor
        } else {
            return lightFillColor
        }
    }
    
    static func shadowColor(colorScheme: ColorScheme) -> Color{
        if colorScheme == .dark{
            return darkShadow
        } else {
            return lightShadow
        }
    }
    
}

struct Card: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject private var rezeptStore: RecipeStore
    
    var recipe: Recipe
    var width: CGFloat = 350
    
    var image: some View {
        Group{
            if recipe.image == nil{
                LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.primary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask(Image("bread").resizable().scaledToFill())
                    .background(BackgroundGradient())
                    .frame(width: CGFloat(width / 1.75), height: CGFloat(width / 1.75))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
                    .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)

            } else{
                Image(uiImage: recipe.image!).resizable().scaledToFill()
                    .frame(width: CGFloat(width / 1.75), height: CGFloat(width / 1.75))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                image
//                Image(uiImage: recipe.image ?? UIImage(named: "bread")!)
//                    .resizable()
//                    .scaledToFill()
//                    .background(BackgroundGradient())
//                    .frame(width: CGFloat(width / 1.75), height: CGFloat(width / 1.75))
//                    .clipShape(RoundedRectangle(cornerRadius: 13))
//                    .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 4, y: 4)
                VStack{
                    HStack {
                        Text(recipe.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text(recipe.formattedTotalTime)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.trailing)
                        Spacer()
                    }
                    HStack {
                        Text(recipe.formattedStartBisEnde)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(Color.secondary)
                        Spacer()
                    }
                    
                    Spacer()
                }.padding(.top)
                    .frame(height: CGFloat(width / 1.75))
                
                Spacer()
            } .frame(width: width, height: CGFloat(width / 1.75))
            .background(BackgroundGradient())
        }
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
        Card(recipe: Recipe.example, width: 300)
            .padding(.horizontal)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .background(Color.fillColor(colorScheme: .light).edgesIgnoringSafeArea(.all))
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
