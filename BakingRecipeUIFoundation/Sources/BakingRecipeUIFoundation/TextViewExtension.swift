// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

public extension Text{
    func secondary() -> Text {
        self
            .font(.subheadline)
            .foregroundColor(Color(UIColor.secondaryCellTextColor!))
    }
    
    func secondaryNotCell() -> Text {
        self
            .font(.subheadline)
            .foregroundColor(Color(UIColor.secondaryTextColor!))
    }
}

struct TextViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Text(".secondary").secondary()
    }
}
