//
//  SettingsSection.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import Foundation
import BakingRecipeStrings

public enum SettingsSection: Int, CaseIterable {
    case temp, export, language , about
    
    public var headerTitle: String? {
        switch self {
        case .temp: return Strings.temperature
        case .export: return nil
        case .language: return nil
        case .about: return nil
        }
    }
}
