// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  BakingRecipeItemsTests.swift
//  
//
//  Created by Moritz Schaub on 16.10.21.
//

import XCTest
@testable import BackAppCore

final class BakingRecipeItemsTests: XCTestCase {

    func test_DetailItem() {
        let id = UUID().hashValue
        let name = "name"
        let item = DetailItem(id: id, name: name, detailLabel: nil)
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, name)
        XCTAssertEqual(item.detailLabel, "")
    }
}
