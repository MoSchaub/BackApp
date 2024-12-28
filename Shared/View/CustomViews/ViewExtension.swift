// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

extension View{
    #if os(iOS)
    func neomorphic(enabled: Bool = true) -> some View{
        HStack{
            self
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .background(enabled ? AnyView(BackgroundGradient()) : AnyView(EmptyView()))
        .padding()
    }
    #elseif os(macOS)
    func neomorphic(enabled: Bool = true) -> some View{
        HStack{
            self
            Spacer()
        }
        .padding(.horizontal)
    }
    #endif
}

struct ViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello world").neomorphic()
    }
}
