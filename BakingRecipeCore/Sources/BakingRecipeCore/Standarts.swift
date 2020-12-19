//
//  Standarts.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//

import Foundation


public struct Standarts {
    static let roomTempKey = "roomTemp"
}

public extension Standarts {
    static var standardRoomTemperature: Int {
        get {
            if let int = UserDefaults.standard.object(forKey:roomTempKey) as? Int {
                return int
            } else {
                UserDefaults.standard.set(20, forKey: roomTempKey)
                return 20
            }
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: roomTempKey)
        }
    }
}
