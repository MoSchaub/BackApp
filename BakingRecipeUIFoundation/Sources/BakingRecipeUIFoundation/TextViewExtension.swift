//
//  TextViewExtension.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 11.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

public extension Text{
    func secondary() -> Text {
        self
            .font(.subheadline)
            .foregroundColor(Color(UIColor.secondaryCellTextColor!))
    }
}

struct TextViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Text(".secondary").secondary()
    }
}
