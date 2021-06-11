//
//  File.swift
//
//
//  Created by Moritz Schaub on 05.10.20.
//

import SwiftUI
import BakingRecipeUIFoundation
import BakingRecipeStrings
import BackAppCore

public class InfoStripCell: CustomCell {
    
    struct InfoStrip: View {
        
        var weighIn: String
        var formattedDuration: String
        var doughYield: String
        
        var body: some View {
            HStack{
                VStack {
                    Text(formattedDuration)
                    Text(Strings.duration).secondary()
                }
                Spacer()
                VStack{
                    Text(weighIn)
                    Text(Strings.weighIn).secondary()
                }
                Spacer()
                VStack {
                    Text(doughYield)
                    Text(Strings.doughYield).secondary()
                }
            }
            .foregroundColor(Color(UIColor.primaryCellTextColor!))
            .padding()
            .background(Color(UIColor.cellBackgroundColor!))
        }
    }
    
    public func setUpCell(for item: InfoStripItem) {
        selectionStyle = .none
        let hostingController = UIHostingController(rootView: InfoStrip(weighIn: item.weighIn, formattedDuration: item.formattedDuration, doughYield: item.doughYield))
        
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }
    
}

