//
//  BrotValueRow.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 01.10.19.
//  Copyright © 2019 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct BrotValueRow: View {
    
    var brotValue: BrotValue
    
    var body: some View {
        VStack {
            HStack {
                Text("\(brotValue.name)")
                    .font(.headline)
                Spacer()
            }
            if brotValue.time/60 == 1{
                HStack {
                    Text("\(Int(brotValue.time/60)) Minute")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }else {
                HStack {
                    Text("\(Int(brotValue.time/60)) Minuten")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

