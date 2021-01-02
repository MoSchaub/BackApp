//
//  ThemeManager.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

public extension Notification.Name {
    static let currentThemeDidChangeToAuto = Notification.Name("CurrentThemeDidChangeToAuto")
    static let currentThemeDidChangeToLight = Notification.Name("CurrentThemeDidChangeToLight")
    static let currentThemeDidChangeToDark = Notification.Name("CurrentThemeDidChangeToDark")
    static let sceneShouldReload = Notification.Name("SceneShouldReload")
}

public final class ThemeManager {
    
    private static let defaultThemeName = Theme.Style.auto
    
    public static let `default` = ThemeManager()
    
    public var currentTheme: Theme {
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToAuto), name: .currentThemeDidChangeToAuto, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToLight), name: .currentThemeDidChangeToLight, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDark), name: .currentThemeDidChangeToDark, object: nil)
    }
    
    @objc private func changeToAuto() {
        changeCurrentTheme(with: Theme.Style.auto)
    }
    @objc private func changeToLight() {
        changeCurrentTheme(with: Theme.Style.light)
    }
    @objc private func changeToDark() {
        changeCurrentTheme(with: Theme.Style.dark)
    }
    
    private func changeCurrentTheme(with style: Theme.Style) {
        self.currentTheme.style = style
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

        
        invalidateViews()
    }
    
    private func invalidateViews() {
        NotificationCenter.default.post(Notification(name: .sceneShouldReload))
//        UIApplication.shared.windows.forEach { window in
//            window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
//            window.rootViewController?.children.forEach({ $0.setNeedsStatusBarAppearanceUpdate() })
//
//            window.subviews.forEach { view in
//                view.removeFromSuperview()
//                window.addSubview(view)
//            }
//        }
    }
    
}

