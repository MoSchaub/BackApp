//
//  SettingsSection.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import Foundation
import BakingRecipeStrings

public enum SettingsSection: Int, CaseIterable {
    case temp, appearance, language, about
    
    public var headerTitle: String? {
        switch self {
        case .temp: return nil
        case .appearance: return Strings.appearance
        case .language: return nil
        case .about: return nil
        }
    }
}
