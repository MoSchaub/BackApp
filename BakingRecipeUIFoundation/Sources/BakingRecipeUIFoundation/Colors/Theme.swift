//
//  Theme.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

public struct Theme {
    
    enum LoadError: Error {
        case resourceNotFound(String)
        case bundleInitialization
        case configNotFound
        case configUnserialize(Error)
    }
    
    public enum Style: String {
        case auto
        case light
        case dark
    }
    
    private static let bundleExtension = "bundle"
    
    public let style: Style
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

