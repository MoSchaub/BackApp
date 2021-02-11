//
//  Standarts.swift
//  
//
//  Created by Moritz Schaub on 03.10.20.
//
#if canImport(Combine)
import Combine
#endif

public struct Standarts {
    
    @UserDefaultsWrapper(key: .roomTemp, defaultValue: 20)
    public static var roomTemp: Double {
        didSet{
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.roomTemp(self.roomTemp))
            }
            #endif
        }
    }
    
    @UserDefaultsWrapper(key: .kneadingHeatingEnabled, defaultValue: false)
    public static var kneadingHeatingEnabled: Bool {
        didSet{
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.kneadingHeatingEnabled(self.kneadingHeatingEnabled))
            }
            #endif
        }
    }
    
    @UserDefaultsWrapper(key: .kneadingHeating, defaultValue: 0)
    public static var kneadingHeating: Double {
        didSet{
            #if canImport(Combine)
            if #available(iOS 13.0, *) {
                standartsChangedPublisher.send(.kneadingHeating(self.kneadingHeating))
            }
            #endif
        }
    }
    
    #if canImport(Combine)
    @available(iOS 13.0, *)
    public static var standartsChangedPublisher = PassthroughSubject<standartsChangedKey, Never>()
    #endif
    
    public enum standartsChangedKey: Equatable {
        case roomTemp(Double)
        case kneadingHeatingEnabled(Bool)
        case kneadingHeating(Double)
    }
}

