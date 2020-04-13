//
//  NeomorphicToggleStyle.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 13.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct NeomorphicBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color(.systemBackground), Color(.secondarySystemBackground)))
                    .frame(height: 40)
                    .overlay(shape.stroke(LinearGradient(Color.init(.secondarySystemBackground),Color.init(.systemBackground)), lineWidth: 4))
                    .shadow(color: Color.init(.secondarySystemBackground).opacity(0.4), radius: 10, x: 5, y: 5)
            } else {
                shape
                    .fill(LinearGradient(Color.init(.secondarySystemBackground),Color.init(.systemBackground)))
                    .frame(height: 40)
                    .shadow(color: Color.init(.secondarySystemBackground).opacity(0.4), radius: 10, x: -10, y: -10)
                    .shadow(color: Color.init(.systemBackground), radius: 10, x: 10, y: 10)
            }
        }
    }
}

struct NeomorphicToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        }
        .background(
            NeomorphicBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct NeoToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            VStack {
                Toggle(isOn: .constant(true)) {
                    Image(systemName: "pencil")
                }.toggleStyle(NeomorphicToggleStyle())
                Toggle(isOn: .constant(false)) {
                    Image(systemName: "pencil")
                }.toggleStyle(NeomorphicToggleStyle())
            }
        }.environment(\.colorScheme, .light)
    }
}
