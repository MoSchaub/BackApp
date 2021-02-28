//
//  ThemeManager.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

public final class ThemeManager {
    
    private static let defaultThemeName = Theme.Style.auto
    
    public static let `default` = ThemeManager()
    
    private var currentTheme: Theme {
        didSet {
            registerAppearance()
        }
    }
    
    init() {
        do {
            self.currentTheme = try Theme(style: ThemeManager.defaultThemeName)
            registerAppearance()
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    private func registerAppearance() {
        UIWindow.appearance().backgroundColor = currentTheme.backgroundColor
        UIWindow.appearance().tintColor = currentTheme.tintColor

        if currentTheme.style == .light {
            UIWindow.appearance().overrideUserInterfaceStyle = .light
        } else if currentTheme.style == .dark {
            UIWindow.appearance().overrideUserInterfaceStyle = .dark
        }

        UITableView.appearance().backgroundColor = currentTheme.backgroundColor

        UITableViewCell.appearance().backgroundColor = currentTheme.backgroundColor
        
        UIColor.cellBackgroundColor = currentTheme.cellBackgroundColor
        UIColor.selectedCellBackgroundColor = currentTheme.selectedCellBackground
        UIColor.tintColor = currentTheme.tintColor
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
