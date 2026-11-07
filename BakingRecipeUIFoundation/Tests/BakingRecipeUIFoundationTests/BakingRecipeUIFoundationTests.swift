// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

#if canImport(UIKit)
import Testing
import UIKit
@testable import BakingRecipeUIFoundation

@Suite("Theme colors")
struct ThemeColorTests {

    @Test("Every theme color resolves from the package's asset catalog")
    func colorsExist() {
        let theme = Theme()
        #expect(theme.backgroundColor != nil)
        #expect(theme.cellBackgroundColor != nil)
        #expect(theme.selectedCellBackground != nil)
        #expect(theme.primaryTextColor != nil)
        #expect(theme.primaryCellTextColor != nil)
        #expect(theme.secondaryTextColor != nil)
        #expect(theme.secondaryCellTextColor != nil)
        #expect(theme.baTintColor != nil)
        #expect(theme.baTintBackgroundColor != nil)
        #expect(theme.secondaryCellBackgroundColor != nil)
    }
}

@MainActor
@Suite("UIView helpers")
struct UIViewHelperTests {

    @Test("allSubviews walks the whole hierarchy depth first")
    func allSubviews() {
        let root = UIView()
        let child = UIView()
        let grandchild = UIView()
        let sibling = UIView()
        root.addSubview(child)
        child.addSubview(grandchild)
        root.addSubview(sibling)

        #expect(root.allSubviews == [child, grandchild, sibling])
        #expect(grandchild.allSubviews.isEmpty)
    }

    @Test("fillSuperview pins all edges with the padding")
    func fillSuperview() throws {
        let container = UIView()
        let view = UIView()
        container.addSubview(view)

        let constraints = view.fillSuperview(padding: UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4))

        #expect(view.translatesAutoresizingMaskIntoConstraints == false)
        #expect(try #require(constraints.top).constant == 1)
        #expect(try #require(constraints.leading).constant == 2)
        // bottom and trailing are inset, so their constants are negative
        #expect(try #require(constraints.bottom).constant == -3)
        #expect(try #require(constraints.trailing).constant == -4)
        #expect([constraints.top, constraints.leading, constraints.bottom, constraints.trailing].allSatisfy { $0?.isActive == true })
    }

    @Test("fillSuperview without a superview adds no constraints")
    func fillSuperviewWithoutSuperview() {
        let constraints = UIView().fillSuperview()
        #expect(constraints.top == nil)
        #expect(constraints.bottom == nil)
    }

    @Test("Size helpers create active constraints")
    func sizeConstraints() throws {
        let view = UIView()
        #expect(try #require(view.constrainHeight(44).height).constant == 44)
        #expect(try #require(view.constrainWidth(120).width).constant == 120)
        #expect(view.constraints.allSatisfy(\.isActive))
    }

    @Test("Anchors with a zero size constant are skipped")
    func zeroSizeAnchors() {
        let view = UIView()
        let constraints = view.anchor(.height(0), .width(10))
        #expect(constraints.height == nil)
        #expect(constraints.width?.constant == 10)
    }
}
#endif
