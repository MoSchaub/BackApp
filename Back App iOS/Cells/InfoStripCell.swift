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

    private struct InfoStripStat {
        let string1, string2: String
    }
    
    public func setUpCell(for item: InfoStripItem) {

        let infoStripStats =  [InfoStripStat(string1: item.formattedDuration, string2: Strings.duration), InfoStripStat(string1: item.weighIn, string2: Strings.weighIn), InfoStripStat(string1: item.doughYield, string2: Strings.doughYield)]

        let vstacks: [UIStackView] = infoStripStats.map {
            let label1 = UILabel(frame: .zero)
            label1.text = $0.string1
            label1.textColor = .primaryCellTextColor

            let label2 = UILabel(frame: .zero)
            label2.attributedText = NSAttributedString(string: $0.string2, attributes: [.font : UIFont.preferredFont(forTextStyle: .subheadline)])
            label2.textColor = .secondaryCellTextColor

            let vstack = UIStackView(arrangedSubviews: [label1, label2])
            vstack.axis = .vertical
            vstack.alignment = .center
            return vstack
        }

        let hstack = UIStackView(arrangedSubviews: vstacks)
        hstack.axis = .horizontal
        hstack.alignment = .center
        hstack.distribution = .fillEqually

        contentView.addSubview(hstack)
        hstack.fillSuperview(padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
}

