//
//  InfoStripTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings
import BakingRecipeCore

class InfoStripTableViewCell: UITableViewCell {
    
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
            .padding()
            .background(Color.cellBackgroundColor())
        }
    }
    
    func setUpCell(for item: InfoStripItem) {
        selectionStyle = .none
        let hostingController = UIHostingController(rootView: InfoStrip(minuteCount: item.minuteCount, ingredientCount: item.ingredientCount, stepCount: item.stepCount))

        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }

}
