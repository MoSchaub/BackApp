//
//  Standarts+Theme.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import BackAppCore
import Foundation

public extension Standarts {
    
    @UserDefaultsWrapper(key: .theme, defaultValue: Theme.Style.auto.number)
    static private var themeNumber: Int
    
    static var theme: Theme.Style {
        get {
            Theme.Style.allCases.first(where: {$0.number == themeNumber}) ?? Theme.Style.auto
        }
        set {
            self.themeNumber = newValue.number
            switch newValue {
            case .auto: NotificationCenter.default.post(name: .currentThemeDidChangeToAuto, object: nil)
            case .light: NotificationCenter.default.post(name: .currentThemeDidChangeToLight, object: nil)
            case .dark: NotificationCenter.default.post(name: .currentThemeDidChangeToDark, object: nil)
            }
        }
    }
    
}
