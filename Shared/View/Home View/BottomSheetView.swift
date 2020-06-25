//
//  BottomSheetView.swift
//  BrotApp2
//
//  Created by Moritz Schaub on 04.04.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 30
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.15
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    @GestureState private var translation: CGFloat = 0
    
    @State private var previousTranslation = CGFloat.zero

    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
        ).onTapGesture {
            self.isOpen.toggle()
        }
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, minHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator
                    .padding(.vertical, 5)
                self.content
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        if self.isOpen{
                            if self.maxHeight + state + value.translation.height > self.minHeight{
                                state = value.translation.height
                            }
                        }
                    }.onEnded { value in
                        let snapDistance = self.maxHeight * Constants.snapRatio
                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }
                        self.isOpen = value.translation.height < 0
                    }
                )
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.systemBackground))
            .cornerRadius(Constants.radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    if self.isOpen{
                        if self.maxHeight + state + value.translation.height > self.minHeight{
                            state = value.translation.height
                        }
                    }
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

extension View{
    func bottomSheet<Content: View>(open: Binding<Bool>, @ViewBuilder  content: () -> Content) -> some View{
        ZStack {
            self
            BottomSheetView(isOpen: open, maxHeight: UIScreen.main.bounds.height - 50, minHeight: 75, content: content)
                .resignKeyboardOnDragGesture()
        }
    }
}


struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello world")
            .bottomSheet(open: .constant(false)) {
                Rectangle().fill(Color.red)
        }
    }
}
