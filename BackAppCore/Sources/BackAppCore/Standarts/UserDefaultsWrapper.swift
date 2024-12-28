//
//  UserDefaultsWrapper.swift
//  
//
//  Created by Moritz Schaub on 01.01.21.
//


import Foundation
// Modified Version of: https://github.com/duckduckgo/iOS/blob/c3ae3845973915a7185698abbef5bd974328ce8a/Core/UserDefaultsPropertyWrapper.swift
// Licensed under Apache 2.0 license
// which was inspired by https://swiftsenpai.com/swift/create-the-perfect-userdefaults-wrapper-using-property-wrapper/

@propertyWrapper
public struct UserDefaultsWrapper<T> {
    
    public enum Key: String, CaseIterable {
        case roomTemp
        case kneadingHeatingEnabled
        case kneadingHeating
        case theme
        case newUser
    }
    
    private let key: Key
    private let defaultValue: T
    private let setIfEmpty: Bool
    
    public init(key: Key, defaultValue: T, setIfEmpty: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.setIfEmpty = setIfEmpty
    }
    
    public var wrappedValue: T {
        get {
            if let storedValue = UserDefaults.standard.object(forKey: key.rawValue) as? T {
                return storedValue
            }
            
            if setIfEmpty {
                UserDefaults.standard.set(defaultValue, forKey: key.rawValue)
            }
            
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}

