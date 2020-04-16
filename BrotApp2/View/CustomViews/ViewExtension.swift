//
//  ViewExtension.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 14.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

extension View{
    func neomorphic() -> some View{
        HStack{
            self
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .background(BackgroundGradient())
        .padding(.vertical)
    }
}

struct ViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello world").neomorphic()
    }
}
