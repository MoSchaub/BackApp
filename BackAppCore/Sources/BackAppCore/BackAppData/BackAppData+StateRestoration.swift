// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BakingRecipeFoundation

/// Encodes the recipe a scene is showing into an `NSUserActivity`, so iOS can hand it
/// back through `UISceneSession.stateRestorationActivity` after it terminated the app
/// in the background, and the user lands on the same recipe again.
public enum RecipeStateRestoration {

    /// activity type of the activity describing a shown recipe
    /// - Note: Listed under `NSUserActivityTypes` in the app's Info.plist.
    public static let activityType = "com.moritzschaub.Back-App-iOS.viewRecipe"

    /// key of the recipe id in the activity's `userInfo`
    static let recipeIdKey = "recipeId"

    /// activity describing that the recipe with `recipeId` is shown
    public static func activity(for recipeId: Int64) -> NSUserActivity {
        let activity = NSUserActivity(activityType: activityType)
        activity.addUserInfoEntries(from: [recipeIdKey: recipeId])
        return activity
    }

    /// id of the recipe stored in `activity`, or nil if it does not describe a shown recipe
    public static func recipeId(from activity: NSUserActivity?) -> Int64? {
        guard let activity, activity.activityType == activityType else {
            return nil
        }
        // NSNumber bridging also accepts the value after a round-trip through the system
        return (activity.userInfo?[recipeIdKey] as? NSNumber)?.int64Value
    }
}

public extension BackAppData {

    /// the recipe described by a state restoration `activity`,
    /// or nil if there is none or it was deleted in the meantime
    func recipeToRestore(from activity: NSUserActivity?) -> Recipe? {
        guard let recipeId = RecipeStateRestoration.recipeId(from: activity) else {
            return nil
        }
        return record(with: recipeId, of: Recipe.self)
    }
}
