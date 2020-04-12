//
//  BackgroundGradient.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 11.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct BackgroundGradient: View{
    var body: some View {
        RoundedRectangle(cornerRadius: 13)
        .fill(LinearGradient(gradient: Gradient(colors: [Color.init(.secondarySystemBackground),Color.init(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .frame(width: UIScreen.main.bounds.width - 30)
        .shadow(color: Color.init(.secondarySystemBackground), radius: 10, x: 5, y: 5)
        .shadow(color: Color.init(.systemBackground), radius: 10, x: -5, y: -5)
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradient()
    }
}
