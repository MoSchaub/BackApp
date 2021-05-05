//
//  RecipeStore+Items.swift
//  
//
//  Created by Moritz Schaub on 19.12.20.
//
import BakingRecipeFoundation

public extension BackAppData {
    
    func recipeItem(for recipe: Recipe) -> RecipeItem {
        return RecipeItem(id: recipe.id, name: recipe.formattedName, imageData: recipe.imageData, minuteLabel: self.formattedTotalDuration(for: recipe.id))
    }

}
