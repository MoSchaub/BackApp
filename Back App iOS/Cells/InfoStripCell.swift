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

    public init(infoStripItem: InfoStripItem, reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setUpCell(for: infoStripItem)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setUpCell(for item: InfoStripItem) {
        selectionStyle = .none

        let rootView = InfoStrip(weighIn: item.weighIn, formattedDuration: item.formattedDuration, doughYield: item.doughYield)
        let hostingController = UIHostingController(rootView: rootView)
        
        // set clear so the view takes the cells background color
        hostingController.view.backgroundColor = .clear

        contentView.addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }
    
}

