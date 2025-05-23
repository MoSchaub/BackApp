// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

private struct ColorUtilsKey {
    static var cellBackgroundColor: UIColor?
    
    static var primaryCellTextColor: UIColor?
    
    static var secondaryCellTextColor: UIColor?
    
    static var selectedCellBackgroundColor: UIColor?
    
    static var baTintColor: UIColor?
    
    static var baTintBackgroundColor: UIColor?
    
    static var secondaryTextColor: UIColor?
    
    static var secondaryCellBackgroundColor: UIColor?
}

public extension UIColor {
    
    private static func getAssociatedObject(key: inout UIColor?) -> UIColor? {
        return withUnsafePointer(to: &key) {
            objc_getAssociatedObject(self, $0) as? UIColor
        }
    }
    
    private static func setAssociatedObject<T>(key: inout UIColor?, value: T?) {
        withUnsafePointer(to: &key) {
            objc_setAssociatedObject(self, $0, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
    static var primaryCellTextColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.primaryCellTextColor)}
        set { setAssociatedObject(key: &ColorUtilsKey.primaryCellTextColor, value: newValue) }
    }
    
    static var secondaryTextColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.secondaryTextColor)}
        set { setAssociatedObject(key: &ColorUtilsKey.secondaryTextColor, value: newValue) }
    }
    
    static var secondaryCellTextColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.secondaryCellTextColor)}
        set { setAssociatedObject(key: &ColorUtilsKey.secondaryCellTextColor, value: newValue) }
    }
    
    static var cellBackgroundColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.cellBackgroundColor) }
        set { setAssociatedObject(key: &ColorUtilsKey.cellBackgroundColor, value: newValue) }
    }
    
    static var selectedCellBackgroundColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.selectedCellBackgroundColor) }
        set { setAssociatedObject(key: &ColorUtilsKey.selectedCellBackgroundColor, value: newValue) }
    }
    
    static var baTintColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.baTintColor) }
        set { setAssociatedObject(key: &ColorUtilsKey.baTintColor, value: newValue) }
    }
    
    static var baTintBackgroundColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.baTintBackgroundColor) }
        set { setAssociatedObject(key: &ColorUtilsKey.baTintBackgroundColor, value: newValue) }
    }
    
    static var secondaryCellBackgroundColor: UIColor? {
        get { getAssociatedObject(key: &ColorUtilsKey.secondaryCellBackgroundColor) }
        set { setAssociatedObject(key: &ColorUtilsKey.secondaryCellBackgroundColor, value: newValue) }
    }
}
