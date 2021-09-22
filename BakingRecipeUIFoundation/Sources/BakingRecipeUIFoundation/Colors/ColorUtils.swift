//
//  ColorUtils.swift
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

struct AssociatedKeys {
    static var cellBackgroundColor: UIColor?
    
    static var primaryCellTextColor: UIColor?
    
    static var secondaryCellTextColor: UIColor?
    
    static var selectedCellBackgroundColor: UIColor?
    
    static var baTintColor: UIColor?
    
    static var secondaryTextColor: UIColor?
}

public extension UIColor {
    static var primaryCellTextColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.primaryCellTextColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.primaryCellTextColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var secondaryTextColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.secondaryTextColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.secondaryTextColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var secondaryCellTextColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.secondaryCellTextColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.secondaryCellTextColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var cellBackgroundColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.cellBackgroundColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cellBackgroundColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var selectedCellBackgroundColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.selectedCellBackgroundColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.selectedCellBackgroundColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var baTintColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.baTintColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.baTintColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
