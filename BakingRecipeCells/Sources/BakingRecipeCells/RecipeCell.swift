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

public enum SqlableError: Error {
    case fetching(message: String)
    case deleting(message: String)
}

public class RecipeCell: CustomCell {
    class ViewModel {
        var appData: BackAppData
    
        
        //delete the recipe
        func deleteRecipe(with id: Int) -> Just<SqlableError?> {
            
            // get the recipe object
            guard let recipe = appData.object(with: id, of: Recipe.self) else {
                return Just<SqlableError?>(.fetching(message: "Error fetching recipe with id \(id)"))
            }
            
            guard appData.delete(recipe) else {
                return Just<SqlableError?>(.deleting(message: "Error deleting recipe with id \(id)"))
            }
            
            return Just<SqlableError?>(.none)
        }
        
        func toggleFavoriteRecipe(with id: Int) -> Just<SqlableError?> {
            
            //get the recipe
            guard var recipe = appData.object(with: id, of: Recipe.self) else {
                return Just<SqlableError?>(.fetching(message: "Error fetching recipe with id \(id)"))
            }
            
            recipe.isFavorite.toggle()
            
            guard appData.update(recipe) else {
                return Just<SqlableError?>(.deleting(message: "Error updating recipe with id \(id)"))
            }
            
            return Just(nil)
        }
        
        init(appData: BackAppData) {
            self.appData = appData
        }
    }
    
    
    
    public var name: String
    public var minuteLabel: String
    public var imageData: Data?
    private var id: Int
    private var viewModel: ViewModel
    
    lazy var imageAccessory = makeImageAccesory()

    public init(name: String, minuteLabel: String, imageData: Data?, id: Int, appData: BackAppData , reuseIdentifier: String?) {
        self.name = name
        self.minuteLabel = minuteLabel
        self.imageData = imageData
        self.id = id
        self.viewModel = ViewModel(appData: appData)
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
        guard let image = UIImage(data: imageData) else {
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

public extension RecipeCell {
    func deleteRecipePublisher() -> Just<SqlableError?> {
        self.viewModel.deleteRecipe(with: self.id)
    }
    
    func toggleFavouriteRecipePublisher() -> Just<SqlableError?> {
        self.viewModel.toggleFavoriteRecipe(with: id)
    }
}
