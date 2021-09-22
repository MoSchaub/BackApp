//
//  ThemeManager.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

public final class ThemeManager {
    
    public static let `default` = ThemeManager()
    
    private var currentTheme: Theme {
        didSet {
            registerAppearance()
        }
    }
    
    init() {
        self.currentTheme = Theme()
        registerAppearance()
    }
    
    private func registerAppearance() {
        UIWindow.appearance().backgroundColor = currentTheme.backgroundColor
        UIWindow.appearance().tintColor = currentTheme.baTintColor
        
        UITableView.appearance().backgroundColor = currentTheme.backgroundColor

        UITableViewCell.appearance().backgroundColor = currentTheme.backgroundColor
        
        UIColor.cellBackgroundColor = currentTheme.cellBackgroundColor
        UIColor.selectedCellBackgroundColor = currentTheme.selectedCellBackground
        UIColor.baTintColor = currentTheme.baTintColor
        UIColor.primaryCellTextColor = currentTheme.primaryCellTextColor
        UIColor.secondaryCellTextColor = currentTheme.secondaryCellTextColor
        UIColor.secondaryTextColor = currentTheme.secondaryTextColor
        
        UINavigationBar.appearance().backgroundColor = currentTheme.backgroundColor
        UINavigationBar.appearance().barTintColor = currentTheme.backgroundColor

        if let textColor = currentTheme.primaryTextColor {
            let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: textColor]
            UINavigationBar.appearance().titleTextAttributes = attrs
        }

        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:currentTheme.primaryTextColor!]

        UIToolbar.appearance().backgroundColor = currentTheme.backgroundColor
        UIToolbar.appearance().barTintColor = currentTheme.backgroundColor
        
        UILabel.appearance(whenContainedInInstancesOf: [UIView.self]).textColor = currentTheme.primaryTextColor

    }
    
}

