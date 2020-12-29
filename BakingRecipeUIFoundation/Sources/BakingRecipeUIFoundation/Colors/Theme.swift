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
    
    private static let bundleExtension = "bundle"
    
    public let name: String
    let bundle: Bundle
    let config: ThemeConfiguration
    
    init(name: String, in containingBundle: Bundle = .main) throws {
        self.name = name
        
        guard let bundleURL = containingBundle.url(forResource: name, withExtension: Theme.bundleExtension) else {
            throw LoadError.resourceNotFound(name)
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

