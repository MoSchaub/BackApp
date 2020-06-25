//
//  ImpressumView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 28.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

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
