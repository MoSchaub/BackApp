//
//  ImageCell.swift
//  
//
//  Created by Moritz Schaub on 06.10.20.
//

import UIKit
import BakingRecipeUIFoundation

public class ImageCell: CustomCell {
    
     public init(reuseIdentifier: String?, data: Data?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        if let data = data {
            let image = UIImage(data: data, scale: 0.0001) ?? Images.largePhoto
            imageView?.image = image
            imageView?.contentMode = .scaleAspectFill
        } else {
            imageView?.image = Images.largePhoto
            imageView?.tintColor = .primaryCellTextColor
            imageView?.contentMode = .scaleAspectFit
        }
        
        imageView?.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

