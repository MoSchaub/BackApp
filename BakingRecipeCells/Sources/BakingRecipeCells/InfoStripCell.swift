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
        @Environment(\.colorScheme) var colorScheme
        
        var minuteCount: Int
        var ingredientCount: Int
        var stepCount: Int
        
        var body: some View {
            HStack{
                Spacer()
                VStack {
                    Text(String(minuteCount))
                    Text(Strings.minutes).secondary()
                }
                Spacer()
                VStack{
                    Text(String(ingredientCount))
                    Text(Strings.ingredients).secondary()
                }
                Spacer()
                VStack{
                    Text(String(stepCount))
                    Text(Strings.steps).secondary()
                }
                Spacer()
            }
            .foregroundColor(Color(UIColor.primaryCellTextColor!))
            .padding()
            .background(Color(UIColor.cellBackgroundColor!))
        }
    }
    
    public func setUpCell(for item: InfoStripItem) {
        selectionStyle = .none
        let hostingController = UIHostingController(rootView: InfoStrip(minuteCount: item.minuteCount, ingredientCount: item.ingredientCount, stepCount: item.stepCount))

        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }

}
