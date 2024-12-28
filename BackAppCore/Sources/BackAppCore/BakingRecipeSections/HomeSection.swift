// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import BakingRecipeStrings

public enum HomeSection: Int, CaseIterable {
    case favourites
    case recipes
    
    public func headerTitle(favouritesEmpty: Bool) -> String? {
        switch self {
        case .favourites: return favouritesEmpty ? nil : Strings.favorites
        case .recipes: return nil
        }
    }
}
