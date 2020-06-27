//
//  InfoStripTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

class InfoStripTableViewCell: UITableViewCell {
    
    var recipe: Recipe!
    
    var view: UIView!
    
    private var infoStrip: some View{
        HStack{
            Spacer()
            VStack {
                Text("\(recipe.totalTime)")
                Text("Min").secondary()
            }
            Spacer()
            VStack{
                Text("\(recipe.numberOfIngredients)")
                Text("Zutaten").secondary()
            }
            Spacer()
            VStack{
                Text("\(recipe.steps.count)")
                Text("Schritte").secondary()
            }
            Spacer()
        }
    }
    
    func setUpCell(for recipe: Recipe) {
        self.recipe = recipe
        view = UIHostingController(rootView: infoStrip).view
        view.frame = .zero
        contentView.addSubview(view)
        setViewConstraints()
    }
    
    func setViewConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }

}
