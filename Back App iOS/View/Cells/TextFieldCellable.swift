//
//  TextFieldCellable.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

protocol TextFieldCellable {
    var textField: UITextField { get set }
    
    var textChanged: ((String) -> Void)? { get set }
    
    func configureTextField()
    
    func setTextFieldConstraints()
    
}
