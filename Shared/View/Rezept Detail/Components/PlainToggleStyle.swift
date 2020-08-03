//
//  PlainToggleStyle.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 03.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct PlainToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
        }
    }
}

struct PlainToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        Toggle(isOn: .constant(true)) {
            Image(systemName: "circle")
        }.toggleStyle(
            PlainToggleStyle()
        )
    }
}
