// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import XCTest
@testable import BakingRecipeUIFoundation

final class BakingRecipeUIFoundationTests: XCTestCase {
    func testThemeManagerRegistersThemeColors() {
        _ = ThemeManager.default

        XCTAssertNotNil(UIColor.baTintColor)
        XCTAssertNotNil(UIColor.cellBackgroundColor)
        XCTAssertNotNil(UIColor.primaryCellTextColor)
    }

    static var allTests = [
        ("testThemeManagerRegistersThemeColors", testThemeManagerRegistersThemeColors),
    ]
}
