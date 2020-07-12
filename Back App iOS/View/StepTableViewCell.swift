//
//  StepTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

struct CellView<C: View>: View{
    var content: C
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .tertiarySystemFill : .clear )
            content
        }
    }
}

extension View {
    func cellView() -> some View {
        CellView(content: self)
    }
}

class StepTableViewCell: UITableViewCell {
    
    var view: UIView!
    
    func setUpCell(for step: Step, recipe: Recipe, roomTemp: Int) {
        let rootView = StepRow(step: step, recipe: recipe, roomTemp: roomTemp).cellView()
        view = UIHostingController(rootView: rootView).view
        view.frame = .zero
        contentView.addSubview(view)
        setViewConstraints()
        accessoryType = .disclosureIndicator
    }
    
    private func setViewConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
    }

}
