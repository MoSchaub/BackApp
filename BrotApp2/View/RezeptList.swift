//
//  ContentView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 29.09.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI
import Parse

struct RezeptList: View {
    
    @EnvironmentObject private var rezeptStore: RezeptStore
    var body: some View {
        
        NavigationView {
            List{
                ForEach(rezeptStore.rezepte){ rezept in
                    NavigationLink(destination: RezeptDetail(rezept: rezept)
                        .environmentObject(self.rezeptStore)) {
                            RezeptRow(rezept: rezept)
                        
                    }
                }
            }
            .navigationBarTitle(Text("BrotApp"))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RezeptList()
        .environmentObject(RezeptStore())
    }
}
