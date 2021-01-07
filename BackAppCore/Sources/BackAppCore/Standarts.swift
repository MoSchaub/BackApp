//
//  Standarts.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//


public struct Standarts {
    
    @UserDefaultsWrapper(key: .roomTemp, defaultValue: 20)
    public static var roomTemp: Double
    
    @UserDefaultsWrapper(key: .kneadingHeatingEnabled, defaultValue: false)
    public static var kneadingHeatingEnabled: Bool
    
    @UserDefaultsWrapper(key: .kneadingHeating, defaultValue: 0)
    public static var kneadingHeating: Double
    
}
