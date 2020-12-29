//
//  ThemeConfiguration.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

struct ThemeConfiguration: Codable {
    let statusBarStyle: Int
    
    init(statusBarStyle: Int) {
        self.statusBarStyle = statusBarStyle
    }
}
