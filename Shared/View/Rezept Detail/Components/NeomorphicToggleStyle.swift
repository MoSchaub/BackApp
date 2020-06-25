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
                    .fill(LinearGradient(Color("Color2"), Color("Color1")))
                    .frame(height: 40)
                    .overlay(shape.stroke(LinearGradient(Color("Color1"),Color("Color2")), lineWidth: 4))
                    .shadow(color: Color("Color1").opacity(0.4), radius: 10, x: 5, y: 5)
            } else {
                shape
                    .fill(LinearGradient(Color("Color1"),Color("Color2")))
                    .frame(height: 40)
                    .shadow(color: Color("Color1").opacity(0.4), radius: 10, x: -10, y: -10)
                    .shadow(color: Color("Color2"), radius: 10, x: 10, y: 10)
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
            Color("Color2").edgesIgnoringSafeArea(.all)
            VStack {
                Toggle(isOn: .constant(true)) {
                    #if os(iOS)
                    Image(systemName: "pencil")
                    #elseif os(macOS)
                    Image(nsImage: NSImage(named: "pencil")!)
                    #endif
                    
                }.toggleStyle(NeomorphicToggleStyle())
                Toggle(isOn: .constant(false)) {
                    #if os(iOS)
                    Image(systemName: "pencil")
                    #elseif os(macOS)
                    Image(nsImage: NSImage(named: "pencil")!)
                    #endif
                }.toggleStyle(NeomorphicToggleStyle())
            }
        }.environment(\.colorScheme, .light)
    }
}
