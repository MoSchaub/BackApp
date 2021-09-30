//
//  HomeSection.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

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
