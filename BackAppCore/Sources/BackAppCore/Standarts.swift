//
//  Standarts.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import Foundation

public struct Standarts {
    
    public enum Key: String {
        case roomTemp
        case knedingHeatingEnabled
        case knedingHeating
        case theme
    }
}

public extension UserDefaults {
    func object<T>(for key: Standarts.Key, as Type: T.Type) -> T? {
        self.object(forKey: key.rawValue) as? T
    }
    
    func set<T: Codable>(_ value: T, for key: Standarts.Key) {
        self.set(value, forKey: key.rawValue)
    }
}

public extension Standarts {
    static var standardRoomTemperature: Int {
        get {
            if let int = UserDefaults.standard.object(for: .roomTemp, as: Int.self) {
                return int
            } else {
                UserDefaults.standard.set(20, for: .roomTemp)
                return 20
            }
        }
        set {
            UserDefaults.standard.set(newValue, for: .roomTemp)
        }
    }
}

public extension Standarts {
    static var knedingHeatEnabled: Bool {
        get {
            if let bool = UserDefaults.standard.object(for: .knedingHeatingEnabled, as: Bool.self) {
                return bool
            } else {
                UserDefaults.standard.set(false, for: .knedingHeatingEnabled)
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, for: .knedingHeatingEnabled)
        }
    }
    
    static var knedingHeat: Double {
        get {
            if let double = UserDefaults.standard.object(for: .knedingHeating, as: Double.self) {
                return double
            } else {
                UserDefaults.standard.set(0, for: .knedingHeating)
                return 0
            }
        }
        set {
            UserDefaults.standard.set(newValue, for: .knedingHeating)
        }
    }
}
