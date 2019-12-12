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
        HStack {
            Image(uiImage: rezept.image)
                .frame(width: 50.0, height: 50.0)
                .scaledToFill()
            VStack{
                HStack {
                    Text(rezept.name).font(.headline).padding(.leading)
                    Spacer()
                }
                HStack {
                    Text("Beginn am \(dateFormatter.string(from: rezept.startDate()))")
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
                    Text("Ende am \(dateFormatter.string(from: rezept.endDate()))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    Spacer()
                }
                
            }
        }
    }
}

struct RezeptRow_Previews: PreviewProvider {
    static var previews: some View {
        RezeptRow(rezept: RezeptData[0])
    }
}
