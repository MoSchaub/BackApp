//
//  File.swift
//  
//
//  Created by Moritz Schaub on 27.10.20.
//

import UIKit

public extension UIAlertController {
    
    convenience init(preferredStyle: UIAlertController.Style) {
        self.init(title: nil, message: nil, preferredStyle: preferredStyle)
    }
}

