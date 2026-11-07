// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation

/// Tests for reopening the last shown recipe after iOS terminated the app in the background.
/// Each test gets its own in-memory database, so this suite runs in parallel with the rest.
@Suite(.bug("https://github.com/MoSchaub/BackApp/issues/29"))
struct StateRestorationTests {

    let appData = BackAppData.empty()

    // MARK: Encoding and decoding the activity

    @Test(arguments: [Int64(0), 1, 42, .max])
    func recipeIdRoundTripsThroughActivity(recipeId: Int64) {
        let activity = RecipeStateRestoration.activity(for: recipeId)

        #expect(activity.activityType == RecipeStateRestoration.activityType)
        #expect(RecipeStateRestoration.recipeId(from: activity) == recipeId)
    }

    @Test func recipeIdSurvivesArchivingOfUserInfo() throws {
        // iOS persists the activity's userInfo as a property list between launches
        let activity = RecipeStateRestoration.activity(for: 7)
        let userInfo = try #require(activity.userInfo)
        let data = try PropertyListSerialization.data(fromPropertyList: userInfo, format: .binary, options: 0)
        let restoredUserInfo = try #require(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [AnyHashable: Any])

        let restored = NSUserActivity(activityType: RecipeStateRestoration.activityType)
        restored.addUserInfoEntries(from: restoredUserInfo)

        #expect(RecipeStateRestoration.recipeId(from: restored) == 7)
    }

    @Test func noActivityRestoresNoRecipeId() {
        #expect(RecipeStateRestoration.recipeId(from: nil) == nil)
    }

    @Test func foreignActivityTypeIsIgnored() {
        let activity = NSUserActivity(activityType: "com.example.somethingElse")
        activity.addUserInfoEntries(from: [RecipeStateRestoration.recipeIdKey: Int64(3)])

        #expect(RecipeStateRestoration.recipeId(from: activity) == nil)
    }

    @Test(arguments: [
        [:],
        ["unrelatedKey": 3],
        [RecipeStateRestoration.recipeIdKey: "3"],
    ] as [[String: any Sendable]])
    func malformedUserInfoIsIgnored(userInfo: [String: any Sendable]) {
        let activity = NSUserActivity(activityType: RecipeStateRestoration.activityType)
        activity.addUserInfoEntries(from: userInfo)

        #expect(RecipeStateRestoration.recipeId(from: activity) == nil)
    }

    // MARK: Looking up the recipe

    @Test func existingRecipeIsRestored() throws {
        let recipeId = try #require(appData.addBlankRecipe().id)

        let restored = appData.recipeToRestore(from: RecipeStateRestoration.activity(for: recipeId))

        // compare ids, not records: GRDB truncates the creation date to milliseconds
        #expect(restored?.id == recipeId)
    }

    @Test func deletedRecipeIsNotRestored() throws {
        let recipe = try appData.addBlankRecipe()
        let recipeId = try #require(recipe.id)
        appData.delete(recipe)
        try #require(appData.record(with: recipeId, of: Recipe.self) == nil, "the recipe should be deleted")

        let restored = appData.recipeToRestore(from: RecipeStateRestoration.activity(for: recipeId))

        #expect(restored == nil, "a recipe deleted since the activity was saved must not be shown")
    }

    @Test func missingActivityRestoresNoRecipe() throws {
        _ = try appData.addBlankRecipe()

        #expect(appData.recipeToRestore(from: nil) == nil)
    }
}
