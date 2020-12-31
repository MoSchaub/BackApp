//
//  File.swift
//  
//
//  Created by Moritz Schaub on 31.12.20.
//

import BackAppCore
import Foundation

public extension Standarts {
    static var theme: Theme {
        get {
            if let themeRawValue = UserDefaults.standard.object(for: .theme, as: String.self) {
                return try! Theme(style: Theme.Style(rawValue: themeRawValue)!)
            } else {
                UserDefaults.standard.set(Theme.Style.auto.rawValue, for: .theme)
                return try! Theme(style: .auto)
            }
        }
        set {
            let newString = newValue.style.rawValue 
            UserDefaults.standard.set(newString, for: .theme)
        }
    }
}
