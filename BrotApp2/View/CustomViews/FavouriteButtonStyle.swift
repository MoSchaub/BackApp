//
//  FavouriteButtonStyle.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 05.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct FavouriteButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        .padding()
        .background(Color.secondary)
        .clipShape(Circle())
    }
}

struct FavouriteButton: View {
    var body: some View {
        Button("text"){
            //do something
        }.buttonStyle(FavouriteButtonStyle())
    }
}

struct FavouriteButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteButton()
    }
}
