//
//  RezeptDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptDetail: View {
    
    @EnvironmentObject private var rezeptStore: RezeptStore
    
    var rezept: Rezept
    
    var rezeptIndex: Int {
        rezeptStore.rezepte.firstIndex(where: {$0.id == rezept.id }) ?? 0
    }
    
    var body: some View {
        List{
            ForEach(rezeptStore.rezepte[rezeptIndex].brotValues) { brotValue in
                NavigationLink(destination: BrotValueDetail(rezept: self.rezeptStore.rezepte[self.rezeptIndex], brotValue: brotValue).environmentObject(self.rezeptStore)) {
                    BrotValueRow(brotValue: brotValue)
                }
            }
        }
        .navigationBarTitle(Text("\(rezeptStore.rezepte[rezeptIndex].name)"))
    }
}

struct RezeptDetail_Previews: PreviewProvider {
    static var previews: some View {
        RezeptDetail(rezept: RezeptData[0]).environmentObject(RezeptStore())
    }
}
