//
//  ImageTableViewCell.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 29.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings
import BakingRecipeUIFoundation

class ImageTableViewCell: UITableViewCell {
    
    struct ImageView: View {
        
        var data: Data?
        
        var body: some View {
                Group {
                    if data != nil {
                        Image(uiImage: UIImage(data: data!)!)
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(cornerRadius)
                    } else {
                        Image(uiImage: Images.largePhoto)
                            .resizable()
                            .imageScale(.large)
                            .scaledToFit()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .background(Color.cellBackgroundColor())
        }
        
        let cornerRadius: CGFloat = 10
        let maxHeight: CGFloat = 250
    }
    
    init(reuseIdentifier: String?, data: Data?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        if let data = data {
            let image = UIImage(data: data) ?? Images.largePhoto
            imageView?.image = image
            imageView?.contentMode = .scaleAspectFill
        } else {
            imageView?.image = Images.largePhoto
            imageView?.tintColor = .label
            imageView?.contentMode = .scaleAspectFit
        }
        
        imageView?.fillSuperview()
        backgroundColor = UIColor(named: Strings.backgroundColorName)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct ImageTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        ImageTableViewCell.ImageView()
    }
}
