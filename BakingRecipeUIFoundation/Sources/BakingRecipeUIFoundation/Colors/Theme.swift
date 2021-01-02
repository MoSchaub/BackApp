//
//  Theme.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit
import BakingRecipeStrings

public struct Theme {
    
    enum LoadError: Error {
        case resourceNotFound(String)
        case bundleInitialization
        case configNotFound
        case configUnserialize(Error)
    }
    
    public enum Style: String, CaseIterable, Codable {
        case auto
        case light
        case dark
        
        public var description: String {
            switch self {
            case .auto: return Strings.auto
            case .light: return Strings.light
            case .dark: return Strings.dark
            }
        }
        
        public var number: Int {
            switch self {
            case .auto: return 0
            case .light: return 1
            case .dark: return 2
            }
        }
    }
    
    private static let bundleExtension = "bundle"
    
    public var style: Style
    let bundle: Bundle
    let config: ThemeConfiguration
    
    init(style: Style, in containingBundle: Bundle = .main) throws {
        self.style = style
        
        guard let bundleURL = containingBundle.url(forResource: style.rawValue, withExtension: Theme.bundleExtension) else {
            throw LoadError.resourceNotFound(style.rawValue)
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            throw LoadError.bundleInitialization
        }
        
        self.bundle = bundle
        
        guard let configAsset = NSDataAsset(name: "config", bundle: bundle) else {
            throw LoadError.configNotFound
        }
        
        do {
            self.config = try PropertyListDecoder().decode(ThemeConfiguration.self, from: configAsset.data)
        } catch {
            throw LoadError.configUnserialize(error)
        }
    }
    
}

