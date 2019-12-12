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
            
            Section{
                VStack {
                    HStack {
                        Text("Name:")
                        TextField("name", text: $rezeptStore.rezepte[rezeptIndex].name)
                    }
                    Image(uiImage: rezeptStore.rezepte[rezeptIndex].image)
                        .scaledToFill()
                }
            }
            
            Section{
                ForEach(rezeptStore.rezepte[rezeptIndex].brotValues) { brotValue in
                    NavigationLink(destination: BrotValueDetail(rezept: self.rezeptStore.rezepte[self.rezeptIndex], brotValue: brotValue).environmentObject(self.rezeptStore)) {
                        BrotValueRow(brotValue: brotValue)
                    }
                }
            }
            
            Section{
                VStack {
                    if rezeptStore.rezepte[rezeptIndex].inverted{
                        Text("Enddatum")
                    }else {
                        Text("Startdatum")
                    }
                    HStack {
                        MODatePicker(date: $rezeptStore.rezepte[rezeptIndex].date )
                        Spacer()
                    }
                    Picker(selection: $rezeptStore.rezepte[rezeptIndex].inverted, label: Text("Start-/Enddatum")) {
                        Text("Enddatum").tag(true)
                        Text("Startdatum").tag(false)
                    }
                    if rezeptStore.rezepte[rezeptIndex].inverted{
                        Text("Enddatum: \(dateFormatter.string(from: rezeptStore.rezepte[rezeptIndex].endDate()))")
                    }else {
                        Text("Startdatum: \(dateFormatter.string(from: rezeptStore.rezepte[rezeptIndex].startDate()))")
                    }
                }
            }
            
            Section{
                Text(rezeptStore.rezepte[rezeptIndex].text())
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("\(rezeptStore.rezepte[rezeptIndex].name)"))
    }
}

struct RezeptDetail_Previews: PreviewProvider {
    static var previews: some View {
        RezeptDetail(rezept: RezeptData[0]).environmentObject(RezeptStore())
    }
}
