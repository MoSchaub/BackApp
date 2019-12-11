//
//  BrotValueDetail.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct BrotValueDetail: View {
    
    @EnvironmentObject private var rezeptStore: RezeptStore
    
    var rezept: Rezept
    
    var rezeptIndex: Int {
        rezeptStore.rezepte.firstIndex(where: {$0.id == rezept.id }) ?? 0
    }
    
    var brotValue: BrotValue
    
    var brotValueIndex: Int {
        rezeptStore.rezepte[rezeptIndex].brotValues.firstIndex(where: {$0.id == brotValue.id }) ?? 0
    }
    
    
    
    var body: some View {
        VStack {
            Text(brotValue.name)
            MOTimePicker(time: $rezeptStore.rezepte[rezeptIndex].brotValues[brotValueIndex].time)
            //Text("\(Int(time/60)) Minuten")
        }
    }
}

struct BrotValueDetail_Previews: PreviewProvider {
    static var previews: some View {
        BrotValueDetail(rezept: RezeptStore().rezepte[0], brotValue: RezeptStore().rezepte[0].brotValues[0])
            .environmentObject(RezeptStore())
    }
}
