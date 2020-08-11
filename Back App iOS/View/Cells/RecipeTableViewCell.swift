//
//  RecipeTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 28.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import LBTATools

extension Color {
    
    static func cellBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(UIColor.tertiarySystemFill) : Color.white
    }
}

class RecipeTableViewCell: UITableViewCell {
    
    class RecipeCellData: ObservableObject {
        var name: String
        var minuteLabel: String
        var imageData: Data?
        
        init(name: String, minuteLabel: String, imageData: Data? = nil) {
            self.name = name
            self.minuteLabel = minuteLabel
            self.imageData = imageData
        }
    }
    
    struct RecipeRowView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @ObservedObject var data: RecipeCellData
        
        var image: some View {
            Group {
                if data.imageData != nil {
                    Image(uiImage: UIImage(data: data.imageData!)!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(cornerRadius)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .imageScale(.large)
                        .scaledToFit()
                }
            }
        }
        
        var body: some View {
            HStack {
                image
                VStack(alignment: .leading) {
                    Text(data.name)
                        .font(.headline)
                    Text(data.minuteLabel).secondary()
                }
                Spacer()
            }
            .padding()
            .frame(maxHeight: height)
            .background(Color.cellBackgroundColor(for: colorScheme))
        }
        
        //constants
        let height: CGFloat = 65
        let cornerRadius: CGFloat = 10
        
    }
    
    func setUp(cellData: RecipeCellData) {
        let hostingController = UIHostingController(rootView: RecipeRowView(data: cellData))
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
    }

}


struct RecipeTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        RecipeTableViewCell.RecipeRowView(data: .init(name: "Name", minuteLabel: "10 Minuten"))
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .environment(\.colorScheme, .dark)
            
    }
}
