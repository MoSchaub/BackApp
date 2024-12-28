// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
struct ImpressumView: View {
    
    private var text : String
    
    var body: some View {
        ScrollView {
            #if os(macOS)
            Text(text).lineLimit(nil)
                .padding(.leading)
            
            #else
            Text(text).lineLimit(nil)
                .padding(.leading)
                .navigationBarTitle("Impressum", displayMode: .automatic)
            #endif
        }
    }
    
    init() {
         self.text = "failed to load file"
        if let url = Bundle.main.url(forResource: "BackAppImpressum.txt", withExtension: nil){
            if let string = try? String(contentsOf: url){
                self.text = string
            }
        }
    }
    
}

struct ImpressumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImpressumView()
        }
    }
}
