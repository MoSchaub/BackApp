// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  BakingRecipeItemsTests.swift
//
//
//  Created by Moritz Schaub on 16.10.21.
//

import Foundation
import Testing
@testable import BackAppCore
import BakingRecipeFoundation

@Suite("Baking recipe items")
struct BakingRecipeItemsTests {

    @Test("DetailItem keeps its id and text and defaults the detail label to empty")
    func detailItem() {
        let id = UUID().hashValue
        let item = DetailItem(id: id, name: "name", detailLabel: nil)
        #expect(item.id == id)
        #expect(item.text == "name")
        #expect(item.detailLabel == "")

        #expect(DetailItem(name: "name", detailLabel: "250 g").detailLabel == "250 g")
    }

    @Test("Items are equal and hash alike exactly when their ids match")
    func identity() {
        let a = TextItem(id: 1, text: "a")
        let sameId = DetailItem(id: 1, name: "different text")
        let otherId = TextItem(id: 2, text: "a")

        #expect(a == sameId)
        #expect(a != otherId)
        #expect(Set<Item>([a, sameId, otherId]).count == 2)
    }

    @Test("Items without an explicit id get distinct random ids")
    func randomIds() {
        let ids = Set((0..<100).map { _ in Item().id })
        #expect(ids.count == 100)
    }

    @Test("Text based items keep their text")
    func textItems() {
        #expect(AmountItem(text: "2 pieces").text == "2 pieces")
        #expect(TextFieldItem(id: 3, text: "Brot").id == 3)
        #expect(InfoItem(text: "info").text == "info")
        #expect(IngredientItem(name: "Mehl", detailLabel: "500 g").detailLabel == "500 g")
        #expect(SubstepItem(name: "Sauerteig").text == "Sauerteig")
    }

    @Test("StepItem takes the step's id")
    func stepItem() {
        var step = Step(name: "Kneten", recipeId: 1, number: 0)
        step.id = 42
        let item = StepItem(step: step)
        #expect(item.id == 42)
        #expect(item.step == step)
        #expect(ScheduleItem(step: step).id == 42)
    }

    @Test("Value items store their payload")
    func valueItems() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(DateItem(date: date).date == date)
        #expect(ImageItem(imageData: Data([1, 2, 3])).imageData == Data([1, 2, 3]))
        #expect(ImageItem(imageData: nil).imageData == nil)
        #expect(TimesItem(decimal: 2.5).decimal == 2.5)
        #expect(TimesItem(decimal: nil).decimal == nil)
    }

    @Test("Decodable items read their fields from JSON")
    func decoding() throws {
        let infoStrip = try JSONDecoder().decode(
            InfoStripItem.self,
            from: Data(#"{"weighIn":"500.0 g","formattedDuration":"2 hours","doughYield":"0.65"}"#.utf8)
        )
        #expect(infoStrip.weighIn == "500.0 g")
        #expect(infoStrip.formattedDuration == "2 hours")
        #expect(infoStrip.doughYield == "0.65")

        #expect(try JSONDecoder().decode(TimesItem.self, from: Data(#"{"decimal":3}"#.utf8)).decimal == 3)
        #expect(try JSONDecoder().decode(TimesItem.self, from: Data("{}".utf8)).decimal == nil)

        let step = Step(name: "Gare", recipeId: 1, number: 0)
        let json = try JSONEncoder().encode(["step": step])
        #expect(try JSONDecoder().decode(StepItem.self, from: json).step == step)
    }

    @Test("Decoding an incomplete InfoStripItem fails")
    func decodingMissingField() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(InfoStripItem.self, from: Data(#"{"weighIn":"500.0 g"}"#.utf8))
        }
    }

    @Test("Recipe item factories reflect the recipe")
    func recipeItems() {
        var recipe = Recipe(name: "Brot", number: 0)
        recipe.info = "Ein Brot"
        recipe.imageData = Data([0xFF])
        recipe.times = 3

        #expect(recipe.nameItem().text == "Brot")
        #expect(recipe.infoItem.text == "Ein Brot")
        #expect(recipe.imageItem.imageData == Data([0xFF]))
        #expect(recipe.amountItem().text == recipe.timesText)
    }
}

@Suite("Collection safe subscript")
struct SafeSubscriptTests {

    @Test("Returns the element for valid indices and nil otherwise", arguments: [
        (-1, String?.none), (0, "a"), (2, "c"), (3, nil),
    ])
    func safeSubscript(index: Int, expected: String?) {
        #expect(["a", "b", "c"][safe: index] == expected)
    }

    @Test("Empty collections never return an element")
    func emptyCollection() {
        #expect([Int]()[safe: 0] == nil)
    }
}
