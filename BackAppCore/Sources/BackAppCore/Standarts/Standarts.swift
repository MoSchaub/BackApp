// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  Standarts.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//
#if canImport(Combine)
import Combine
#endif

/// The settings are computed properties without stored state: their values live in `UserDefaults`,
/// which is thread-safe, so they can be read and written from any isolation domain.
public struct Standarts {
    
    public static var roomTemp: Double {
        get { UserDefaultsWrapper(key: .roomTemp, defaultValue: 20).wrappedValue }
        set {
            var setting = UserDefaultsWrapper(key: .roomTemp, defaultValue: 20.0)
            setting.wrappedValue = newValue
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.roomTemp(newValue))
            }
            #endif
        }
    }
    
    public static var kneadingHeatingEnabled: Bool {
        get { UserDefaultsWrapper(key: .kneadingHeatingEnabled, defaultValue: false).wrappedValue }
        set {
            var setting = UserDefaultsWrapper(key: .kneadingHeatingEnabled, defaultValue: false)
            setting.wrappedValue = newValue
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.kneadingHeatingEnabled(newValue))
            }
            #endif
        }
    }
    
    public static var kneadingHeating: Double {
        get { UserDefaultsWrapper(key: .kneadingHeating, defaultValue: 0).wrappedValue }
        set {
            var setting = UserDefaultsWrapper(key: .kneadingHeating, defaultValue: 0.0)
            setting.wrappedValue = newValue
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.kneadingHeating(newValue))
            }
            #endif
        }
    }
    
    static var newUser: Bool {
        get { UserDefaultsWrapper(key: .newUser, defaultValue: true).wrappedValue }
        set {
            var setting = UserDefaultsWrapper(key: .newUser, defaultValue: true)
            setting.wrappedValue = newValue
        }
    }
    
    #if canImport(Combine)
    /// `nonisolated(unsafe)` because Combine subjects synchronize `send` internally.
    @available(iOS 13.0, *)
    nonisolated(unsafe) public static let standartsChangedPublisher = PassthroughSubject<standartsChangedKey, Never>()
    #endif
    
    public enum standartsChangedKey: Equatable {
        case roomTemp(Double)
        case kneadingHeatingEnabled(Bool)
        case kneadingHeating(Double)
    }
}

