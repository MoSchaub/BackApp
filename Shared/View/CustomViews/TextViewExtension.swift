//
//  TextViewExtension.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 11.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

extension Text{
    func secondary() -> Text {
        self
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct TextViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Text(".secondary").secondary()
    }
}
