//
//  RezeptRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct RezeptRow: View {
    
    var rezept: Rezept
    
    var body: some View {
        VStack{
            HStack {
                Text(rezept.name).font(.headline).padding(.leading)
                Spacer()
            }
            HStack {
                Text("Beginn am \(rezept.date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                Spacer()
            }
            HStack {
                Text("Dauer: \(rezept.totalTime()) Minuten")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                Spacer()
            }
            HStack{
                Text("Ende am \(dateFormatter.string(from: rezept.getEndDate()!))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                Spacer()
            }
            
        }
    }
}

struct RezeptRow_Previews: PreviewProvider {
    static var previews: some View {
        RezeptRow(rezept: RezeptData[0])
    }
}
