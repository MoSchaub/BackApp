//
//  RecipeCell.swift
//  
//
//  Created by Moritz Schaub on 05.10.20.
//

import UIKit
import BackAppCore
import BakingRecipeUIFoundation
import BakingRecipeFoundation
import Combine

public class RecipeCell: CustomCell {
    public var name: String
    public var minuteLabel: String
    public var imageData: Data?
    
    lazy var imageAccessory = makeImageAccesory()

    public init(name: String, minuteLabel: String, imageData: Data?, reuseIdentifier: String?) {
        self.name = name
        self.minuteLabel = minuteLabel
        self.imageData = imageData
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func setup() {
        super.setup()
        
        self.textLabel?.text = name
        self.detailTextLabel?.text = minuteLabel
        
        self.accessoryView = imageAccessory
    }


}

private extension RecipeCell {
    func makeImageAccesory() -> UIImageView? {
        guard let imageData = imageData else {
            return nil
        }
        guard let image = UIImage(data: imageData, scale: 0.0001) else {
            return nil
        }
        let height = self.bounds.height
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: height * 1.5, height: height)))
        
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        
        return imageView
    }
}
