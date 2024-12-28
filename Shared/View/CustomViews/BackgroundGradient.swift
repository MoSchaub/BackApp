// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

struct BackgroundGradient: View{
    var body: some View {
        GeometryReader{ geo in
            RoundedRectangle(cornerRadius: 13)
                .fill(LinearGradient(gradient: Gradient(colors: [Color("Color1"),Color("Color2")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color("Color1"), radius: 10, x: 5, y: 5)
                .shadow(color: Color("Color2"), radius: 10, x: -5, y: -5)
        }
        
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("Color1").edgesIgnoringSafeArea(.all)
            BackgroundGradient()
                .frame(width: 350, height: 100)
               
        } .environment(\.colorScheme, .dark)
    }
}
